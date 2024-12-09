import 'dart:convert';
import 'package:flutter_application_4/business_logic.dart/models%20web/orders_model_web.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WebOrderService {
  static const String _baseUrl =
      'https://gardeniakosmetyka.com/api/v1/corder/getCorders';

  Future<List<WebOrder>> fetchOrders() async {
    try {
      final token = await _getAuthToken();
      final response = await _makeAuthenticatedRequest(token);
      print('Raw response: ${response.body}'); // Debug print
      return _parseOrdersResponse(response);
    } catch (e) {
      print('Error in fetchOrders: $e'); // Debug print
      throw Exception('Failed to fetch orders: ${e.toString()}');
    }
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Future<http.Response> _makeAuthenticatedRequest(String token) async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Server returned status code ${response.statusCode}');
    }

    return response;
  }

  List<WebOrder> _parseOrdersResponse(http.Response response) {
    try {
      final List<dynamic> jsonResponse = json.decode(response.body);
      print('Decoded JSON: $jsonResponse'); // Debug print
      return jsonResponse.map((json) => WebOrder.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing orders: $e'); // Debug print
      throw Exception('Failed to parse orders: ${e.toString()}');
    }
  }

  // ... rest of your service methods ...
}
