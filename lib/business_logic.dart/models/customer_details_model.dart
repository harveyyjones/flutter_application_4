// TODO: This part is not dead neccesary.

import 'dart:convert';

class CustomerDetailsModel {
  final String orderId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String orderStatus;
  final double orderTotal;
  final List<CartItem> cart;

  CustomerDetailsModel({
    String? orderId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? orderStatus,
    double? orderTotal,
    List<CartItem>? cart,
  }) : 
    orderId = orderId ?? 'Unknown',
    customerName = customerName ?? 'Anonymous',
    customerEmail = customerEmail ?? 'No email provided',
    customerPhone = customerPhone ?? 'No phone provided',
    orderStatus = orderStatus ?? 'Pending',
    orderTotal = orderTotal ?? 0.0,
    cart = cart ?? [];

  factory CustomerDetailsModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return CustomerDetailsModel(
      orderId: json['orderId'] as String?,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      orderStatus: json['orderStatus'] as String?,
      orderTotal: (json['orderTotal'] as num?)?.toDouble(),
      cart: (json['cart'] as String?)?.isNotEmpty == true
          ? (jsonDecode(json['cart']) as List)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'orderStatus': orderStatus,
      'orderTotal': orderTotal,
      'cart': jsonEncode(cart.map((item) => item.toJson()).toList()),
    };
  }
}

class CartItem {
  final int id;
  final String image;
  final String categoryName;
  final String name;
  final String barcode;
  final String price;
  final String qty;
  final String max;

  CartItem({
    required this.id,
    required this.image,
    required this.categoryName,
    required this.name,
    required this.barcode,
    required this.price,
    required this.qty,
    required this.max,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      image: json['image'] as String,
      categoryName: json['category_name'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String,
      price: json['price'] as String,
      qty: json['qty'] as String,
      max: json['max'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'category_name': categoryName,
      'name': name,
      'barcode': barcode,
      'price': price,
      'qty': qty,
      'max': max,
    };
  }
}
