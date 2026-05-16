import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // CHANGE IP
  static const String baseUrl = 'http://YOURIP:8000';

  // =========================
  // LOGIN
  // =========================

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/token/'),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('access', data['access']);

      await prefs.setString('refresh', data['refresh']);

      return true;
    }

    return false;
  }

  // =========================
  // REGISTER
  // =========================

  static Future<bool> register(
    String username,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/api/register/'),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({
        'username': username,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // =========================
  // LOGOUT
  // =========================

  static Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final refresh = prefs.getString('refresh');

    final response = await http.post(
      Uri.parse('$baseUrl/users/api/logout/'),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({'refresh': refresh}),
    );

    return response.statusCode == 205;
  }

  // =========================
  // GET TASKS
  // =========================

  static Future<List<dynamic>> getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access');

    final response = await http.get(
      Uri.parse('$baseUrl/tasks/api/tasks/'),

      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  // =========================
  // CREATE TASK
  // =========================

  static Future<bool> createTask(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access');

    final response = await http.post(
      Uri.parse('$baseUrl/tasks/api/tasks/create/'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({'title': title}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // =========================
  // TOGGLE TASK
  // =========================

  static Future<bool> updateTask(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access');

    final response = await http.post(
      Uri.parse('$baseUrl/tasks/api/tasks/toggle/$id/'),

      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // =========================
  // DELETE TASK
  // =========================

  static Future<bool> deleteTask(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access');

    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/api/tasks/delete/$id/'),

      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
