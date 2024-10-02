// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/product_model.dart';


// // Service to use when matching the order and scanned products. Different purpose from the order fetching.
// Future<List<Product>> fetchProducts() async {
//   final response = await http.get(Uri.parse('https://gardeniakosmetyka.com/api/v1/order/getOrders'));

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     List<Product> products = [];
    
//     for (var item in data) {
//       List<dynamic> cart = json.decode(item['cart']);
//       for (var productData in cart) {
//         products.add(Product.fromJson(productData));
//       }
//     }
//     return products;
//   } else {
//     throw Exception('Failed to load products');
//   }
// }
