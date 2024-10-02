import 'dart:convert';

import 'package:flutter_application_4/business_logic.dart/models/order_details.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServiceForOrderDetails {
    // ... existing code ...

    Future<OrderDetails> getOrder(String orderId) async {
        print('Fetching order details for order ID: $orderId'); // Debug log for order ID
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('auth_token');

        if (token == null) {
            throw Exception('Authentication token not found');
        }

        final response = await http.get(
            Uri.parse('https://gardeniakosmetyka.com/api/v1/order/getOrder/$orderId'),
            headers: {
                'Authorization': 'Bearer $token',
            },
        );

        if (response.statusCode == 200) {
            // Parse the order details from the response
            return OrderDetails.fromJson(jsonDecode(response.body));
        } else {
            print('Failed to load order for order ID: $orderId'); // Debug log for failure
            throw Exception('Failed to load order: ${response.body}'); // Include response body in exception
        }
    }
    // ... existing code ...
}
