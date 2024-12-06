import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models%20baselinker/order_details_baselinker_model.dart';
import 'package:flutter_application_4/business_logic.dart/models%20baselinker/orders_model_baselinker.dart';
import 'package:flutter_application_4/business_logic.dart/services%20for%20baselinker/bs_service_order_details.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_4/business_logic.dart/services/auth_service.dart';

class ProductCategory {
  final String categoryName;
  final List<BasketItem> products;
  final int totalQuantity;

  ProductCategory({
    required this.categoryName,
    required this.products,
    required this.totalQuantity,
  });
}

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
  List<BaselinkerBasketItem> _products = [];
  XFile? _imageFile;
  int _selectedOrderStatus = 0;
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
      final details = await orderService.fetchOrderDetails(widget.order.id);
      if (details != null) {
        setState(() {
          _orderDetails = details;
          _selectedOrderStatus = details.orderStatus;
          _products = details.baskets.cast<BaselinkerBasketItem>();
          _updateProductCountsForbaselinker(details.baskets);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load order details: $e')),
        );
      }
    }
  }

  void _updateProductCountsForbaselinker(List<BasketItem> orderDetails) {
    _productCounts.clear();
    
    for (var item in orderDetails) {
      String category = item.categoryName;
      _productCounts[category] = (_productCounts[category] ?? 0) + (item.qty as int);
    }
    
    var sortedEntries = _productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _productCounts.clear();
    for (var entry in sortedEntries) {
      _productCounts[entry.key] = entry.value;
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

  List<ProductCategory> _getOrganizedProducts() {
    Map<String, List<BasketItem>> categories = {};
    
    for (var product in _orderDetails?.baskets ?? []) {
      String category = product.categoryName;
      
      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(product);
    }

    List<ProductCategory> organizedProducts = categories.entries.map((entry) {
      int totalQuantity = entry.value.fold(0, 
        (sum, product) => sum + (int.tryParse(product.qty.toString()) ?? 0));
      
      List<BasketItem> sortedProducts = List.from(entry.value)
        ..sort((a, b) => (int.tryParse(b.qty.toString()) ?? 0)
            .compareTo(int.tryParse(a.qty.toString()) ?? 0));
      
      return ProductCategory(
        categoryName: entry.key,
        products: sortedProducts,
        totalQuantity: totalQuantity,
      );
    }).toList();

    organizedProducts.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    return organizedProducts;
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
                    const SizedBox(height: 16),
                    
                    ..._getOrganizedProducts().map((category) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Total: ${category.totalQuantity}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Products in this category
                        ...category.products.map((product) => Card(
                          color: product.isScanned ? Colors.green : Colors.grey[900],
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            // leading: _buildImageWithLoader(product.image),
                            title: Text(product.name, style: TextStyle(color: Colors.white)),
                            subtitle: Text('Quantity: ${product.qty}', 
                                         style: TextStyle(color: Colors.white70)),
                            trailing: product.isScanned 
                              ? SizedBox() 
                              : ElevatedButton(
                                  onPressed: () => _scanBarcode(product),
                                  child: Text('Scan', 
                                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                                ),
                          ),
                        )).toList(),
                        const SizedBox(height: 8),
                      ],
                    )).toList(),

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
                            const Text('Product Counts:', 
                                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._productCounts.entries.map((entry) => 
                              Text('${entry.key}: ${entry.value}', 
                                   style: const TextStyle(color: Colors.white70))
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
