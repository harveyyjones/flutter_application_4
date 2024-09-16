import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/product_model.dart' as product;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_4/business_logic.dart/services/auth_service.dart';

import 'business_logic.dart/models/order_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isAllScanned = false;
  List<product.CartItem> _products = [];
  XFile? _imageFile;
  String _selectedNumber = '1';
  late int _selectedOrderStatus;
  String? _userId;
  List<String> _scannedBarcodes = [];
  Map<String, int> _productCounters = {};
  Map<String, TextEditingController> _controllers = {};

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _products = widget.order.cart.map((item) => product.CartItem(
      name: item.name,
      barcode: item.barcode,
      image: item.image,
      isApproved: item.isApproved,
      quantity: item.qty,
      price: item.price ?? 0.0, // Use 0.0 as default if price is null
      maxQuantity: item.max,
    )).toList();
    _selectedOrderStatus = widget.order.sipDurum;
    _getUserId();
    for (var product in _products) {
      _controllers[product.barcode] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
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
      'İptal',
      true,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes != '-1') {
      setState(() {
        _scannedBarcodes.add(barcodeScanRes);
      });

      if (barcodeScanRes == tappedProduct.barcode) {
        setState(() {
          tappedProduct.isApproved = true;
        });
      } else {
        _showMismatchDialog(tappedProduct);
      }
    }
  }

  void _showMismatchDialog(product.CartItem tappedProduct) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Barkod Uyuşmazlığı"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(tappedProduct.image),
              Text("Beklenen: ${tappedProduct.name}"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Tamam"),
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
        SnackBar(content: Text('Fotoğraf başarıyla yakalandı')),
      );
    } else {
      print('No image selected.');
    }
  }

  Future<void> _updateOrder() async {
    if (!_allProductsScanned()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen siparişi güncellemeden önce tüm ürünleri tarayın.')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen önce bir fotoğraf çekin.')),
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

      if (response.statusCode == 200) {
        print('Sipariş başarıyla güncellendi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş başarıyla güncellendi.')),
        );
      } else {
        print('Sipariş güncellenemedi. Durum kodu: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş güncellenemedi. Lütfen daha sonra tekrar deneyin.')),
        );
      }
      client.close();
    } catch (e) {
      print('Sipariş güncellenirken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş güncellenirken bir hata oluştu. Lütfen tekrar deneyin.')),
      );
    }
  }

  bool _allProductsScanned() {
    return _products.every((product) => product.isApproved);
  }

  void _showCustomerDetails() {
    print('Bayi Adı: ${widget.order.bayiAdi}');
    print('Sipariş Veren: ${widget.order.siparis_veren}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Müşteri Detayları"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bayi Adı: ${widget.order.bayiAdi}"),
              Text("Sipariş Veren: ${widget.order.siparis_veren}"),
              // For example:
              // Text("Adres: ${widget.order.address}"),
              // Text("Telefon: ${widget.order.phone}"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Kapat"),
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
    // Group products by their barcode and calculate quantities
    Map<String, product.CartItem> groupedProducts = {};
    for (var item in _products) {
      if (groupedProducts.containsKey(item.barcode)) {
        groupedProducts[item.barcode]!.quantity += item.quantity;
      } else {
        groupedProducts[item.barcode] = item;
      }
    }

    bool allScanned = groupedProducts.values.every((product) => product.isApproved);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sipariş Detayları"),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showCustomerDetails,
          ),
        ],
      ),
      body: ListView(
        children: [
          ...groupedProducts.values.map((product) {
            return ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 50);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Barkod: ${product.barcode}"),
                  Text("Miktar: ${product.quantity}"),
                  Text("Fiyat: \PLN ${product.price.toStringAsFixed(2)}"),
                  if (product.maxQuantity != null)
                    Text("Maksimum Miktar: ${product.maxQuantity}"),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _productCounters[product.barcode] = (_productCounters[product.barcode] ?? 0) - 1;
                            _controllers[product.barcode]!.text = _productCounters[product.barcode].toString();
                          });
                        },
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: _controllers[product.barcode],
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null) {
                              setState(() {
                                _productCounters[product.barcode] = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _productCounters[product.barcode] = (_productCounters[product.barcode] ?? 0) + 1;
                            _controllers[product.barcode]!.text = _productCounters[product.barcode].toString();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              tileColor: product.isApproved ? Colors.green.withOpacity(0.3) : null,
              trailing: product.isApproved
                  ? null
                  : ElevatedButton(
                      onPressed: () => _scanBarcode(product),
                      child: const Text("Tara"),
                    ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Text('Taranan Barkodlar:'),
          Column(
            children: _scannedBarcodes.map((barcode) => Text(barcode)).toList(),
          ),
          const SizedBox(height: 10),
          if (allScanned)
            const Text("Tüm Barkodlar Tarandı")
          else
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.green),
              ),
              onPressed: _pickImage,
              child: const Text("Fotoğraf Çek"),
            ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.file(File(_imageFile!.path)),
            ),
          const SizedBox(height: 10),
          Text('Sipariş Durumu: ${verbaliseStatus(_selectedOrderStatus)}'),
          DropdownButton<int>(
            value: _selectedOrderStatus,
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _selectedOrderStatus = value!;
              });
            },
            items: const [
              DropdownMenuItem<int>(value: 0, child: Text('Onay Bekliyor')),
              DropdownMenuItem<int>(value: 1, child: Text('Siparişi Hazırlayınız')),
              DropdownMenuItem<int>(value: 2, child: Text('Depoda Hazırlanıyor')),
            ],
          ),
          SizedBox(height: 16),
          Text('Ödeme Durumu: ${verbaliseOdemeDurumu(widget.order.odemDurum)}'),
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: _allProductsScanned() ? _updateOrder : null,
            child: Text(_allProductsScanned() ? "Siparişi Güncelle" : "Önce Tüm Ürünleri Tarayın"),
          ),
          ElevatedButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: _showCustomerDetails,
            child: const Text("Müşteri Detaylarını Görüntüle"),
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
      return 'İptal Edildi';
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
    default:
      return 'Bilinmeyen Durum';
  }
      return 'Ödendi';
  }