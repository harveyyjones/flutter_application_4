import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://gardeniakosmetyka.com/api/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        body: {'email': email, 'password': password},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Full response: ${response.body}');
        
        // Extract the token from the response
        final String token = data['access_token'];
        
        // Save the auth data including the new token
        await _saveAuthData(data, token);
        
        print('Login successful. Token: $token');
        return data;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Unable to establish connection: $e');
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, json.encode(data['user']));
      print('Auth data saved. Token: $token');
    } catch (e) {
      throw Exception('Unable to save auth data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.containsKey(_tokenKey);
      if (isLoggedIn) {
        final token = prefs.getString(_tokenKey);
        print('User is logged in. Token: $token');
      } else {
        print('User is not logged in.');
      }
      return isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Retrieved token: $token');
    return token;
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token set: $token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token cleared');
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
      final token = prefs.getString(_tokenKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove('ad');
      print('Logout successful. Cleared token: $token');
    } catch (e) {
      throw Exception('Unable to logout: $e');
    }
  }

  Future<void> saveAdToPreferences(Map<String, dynamic> adData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ad', json.encode(adData));
      print('Ad data saved: $adData');
    } catch (e) {
      throw Exception('Unable to save ad data: $e');
    }
  }
}
