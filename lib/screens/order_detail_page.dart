import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_details.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:flutter_application_4/business_logic.dart/services/service_for_order_details.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_4/business_logic.dart/services/auth_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isAllScanned = false;
  List<CartItem> _products = [];
  XFile? _imageFile;
  late int _selectedOrderStatus;
  String? _userId;
  Map<String, int> productCounters = {};
  OrderDetails? _orderDetails; // Add this line to hold order details

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _products = widget.order.cart;
    _selectedOrderStatus = widget.order.sipDurum;
    _getUserId();
     _fetchOrderDetails(); // Fetch order details
    for (var item in _products) {
      productCounters[item.barcode] = item.quantity;
    }
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

  Future<OrderDetails?> _fetchOrderDetails() async {
    try {
      _orderDetails = await ServiceForOrderDetails().getOrder(widget.order.id.toString());
      setState(() {}); // Update UI after fetching order details
    } catch (e) {
      print('Error fetching order details: $e');
    }
    return _orderDetails;
  }

  Future<void> _scanBarcode(CartItem product) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    print('Scanned Barcode: $barcodeScanRes');
    print('Expected Barcode: ${product.barcode}');

    if (barcodeScanRes == product.barcode) {
      setState(() {
        product.isApproved = true;
      });
      print('Barcode matches! Product approved.');
      _displayApprovedProducts();
    } else {
      print('Barcode does not match.');
      _showMismatchDialog(product);
    }
  }

  void _showMismatchDialog(CartItem product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Barcode Mismatch"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(product.image),
              Text("Expected: ${product.name}"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      print('Image picked: ${pickedFile.path}');
      print('Image name: ${pickedFile.name}');
      print('Image size: ${await File(pickedFile.path).length()} bytes');
      
      setState(() {
        _imageFile = pickedFile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image captured successfully')),
      );
    } else {
      print('No image selected.');
    }
  }

  Future<void> _updateOrder() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a picture first.')),
      );
      Navigator.of(context).pop();
      return;
    }

    final url = Uri.parse('https://gardeniakosmetyka.com/api/v1/order/updateOrder');
    final request = http.MultipartRequest('POST', url);

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['user_id'] = _userId ?? '';
    request.fields['status'] = _selectedOrderStatus.toString();
    request.fields['order_id'] = widget.order.id.toString();

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _imageFile!.path,
      filename: _imageFile!.name,
    ));

    try {
      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      Navigator.of(context).pop();

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (mounted) {
        if (response.statusCode == 200) {
          print('Order updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sipariş başarıyla güncellendi.')),
          );
        } else {
          print('Failed to update order. Status code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update order. Please try again later.')),
          );
        }
      }
      client.close();
    } catch (e) {
      Navigator.of(context).pop();
      print('Error updating order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while updating the order. Please try again.')),
        );
      }
    }
  }

  void _displayApprovedProducts() {
    List<CartItem> approvedProducts = _products.where((item) => item.isApproved).toList();
    
    if (approvedProducts.isEmpty) {
      print('No approved products found.');
    } else {
      print('Approved Products: ${approvedProducts.map((p) => p.name).join(', ')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool allScanned = _products.every((product) => product.isApproved);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Sipariş Detayları", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) => snapshot.hasData ? 
         ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Displaiy bayi_adi and shippingImage if available
            if (_orderDetails!.bayiAdi.isNotEmpty) ...[
              Text('Bayi Adı: ${_orderDetails!.bayiAdi}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              if (_orderDetails!.shippingImage!.isNotEmpty && _orderDetails!.shippingImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://gardeniakosmetyka.com/${_orderDetails!.shippingImage!}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              const SizedBox(height: 20),
            ],
            ..._products.map((product) {
              return Card(
                color: Colors.grey[850],
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error, color: Colors.redAccent));
                            },
                          ),
                        ),
                      ),
                      title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "Barcode: ${product.barcode}\nQuantity: ${product.quantity}\nMax Stock: ${product.max}",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      tileColor: product.isApproved ? Colors.greenAccent.withOpacity(0.2) : null,
                      trailing: product.isApproved
                          ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                          : ElevatedButton(
                              onPressed: () => _scanBarcode(product),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.tealAccent,
                              ),
                              child: const Text("Tara"),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue: productCounters[product.barcode].toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                int? newValue = int.tryParse(value);
                                if (newValue != null) {
                                  setState(() {
                                    productCounters[product.barcode] = newValue.clamp(0, product.max);
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            if (allScanned) ...[
              const Text("Tüm Barkodlar Tarandı", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (_imageFile != null)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.tealAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(_imageFile == null ? "Fotoğraf Çek" : "Yeni Fotoğraf Çek"),
              ),
            ],
            const SizedBox(height: 20),
            Text('Sipariş Durumu: ${verbaliseStatus(_selectedOrderStatus)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: _selectedOrderStatus,
                isExpanded: true,
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                onChanged: (value) {
                  setState(() {
                    _selectedOrderStatus = value!;
                  });
                },
                items: const [
                  DropdownMenuItem<int>(value: 0, child: Text('Onay Bekliyor')),
                  DropdownMenuItem<int>(value: 1, child: Text('Siparişi Hazırlayınız')),
                  DropdownMenuItem<int>(value: 2, child: Text('Depoda Hazırlanıyor')),
                  DropdownMenuItem<int>(value: 3, child: Text('Tamamlandı')),
                  DropdownMenuItem<int>(value: 4, child: Text('İptal Edildi')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Ödeme Durumu: ${verbaliseOdemeDurumu(widget.order.odemDurum)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
         
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _updateOrder,
              child: const Text("Siparişi Güncelle", style: TextStyle(fontSize: 16)),
            ),
          ],
        ) : Center(child: CircularProgressIndicator()),
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

String verbaliseOdemeDurumu(int status) {
  switch (status) {
    case 0: return 'Bekliyor';
    case 1: return 'Ödendi';
    case 2: return 'Tamamlandı';
    default: return 'Bilinmeyen Durum';
  }
}}