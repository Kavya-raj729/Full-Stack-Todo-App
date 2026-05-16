import 'dart:convert';

import 'package:http/http.dart' as http;

class GithubService {
  static const String baseUrl = 'http://YOUR_IP:8000';

  // =========================
  // PROFILE
  // =========================

  static Future<Map<String, dynamic>?> fetchProfile(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/github/profile/$username/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // =========================
  // REPO
  // =========================

  static Future<Map<String, dynamic>?> fetchRepo(
    String owner,
    String repo,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/github/repo/$owner/$repo/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // =========================
  // FETCH LANGUAGES
  // =========================

  static Future<Map<String, dynamic>?> fetchLanguages(
    String owner,
    String repo,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/github/languages/$owner/$repo/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // =========================
  // FETCH USER REPOS
  // =========================

  static Future<List<dynamic>?> fetchUserRepos(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/github/repos/$username/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}
