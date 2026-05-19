import 'dart:convert';

import 'package:http/http.dart' as http;

class GithubService {
  static const String baseUrl = 'http://YOUR_IP:8000';

  // =========================
  // PROFILE
  // =========================

  static Future<Map<String, dynamic>?> fetchProfile(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/github/profile/$username/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile data: $data');
        return data;
      } else {
        print('Profile fetch error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Profile fetch exception: $e');
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/github/repo/$owner/$repo/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Repo data: $data');
        return data;
      } else {
        print('Repo fetch error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Repo fetch exception: $e');
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/github/languages/$owner/$repo/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Languages data: $data');
        return data;
      } else {
        print(
          'Languages fetch error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Languages fetch exception: $e');
    }
    return null;
  }

  // =========================
  // FETCH USER REPOS
  // =========================

  static Future<List<dynamic>?> fetchUserRepos(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/github/repos/$username/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('User repos data: $data');
        return data;
      } else {
        print(
          'User repos fetch error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('User repos fetch exception: $e');
    }
    return null;
  }
}
