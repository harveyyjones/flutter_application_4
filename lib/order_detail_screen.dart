import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart';
import 'package:flutter_application_4/business_logic.dart/models/product_model.dart' as product;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_4/business_logic.dart/models/order_model.dart' as order;
import 'package:flutter_application_4/business_logic.dart/printer_connection.dart'; // Add this import

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  OrderDetailsScreen({required this.order});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<order.CartItem> _products = [];
  XFile? _imageFile;
  String _selectedNumber = '1'; // Add this line

  @override
  void initState() {
    super.initState();
    _products = widget.order.cart;
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
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // Future<void> _showCustomerDetails() async {
  //   try {
  //     final orderDetails = await _customerDetailsService.fetchCustomerDetails(widget.order.id.toString());
      
  //     if (!mounted) return;

  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text("Customer Details"),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Order ID: ${orderDetails.orderId}"),
  //               Text("Name: ${orderDetails.customerName}"),
  //               Text("Email: ${orderDetails.customerEmail}"),
  //               Text("Phone: ${orderDetails.customerPhone}"),
  //               Text("Order Status: ${orderDetails.orderStatus}"),
  //               Text("Order Total: \$${orderDetails.orderTotal.toStringAsFixed(2)}"),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               child: const Text("Close"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error fetching customer details: $e")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Group products by their barcode and calculate quantities
    Map<String, product.CartItem> groupedProducts = {};
    for (var item in _products) {
      if (groupedProducts.containsKey(item.barcode)) {
        groupedProducts[item.barcode]!.quantity += item.qty; // Update this line
      } else {
        groupedProducts[item.barcode] = product.CartItem(
          barcode: item.barcode,
          name: item.name,
          image: item.image,
          quantity: item.qty, // Update this line
          isApproved: item.isApproved,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: ListView(
        children: [
          ...groupedProducts.values.map((product) {
            return ListTile(
              leading: SizedBox(
                width: 50,  // Adjust the width as needed
                height: 50, // Adjust the height as needed
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover, // Ensure the image covers the box
                ),
              ),
              title: Text(product.name),
              subtitle: Text("Barcode: ${product.barcode}\nQuantity: ${product.quantity}"), // Update this line
              tileColor: product.isApproved ? Colors.green.withOpacity(0.3) : null, // Highlight approved items
              trailing: product.isApproved
                  ? null
                  : ElevatedButton(
                      onPressed: () => _scanBarcode(product),
                      child: const Text("Scan"),
                    ),
            );
          }).toList(),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: _selectedNumber,
            onChanged: (String? newValue) {
              setState(() {
                _selectedNumber = newValue!;
              });
            },
            items: <String>['1', '2', '3']
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Send Picture"),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.file(File(_imageFile!.path)),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => YourExistingWidget()),
              );
            },
            child: const Text("Select Printer"),
          ),
        ],
      ),
    );
  }
}
