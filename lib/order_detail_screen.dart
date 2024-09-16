import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:flutter_application_4/business_logic.dart/models/product_model.dart' as product;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart' as order;
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
  List<order.CartItem> _products = [];
  XFile? _imageFile;
  String _selectedNumber = '1'; // Add this line
  late int _selectedOrderStatus;
  String? _userId;
  int valueOfTheCounter = 0;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _products = widget.order.cart;
    _selectedOrderStatus = widget.order.sipDurum;
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
      // Handle the error, maybe show a snackbar to the user
    }
  }

  Future<void> _scanBarcode(product.CartItem tappedProduct) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes == tappedProduct.barcode) {
      setState(() {
        tappedProduct.isApproved = true;  // Update the property
      });
    } else {
      _showMismatchDialog(tappedProduct );
    }
  }

  void _showMismatchDialog(product.CartItem tappedProduct) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Barcode Mismatch"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(tappedProduct.image),
              Text("Expected: ${tappedProduct.name}"),
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
        SnackBar(content: Text('Image captured successfully')),
      );
    } else {
      print('No image selected.');
    }
  }

  Future<void> _updateOrder() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take a picture first.')),
      );
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

    // Enhanced logging
    print('Sending request to: $url');
    print('Headers:');
    request.headers.forEach((key, value) => print('$key: $value'));
    print('Fields:');
    request.fields.forEach((key, value) => print('$key: $value'));
    print('Files:');
    for (var file in request.files) {
      print('${file.field}: ${file.filename}');
    }

    try {
      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (mounted) {  // Add this check
        if (response.statusCode == 200) {
          print('Order updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sipariş başarıyla güncellendi.')),
          );
        } else {
          print('Failed to update order. Status code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update order. Please try again later.')),
          );
        }
      }
      client.close();
    } catch (e) {
      print('Error updating order: $e');
      if (mounted) {  // Add this check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while updating the order. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group products by their barcode and calculate quantities
    Map<String, product.CartItem> groupedProducts = {};
    for (var item in _products) {
      if (groupedProducts.containsKey(item.barcode)) {
        groupedProducts[item.barcode]!.quantity += item.qty;
      } else {
        groupedProducts[item.barcode] = product.CartItem(
          barcode: item.barcode,
          name: item.name,
          image: item.image,
          quantity: item.qty,
          isApproved: item.isApproved,
          max: item.max,
        );
      }
    }

    bool allScanned = groupedProducts.values.every((product) => product.isApproved);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: ListView(
        children: [
          ...groupedProducts.values.map((product) {
            return Column(
              children: [
                ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    "Barcode: ${product.barcode}\n"
                    "Quantity: ${product.quantity}\n"
                    "Max Stock: ${product.max}",
                  ),
                  tileColor: product.isApproved ? Colors.green.withOpacity(0.3) : null,
                  trailing: product.isApproved
                      ? null
                      : ElevatedButton(
                          onPressed: () => _scanBarcode(product),
                          child: const Text("Scan"),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (product.quantity > 0) valueOfTheCounter--;
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('-'),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: valueOfTheCounter.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null) {
                              setState(() {
                                valueOfTheCounter= newValue.clamp(0, product.max);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(),
                          ),
                        )
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (valueOfTheCounter < product.max) valueOfTheCounter++;
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('+'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            );
          }).toList(),
          const SizedBox(height: 20),
         
          const SizedBox(height: 10),
          if (allScanned)
            const Text("All Barcodes Scanned")
          else
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.green),
              ),
              onPressed: _pickImage,
              child: const Text("Take Picture"),
            ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.file(File(_imageFile!.path)),
            ),
          const SizedBox(height: 10),
          Text('Order Status: ${verbaliseStatus(_selectedOrderStatus)}'),
          DropdownButton<int>(
            value: _selectedOrderStatus,
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _selectedOrderStatus = value!;
              });
              // TODO: Implement API call to update order status
            },
            items: const [
              DropdownMenuItem<int>(value: 0, child: Text('Onay Bekliyor')),
              DropdownMenuItem<int>(value: 1, child: Text('Siparişi Hazırlayınız')),
              DropdownMenuItem<int>(value: 2, child: Text('Depoda Hazırlanıyor')),
              DropdownMenuItem<int>(value: 3, child: Text('Tamamlandı')),
              DropdownMenuItem<int>(value: 4, child: Text('Iptal Edildi')),
            ],
          ),
          SizedBox(height: 16),
          Text('Payment Status: ${verbaliseOdemeDurumu(widget.order.odemDurum)}'),
         
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: _updateOrder,
            child: const Text("Update Order"),
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
