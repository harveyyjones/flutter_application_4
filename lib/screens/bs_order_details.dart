import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models%20baselinker/order_details_baselinker_model.dart';
import 'package:flutter_application_4/business_logic.dart/models%20baselinker/orders_model_baselinker.dart';
import 'package:flutter_application_4/business_logic.dart/services%20for%20baselinker/bs_service_order_details.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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
  late BaselinkerOrderDetails? _orderDetails; // Change to nullable
  List<BaselinkerBasketItem> _products = [];
  XFile? _imageFile;
  late int _selectedOrderStatus = _orderDetails?.orderStatus ?? 0; // Use null-aware operator
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
      final orderService = BaselinkerOrderDetailsService();
      _orderDetails = await orderService.fetchOrderDetails(widget.order.id);
      if (_orderDetails != null) {
        _products = _orderDetails!.baskets.cast<BaselinkerBasketItem>(); // Cast to the correct type
        _updateProductCountsForbaselinker(_orderDetails!.baskets); // Update product counts after fetching order details
      }
      setState(() {
        _isLoading = false;
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

  void _updateProductCountsForbaselinker(List<BasketItem> orderDetails) {
    _productCounts.clear();
    List<String> checkStrings = [
      'do domu',
      'perfumy',
      'zapach do auta',
      'balsam do Ciała',
      '500 ml',
      'zawieszka',
      'diamond',
      'damski żel pod prysznic',
    ];

    for (var item in orderDetails) { // Iterate over orderDetails instead of _products
      String itemName = item.name.toLowerCase();
      for (var checkString in checkStrings) {
        if (itemName.contains(checkString.toLowerCase())) {
          _productCounts[checkString] = (_productCounts[checkString] ?? 0) + (item.qty as int);
          break; // Count each item only once
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

  Future<void> _scanBarcode(BasketItem product) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes != '-1') {
      setState(() {
        try {
          if (barcodeScanRes == product.barcode) {
            product.isScanned = true;
          } else {
            _showMismatchDialog(product, barcodeScanRes);
          }
        } catch (e) {
          print('Error updating product state: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      });
    }
  }

  void _showMismatchDialog(BasketItem product, String scannedBarcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Barcode Mismatch"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Expected: ${product.name}", style: TextStyle(fontSize: 20),),
              Image.network(product.image, width: MediaQuery.of(context).size.width * 0.6, height: MediaQuery.of(context).size.height * 0.6),
              Text("Scanned: $scannedBarcode", style: TextStyle(fontSize: 20),),
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                    Text('Order ID: ${_orderDetails!.id}', style: TextStyle(color: Colors.white)), // Use null-aware operator
                    Text('Customer: ${_orderDetails!.musteriAdi}', style: TextStyle(color: Colors.white)), // Updated to ensure text is white
                    ..._orderDetails!.baskets.map((product) { // Use null-aware operator
                      return Card(
                        color: product.isScanned ? Colors.green : Colors.grey[900],
                        child: ListTile(
                          leading: _buildImageWithLoader(product.image), // Updated to use image loader
                          title: Text(product.name, style: TextStyle(color: Colors.white)),
                          subtitle: Text('Quantity: ${product.qty}', style: TextStyle(color: Colors.white)),
                          trailing: product.isScanned ? SizedBox() : ElevatedButton(
                            onPressed: () => _scanBarcode(product),
                            child: Text('Scan', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                          ) 
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Text('Order Status: ${verbaliseStatus(_selectedOrderStatus)}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Card(
                      color: Colors.grey[850],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Product Counts:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._productCounts.entries.map((entry) => 
                              Text('${entry.key}: ${entry.value}', style: const TextStyle(color: Colors.white70))
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildImageWithLoader(String imageUrl) {
    return FutureBuilder(
      future: precacheImage(NetworkImage(imageUrl), context), // Precache the image
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Image.network(
            imageUrl,
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              // Display a placeholder image or an error message
              return Icon(Icons.error, color: Colors.red, size: 50);
            },
          );
        } else {
          return CircularProgressIndicator(); // Show loading indicator while image is loading
        }
      },
    );
  }

  String verbaliseStatus(int status) {
    switch (status) {
      case 0: return 'Onay Bekliyor';
      case 1: return 'Siparişi Hazırlayınız';
      case 2: return 'Kargoya Verilecek';
      case 3: return 'Kargoya Verildi';
      case 4: return 'Tamamlandı';
      case 5: return 'Müşteri Alacak';
      case 6: return 'Müşteri Teslim Aldı';
      case 7: return 'Ödeme Bekleniyor';
      case -1: return 'Sipariş Iptal';
      default: return 'Bilinmeyen Durum';
    }
  }
}
