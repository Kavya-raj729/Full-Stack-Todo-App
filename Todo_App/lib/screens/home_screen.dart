import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<dynamic> repos = [];

  final usernameController = TextEditingController();

  final repoController = TextEditingController();

  bool isLoading = false;

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    bool success = await ApiService.logout();

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(builder: (_) => const LoginScreen()),

        (route) => false,
      );
    }
  }

  // =========================
  // ANALYZE PROFILE
  // =========================

  Future<void> analyzeProfile() async {
    if (usernameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final data = await GithubService.fetchProfile(
      usernameController.text.trim(),
    );

    final repoData = await GithubService.fetchUserRepos(
      usernameController.text.trim(),
    );

    setState(() {
      profile = data;

      repos = repoData ?? [];

      isLoading = false;
    });
  }

  // =========================
  // ANALYZE REPO
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

      print(url);

      Uri uri = Uri.parse(url);

      final segments = uri.pathSegments;

      if (segments.length < 2) {
        print('Invalid Repo URL');

        setState(() {
          isLoading = false;
        });

        return;
      }

      final owner = segments[0];

      final repoName = segments[1].replaceAll('.git', '');

      print(owner);
      print(repoName);

      final repoData = await GithubService.fetchRepo(owner, repoName);

      print(repoData);

      final languageData = await GithubService.fetchLanguages(owner, repoName);

      print(languageData);

      setState(() {
        repo = repoData;

        languages = Map<String, dynamic>.from(languageData ?? {});

        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
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
          'GitHub Dashboard',

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
            // PROFILE ANALYZER
            // =========================
            const Text(
              'GitHub Profile Analyzer',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildInputField(
              controller: usernameController,

              hint: 'Enter GitHub Username',

              icon: Icons.person,
            ),

            const SizedBox(height: 15),

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
            // PROFILE CARD
            // =========================
            if (profile != null)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade500,

                      Colors.purple.shade300,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(30),
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,

                      backgroundImage: NetworkImage(profile!['avatar']),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      profile!['name'] ?? '',

                      style: const TextStyle(
                        fontSize: 28,

                        fontWeight: FontWeight.bold,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '@${profile!['username']}',

                      style: const TextStyle(
                        color: Colors.white70,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      profile!['bio'] ?? '',

                      textAlign: TextAlign.center,

                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),

                    const SizedBox(height: 25),

                    Wrap(
                      spacing: 15,

                      runSpacing: 15,

                      children: [
                        _buildStatCard('Followers', '${profile!['followers']}'),

                        _buildStatCard('Following', '${profile!['following']}'),

                        _buildStatCard(
                          'Repositories',
                          '${profile!['public_repos']}',
                        ),

                        _buildStatCard(
                          'Location',
                          '${profile!['location'] ?? 'N/A'}',
                        ),

                        _buildStatCard(
                          'Company',
                          '${profile!['company'] ?? 'N/A'}',
                        ),

                        _buildStatCard(
                          'Public Gists',
                          '${profile!['public_gists'] ?? '0'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // =========================
            // TOP REPOSITORIES
            // =========================
            if (repos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 35),

                  const Text(
                    'Top Repositories',

                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: repos.length,

                    itemBuilder: (context, index) {
                      final repo = repos[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    repo['name'],

                                    style: const TextStyle(
                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    repo['language'] ?? 'Unknown',

                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                const Icon(Icons.star, color: Colors.orange),

                                const SizedBox(height: 5),

                                Text('${repo['stars']}'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

            // =========================
            // REPO DETAILS
            // =========================
            if (repo != null)
              Container(
                margin: const EdgeInsets.only(top: 35),

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(30),

                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      repo!['name'] ?? '',

                      style: const TextStyle(
                        fontSize: 28,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      repo!['description'] ?? 'No Description',

                      style: TextStyle(
                        color: Colors.grey.shade700,

                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Wrap(
                      spacing: 15,
                      runSpacing: 15,

                      children: [
                        _buildStatCard('Stars', '${repo!['stars']}'),

                        _buildStatCard('Forks', '${repo!['forks']}'),

                        _buildStatCard('Watchers', '${repo!['watchers']}'),

                        _buildStatCard('Issues', '${repo!['issues']}'),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'Repository Health Score',

                      style: TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),

                      child: LinearProgressIndicator(
                        value: calculateHealthScore() / 100,

                        minHeight: 20,

                        backgroundColor: Colors.grey.shade300,

                        valueColor: AlwaysStoppedAnimation<Color>(
                          calculateHealthScore() > 70
                              ? Colors.green
                              : calculateHealthScore() > 40
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${calculateHealthScore().toStringAsFixed(1)} / 100',

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Wrap(
                      spacing: 15,
                      runSpacing: 15,

                      children: [
                        _buildStatCard(
                          'Language',
                          '${repo!['language'] ?? 'N/A'}',
                        ),

                        _buildStatCard('Size', '${repo!['size']} KB'),

                        _buildStatCard('Branch', '${repo!['default_branch']}'),

                        _buildStatCard('Created', '${repo!['created_at']}'),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'Language Distribution',

                      style: TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    if (languages == null || languages!.isEmpty)
                      Container(
                        height: 220,

                        alignment: Alignment.center,

                        child: const Text(
                          'No Language Data Found',

                          style: TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            height: 280,

                            child: PieChart(
                              PieChartData(
                                sections: _buildPieSections(),

                                sectionsSpace: 3,

                                centerSpaceRadius: 65,
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
                                  horizontal: 14,

                                  vertical: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius: BorderRadius.circular(14),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,

                                      blurRadius: 5,
                                    ),
                                  ],
                                ),

                                child: Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    CircleAvatar(
                                      radius: 6,

                                      backgroundColor: Colors.deepPurple,
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      e.key,

                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
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
      const Color(0xff00BCD4),
      const Color(0xff9C27B0),
      const Color(0xff3F51B5),
      const Color(0xffE91E63),
    ];

    int index = 0;

    return languages!.entries.map((entry) {
      final value = (entry.value as num).toDouble();

      final percentage = (value / total) * 100;

      final section = PieChartSectionData(
        color: colors[index % colors.length],

        value: percentage,

        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',

        radius: 100,

        titleStyle: const TextStyle(
          fontSize: 12,

          fontWeight: FontWeight.bold,

          color: Colors.white,
        ),
      );

      index++;

      return section;
    }).toList();
  }
  // =========================
  // HEALTH SCORE
  // =========================

  double calculateHealthScore() {
    if (repo == null) return 0;

    double score = 0;

    score += (repo!['stars'] ?? 0) * 0.45;

    score += (repo!['forks'] ?? 0) * 0.30;

    score += (repo!['watchers'] ?? 0) * 0.15;

    score -= (repo!['issues'] ?? 0) * 0.10;

    if (score > 100) {
      score = 100;
    }

    if (score < 0) {
      score = 0;
    }

    return score;
  }

  // =========================
  // STAT CARD
  // =========================

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.38,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: TextStyle(
              color: Colors.grey.shade600,

              fontSize: 14,

              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.black87,

              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
