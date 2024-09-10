import 'dart:convert';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final String _baseUrl = 'https://gardeniakosmetyka.com/api/v1/order/getOrders';

  Future<List<Order>> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
