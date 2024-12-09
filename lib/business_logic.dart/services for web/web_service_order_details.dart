import 'dart:convert';
import 'package:flutter_application_4/business_logic.dart/models%20web/order_details_web_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WebOrderDetailsService {
  static const String _baseUrl =
      'https://gardeniakosmetyka.com/api/v1/corder/getCorder'; // Updated URL

  Future<WebOrderDetails> fetchOrderDetails(int orderId) async {
    try {
      print('Fetching order details for order ID: $orderId'); // Debug print
      final token = await _getAuthToken();
      print('Retrieved auth token: $token'); // Debug print
      final response = await _makeAuthenticatedRequest(token, orderId);
      print(
          'Response status code: ${response.statusCode}'); // Added debug print
      print('Response body: ${response.body}'); // Added debug print
      return _parseOrderResponse(response);
    } catch (e) {
      print('Error in fetchOrderDetails: $e'); // Added error logging
      throw Exception('Failed to fetch order details: ${e.toString()}');
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

  Future<http.Response> _makeAuthenticatedRequest(
      String token, int orderId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$orderId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Server returned status code ${response.statusCode}');
    }

    print('Response status code: ${response.statusCode}'); // Added debug print
    print('Error response body: ${response.body}'); // Added debug print

    return response;
  }

  WebOrderDetails _parseOrderResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(
          'Parsed JSON response: $jsonResponse'); // Added logging for parsed JSON
      return WebOrderDetails.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Failed to parse order details: ${e.toString()}');
    }
  }
}
