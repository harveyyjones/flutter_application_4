import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:flutter_application_4/business_logic.dart/services/service_for_orders.dart';
import 'package:flutter_application_4/order_detail_screen.dart';
// Add this import
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Add this import
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final OrderService _orderService = OrderService();

  int? _selectedOrderStatus;
  int? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _orderService.fetchOrders();
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading orders: $e';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        bool matchesOrderStatus = _selectedOrderStatus == null || order.sipDurum == _selectedOrderStatus;
        bool matchesPaymentStatus = _selectedPaymentStatus == null || order.odemDurum == _selectedPaymentStatus;
        return matchesOrderStatus && matchesPaymentStatus;
      }).toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      print('Image picked: ${pickedFile.path}');
      print('Image name: ${pickedFile.name}');
      print('Image size: ${await File(pickedFile.path).length()} bytes');
      
      setState(() {
      });
      await _sendImageToApi(pickedFile);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _sendImageToApi(XFile imageFile) async {
    // Update the URL to remove the trailing slash
    final url = Uri.parse('https://gardeniakosmetyka.com/public/api/v1/image-upload');
    
    final request = http.MultipartRequest('POST', url);

    // Retrieve the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    print('Token: $token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    // Add the authorization token to the request headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add the image file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: imageFile.name,
    ));

    try {
      // Use a regular http client to handle redirects automatically
      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        print('Response: ${response.body}');
        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image. Please try again later.')),
        );
      }
      client.close();
    } catch (e) {
      print('Error uploading image: $e');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while uploading the image. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedOrderStatus,
                        hint: Text('Order Status'),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedOrderStatus = value;
                          });
                        },
                        items: const [
                          DropdownMenuItem<int>(value: null, child: Text('All')),
                          DropdownMenuItem<int>(value: 0, child: Text('Onay Bekliyor')),
                          DropdownMenuItem<int>(value: 1, child: Text('Siparişi Hazırlayınız')),
                          DropdownMenuItem<int>(value: 2, child: Text('Depoda Hazırlanıyor')),
                          DropdownMenuItem<int>(value: 3, child: Text('Tamamlandı')),
                          DropdownMenuItem<int>(value: 4, child: Text('Iptal Edildi')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedPaymentStatus,
                        hint: const Text('Payment Status'),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentStatus = value;
                          });
                        },
                        items: const [
                          DropdownMenuItem<int>(value: null, child: Text('All')),
                          DropdownMenuItem<int>(value: 0, child: Text('Bekliyor')),
                          DropdownMenuItem<int>(value: 1, child: Text('Ödendi')),
                          DropdownMenuItem<int>(value: 2, child: Text('Tamamlandı')),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Send Picture"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Order #${order.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Created at: ${order.createdAt}'),
                        Text('Total Price: ${order.totalPrice}'),
                        Text('Items: ${order.cart.length}'),
                        Text('Odeme durumu: ${verbaliseOdemeDurumu(order.odemDurum)}'),
                        Text('Order User ${order.orderUser}'),
                        Text('Siparis Durumu ${verbaliseStatus(order.sipDurum)}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String verbaliseStatus(int status) {
  switch (status) {
    case 0:
      return 'Onay Bekliyor';
    case 1:
      return 'Siparişi Hazırlayınız';
    case 2:
      return 'Depoda Hazırlanıyor';
    case 3:
      return 'Tamamlandı';
    case 4:
      return 'Iptal Edildi';
    default:
      return 'Bilinmeyen Durum';
  }
}

String verbaliseOdemeDurumu(int status) {
  switch (status) {
    case 0:
      return 'Bekliyor';
    case 1:
      return 'Ödendi';
    case 2:
      return 'Tamamlandı';
    default:
      return 'Bilinmeyen Durum';
  }
}