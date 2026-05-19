import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';
import '../services/github_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? profile;

  Map<String, dynamic>? repo;

  Map<String, dynamic>? languages;

  Map<String, dynamic>? aiPortfolio;

  List<dynamic> repos = [];

  final usernameController = TextEditingController();

  final profileUsernameController = TextEditingController();

  final repoController = TextEditingController();

  bool isLoading = false;

  bool isGeneratingAI = false;

  // =========================
  // LOGOUT
  // =========================

 Future<void> logout() async {
  try {
    await ApiService.logout();

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  } catch (e) {
    print("Logout Error: $e");
  }
}

  // =========================
  // ANALYZE PROFILE
  // =========================

  Future<void> analyzeProfile() async {
    if (profileUsernameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final data = await GithubService.fetchProfile(
      profileUsernameController.text.trim(),
    );

    final repoData = await GithubService.fetchUserRepos(
      profileUsernameController.text.trim(),
    );

    setState(() {
      profile = data;
      repos = repoData ?? [];
      isLoading = false;
    });
  }

  // =========================
  // ANALYZE REPOSITORY
  // =========================

  Future<void> analyzeRepo() async {
    if (repoController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = repoController.text.trim();

      Uri uri = Uri.parse(url);

      final segments = uri.pathSegments;

      if (segments.length < 2) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final owner = segments[0];

      final repoName = segments[1].replaceAll('.git', '');

      final repoData = await GithubService.fetchRepo(owner, repoName);

      final languageData = await GithubService.fetchLanguages(owner, repoName);

      setState(() {
        repo = repoData;

        languages = Map<String, dynamic>.from(languageData ?? {});

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // AI PORTFOLIO GENERATOR
  // =========================

  Future<void> generateAIPortfolio() async {
    if (usernameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isGeneratingAI = true;
    });

    try {
      final response = await Dio().post(
        'http://192.168.110.196:8000/ai/generate/',
        data: {"username": usernameController.text.trim()},
      );

      setState(() {
        aiPortfolio = response.data;
        isGeneratingAI = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isGeneratingAI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff6C63FF), Color(0xff8E7CFF)],
            ),
          ),
        ),

        title: const Text(
          'AI GitHub Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =========================
            // HERO SECTION
            // =========================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6C63FF), Color(0xff8E7CFF)],
                ),

                borderRadius: BorderRadius.circular(30),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 34),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "AI Resume Generator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Generate AI-powered resume, ATS analysis, developer insights, portfolio descriptions and career recommendations from GitHub.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,

                    children: [
                      _buildFeatureChip("AI Resume"),
                      _buildFeatureChip("ATS Score"),
                      _buildFeatureChip("Portfolio"),
                      _buildFeatureChip("Career Analysis"),
                      _buildFeatureChip("Skill Detection"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _buildInputField(
                    controller: usernameController,
                    hint: 'Enter GitHub Username',
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: generateAIPortfolio,

                      child: isGeneratingAI
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Generate AI Portfolio",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // =========================
            // PROFILE ANALYZER
            // =========================
            const Text(
              'GitHub Profile Analyzer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildInputField(
              controller: profileUsernameController,
              hint: 'Enter GitHub Username',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 20),

            _buildButton(title: 'Analyze Profile', onTap: analyzeProfile),

            const SizedBox(height: 35),

            // =========================
            // REPO ANALYZER
            // =========================
            const Text(
              'Repository Analyzer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildInputField(
              controller: repoController,
              hint: 'Enter GitHub Repo URL',
              icon: Icons.link,
            ),

            const SizedBox(height: 15),

            _buildButton(title: 'Analyze Repository', onTap: analyzeRepo),

            const SizedBox(height: 30),

            if (isLoading) const Center(child: CircularProgressIndicator()),

            // =========================
            // PROFILE DETAILS
            // =========================
            if (profile != null)
              Container(
                margin: const EdgeInsets.only(top: 35),

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundImage: NetworkImage(profile!['avatar']),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                profile!['name']?.toString() ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "@${profile!['username']?.toString() ?? 'N/A'}",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                profile!['bio']?.toString() ??
                                    'No bio available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.4,

                      children: [
                        _buildStatCard(
                          "Followers",
                          (profile!['followers'] ?? 0).toString(),
                          Icons.people,
                        ),

                        _buildStatCard(
                          "Following",
                          (profile!['following'] ?? 0).toString(),
                          Icons.person_add,
                        ),

                        _buildStatCard(
                          "Repositories",
                          (profile!['public_repos'] ?? 0).toString(),
                          Icons.folder,
                        ),

                        _buildStatCard(
                          "Gists",
                          (profile!['public_gists'] ?? 0).toString(),
                          Icons.code,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Repositories",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: repos.length > 5 ? 5 : repos.length,

                      itemBuilder: (context, index) {
                        final repo = repos[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: const Color(0xffF5F7FB),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.book,
                                    color: Colors.deepPurple,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      repo['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(repo['description'] ?? 'No description'),

                              const SizedBox(height: 15),

                              Row(
                                children: [
                                  _buildMiniStat(
                                    Icons.star,
                                    (repo['stars'] ?? 0).toString(),
                                  ),

                                  _buildMiniStat(
                                    Icons.call_split,
                                    (repo['forks'] ?? 0).toString(),
                                  ),

                                  _buildMiniStat(
                                    Icons.remove_red_eye,
                                    (repo['watchers'] ?? 0).toString(),
                                  ),

                                  const SizedBox(width: 20),

                                  _buildMiniStat(
                                    Icons.code,
                                    repo['language']?.toString() ?? 'N/A',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            // =========================
            // AI ANALYSIS
            // =========================
            if (aiPortfolio != null)
              Container(
                margin: const EdgeInsets.only(top: 35),

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Colors.deepPurple,
                          size: 32,
                        ),

                        SizedBox(width: 10),

                        Text(
                          "AI Developer Analysis",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildAISection("About Me", aiPortfolio!['about_me'] ?? ''),

                    _buildAISection(
                      "Resume Summary",
                      aiPortfolio!['resume_summary'] ?? '',
                    ),

                    _buildAISection(
                      "Developer Type",
                      aiPortfolio!['developer_type'] ?? '',
                    ),

                    _buildAISection(
                      "Experience Level",
                      aiPortfolio!['experience_level'] ?? '',
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "ATS Score",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade700,
                          ],
                        ),

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Center(
                        child: Text(
                          aiPortfolio!['ats_score'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildListSection("Strengths", aiPortfolio!['strengths']),

                    _buildListSection("Weaknesses", aiPortfolio!['weaknesses']),

                    _buildListSection(
                      "Recommended Learning",
                      aiPortfolio!['learn_next'],
                    ),

                    _buildListSection(
                      "Career Roles",
                      aiPortfolio!['career_roles'],
                    ),
                  ],
                ),
              ),

            // =========================
            // REPO ANALYSIS
            // =========================
            if (repo != null)
              Container(
                margin: const EdgeInsets.only(top: 35),

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.deepPurple,
                          size: 30,
                        ),

                        SizedBox(width: 10),

                        Text(
                          "Repository Insights",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildRepoInfo(
                      "Repository Name",
                      repo!['name']?.toString() ?? 'N/A',
                    ),

                    _buildRepoInfo(
                      "Description",
                      repo!['description']?.toString() ?? 'No description',
                    ),

                    _buildRepoInfo(
                      "Default Branch",
                      repo!['default_branch']?.toString() ?? 'N/A',
                    ),

                    _buildRepoInfo(
                      "Created At",
                      repo!['created_at']?.toString() ?? 'N/A',
                    ),

                    _buildRepoInfo(
                      "Updated At",
                      repo!['updated_at']?.toString() ?? 'N/A',
                    ),

                    const SizedBox(height: 25),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.4,

                      children: [
                        _buildStatCard(
                          "Stars",
                          (repo!['stars'] ?? 0).toString(),
                          Icons.star,
                        ),

                        _buildStatCard(
                          "Forks",
                          (repo!['forks'] ?? 0).toString(),
                          Icons.call_split,
                        ),

                        _buildStatCard(
                          "Open Issues",
                          (repo!['open_issues_count'] ?? 0).toString(),
                          Icons.bug_report,
                        ),

                        _buildStatCard(
                          "Watchers",
                          (repo!['watchers'] ?? 0).toString(),
                          Icons.remove_red_eye,
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      "Language Distribution",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      height: 300,

                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(),
                          centerSpaceRadius: 60,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,

                      children: languages!.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            "${e.key} : ${e.value}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // =========================
  // INPUT FIELD
  // =========================

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),

        contentPadding: const EdgeInsets.symmetric(vertical: 18),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =========================
  // BUTTON
  // =========================

  Widget _buildButton({required String title, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff6C63FF),

          padding: const EdgeInsets.symmetric(vertical: 18),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        onPressed: onTap,

        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =========================
  // FEATURE CHIP
  // =========================

  Widget _buildFeatureChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // AI SECTION
  // =========================

  Widget _buildAISection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // LIST SECTION
  // =========================

  Widget _buildListSection(String title, List<dynamic>? items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: (items ?? [])
                .map<Widget>(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Text(
                      e.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // =========================
  // STAT CARD
  // =========================

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff6C63FF), Color(0xff8E7CFF)],
        ),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.white, size: 30),

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MINI STAT
  // =========================

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),

        const SizedBox(width: 5),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // =========================
  // REPO INFO
  // =========================

  Widget _buildRepoInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // PIE CHART
  // =========================

  List<PieChartSectionData> _buildPieSections() {
    if (languages == null || languages!.isEmpty) {
      return [];
    }

    final total = languages!.values
        .map((e) => (e as num).toDouble())
        .reduce((a, b) => a + b);

    final colors = [
      const Color(0xff6C63FF),
      const Color(0xffFF6584),
      const Color(0xff4CAF50),
      const Color(0xffFF9800),
      Colors.blue,
      Colors.teal,
    ];

    int index = 0;

    return languages!.entries.map((entry) {
      final value = (entry.value as num).toDouble();

      final percentage = (value / total) * 100;

      final section = PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

      index++;

      return section;
    }).toList();
  }
}
