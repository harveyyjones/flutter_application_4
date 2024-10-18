import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models%20baselinker/order_details_baselinker_model.dart';
import 'package:flutter_application_4/business_logic.dart/models%20baselinker/orders_model_baselinker.dart';
import 'package:flutter_application_4/business_logic.dart/services%20for%20baselinker/bs_service_order_details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_4/business_logic.dart/services/auth_service.dart';

class BaselinkerOrderDetailsScreen extends StatefulWidget {
  final BaselinkerOrder order;

  const BaselinkerOrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _BaselinkerOrderDetailsScreenState createState() => _BaselinkerOrderDetailsScreenState();
}

class _BaselinkerOrderDetailsScreenState extends State<BaselinkerOrderDetailsScreen> {
  final BaselinkerOrderDetailsService _orderService = BaselinkerOrderDetailsService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  BaselinkerOrderDetails? _orderDetails;
  List<BasketItem> _products = [];
  XFile? _imageFile;
  late int _selectedOrderStatus;
  String? _userId;
  Map<String, int> _productCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    _getUserId();
  }

  Future<void> _getUserId() async {
    try {
      final user = await _authService.getUser();
      setState(() {
        _userId = user?.id.toString();
      });
    } catch (e) {
      print('Error getting user ID: $e');
    }
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final details = await _orderService.fetchOrderDetails(widget.order.id);
      setState(() {
        _orderDetails = details;
        _products = details.baskets;
        _selectedOrderStatus = details.orderStatus;
        _isLoading = false;
        _updateProductCounts();
      });
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order details: $e')),
      );
    }
  }

  void _updateProductCounts() {
    _productCounts.clear();
    List<String> checkStrings = [
      'do domu', 'perfumy', 'zapach do auta', 'balsam do Ciała',
      '500 ml', 'zawieszka', 'diamond', 'damski żel pod prysznic',
    ];

    for (var item in _products) {
      String itemName = item.name.toLowerCase();
      for (var checkString in checkStrings) {
        if (itemName.contains(checkString.toLowerCase())) {
          _productCounts[checkString] = (_productCounts[checkString] ?? 0) + int.parse(item.qty);
          break;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image captured successfully')),
      );
    }
  }

  Future<void> _updateOrder() async {
    // Your existing _updateOrder method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Sipariş Detayları", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orderDetails == null
              ? Center(child: Text('Failed to load order details', style: TextStyle(color: Colors.white)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Order ID: ${_orderDetails!.id}', style: TextStyle(color: Colors.white)),
                    Text('Customer: ${_orderDetails!.musteriAdi}', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    ..._products.map((product) {
                      return Card(
                        color: Colors.grey[850],
                        child: ListTile(
                          leading: Image.network(product.image, width: 50, height: 50),
                          title: Text(product.name, style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                            "Quantity: ${product.qty}\nPrice: ${product.salePrice}",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Text('Order Status: ${verbaliseStatus(_selectedOrderStatus)}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: _selectedOrderStatus,
                      items: [0, 1, 2, 3, 4].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(verbaliseStatus(value), style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedOrderStatus = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(_imageFile == null ? "Take Photo" : "Retake Photo"),
                    ),
                    if (_imageFile != null)
                      Image.file(File(_imageFile!.path)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateOrder,
                      child: Text("Update Order"),
                    ),
                  ],
                ),
    );
  }

  String verbaliseStatus(int status) {
    switch (status) {
      case 0: return 'Onay Bekliyor';
      case 1: return 'Siparişi Hazırlayınız';
      case 2: return 'Depoda Hazırlanıyor';
      case 3: return 'Tamamlandı';
      case 4: return 'İptal Edildi';
      default: return 'Bilinmeyen Durum';
    }
  }
}