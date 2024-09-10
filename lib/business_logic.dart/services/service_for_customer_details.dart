// TODO: Fix the issue with the cart not being displayed
// TODO: This part is not dead neccesary.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_details_model.dart';

class CustomerDetailsService {
  final String _baseUrl = 'https://gardeniakosmetyka.com/api/v1';

  Future<CustomerDetailsModel> fetchCustomerDetails(String orderId) async {
    print('Fetching customer details for order ID: $orderId');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        print('Error: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      print('Making API request to: $_baseUrl/order/getOrder/$orderId');
      final response = await http.get(
        Uri.parse('$_baseUrl/order/getOrder/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Assuming the API returns cart as a list of objects, not a string
        if (jsonResponse['cart'] is List) {
          jsonResponse['cart'] = json.encode(jsonResponse['cart']);
        }
        print('Successfully parsed JSON response');
        return CustomerDetailsModel.fromJson(jsonResponse);
      } else {
        print('Error: Failed to load customer details. Status code: ${response.statusCode}');
        throw Exception('Failed to load customer details');
      }
    } catch (e) {
      print('Error occurred while fetching customer details: $e');
      rethrow;
    }
  }
}
