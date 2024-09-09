import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://gardeniakosmetyka.com/api/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        body: {'email': email, 'password': password},
      ).timeout(Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await _saveAuthData(data);
        return data;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Unable to establish connection: $e');
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['access_token']);
      await prefs.setString(_userKey, json.encode(data['user']));
    } catch (e) {
      throw Exception('Unable to save auth data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_tokenKey);
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      return UserModel.fromSharedPreferences(userString);
    } catch (e) {
      throw Exception('Unable to retrieve user data: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('Unable to logout: $e');
    }
  }
}