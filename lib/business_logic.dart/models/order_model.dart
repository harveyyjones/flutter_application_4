import 'dart:convert';

class CartItem {
  final int id;
  final String image;
  final String categoryName;
  final String name;
  final String barcode;
  final int? quantity; // Changed to nullable type
  final int max;
  bool isApproved;
  final double? price; // Changed to nullable type

  CartItem({
    required this.id,
    required this.image,
    required this.categoryName,
    required this.name,
    required this.barcode,
    this.quantity, // Made optional
    required this.max,
    this.isApproved = false,
    this.price, // Made optional
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      return CartItem(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0, // Default to 0
        image: json['image']?.toString() ?? '', // Default to empty string
        categoryName: json['category_name']?.toString() ?? '', // Default to empty string
        name: json['name']?.toString() ?? '', // Default to empty string
        barcode: json['barcode']?.toString() ?? '', // Default to empty string
        quantity: json['qty'] != null ? int.tryParse(json['qty'].toString()) : null, // Nullable
        max: int.tryParse(json['max'].toString()) ?? 0, // Default to 0
        isApproved: json['isApproved'] as bool? ?? false,
        price: json['price'] != null ? double.tryParse(json['price'].toString()) : null, // Nullable
      );
    } catch (e) {
      print('Error parsing CartItem: $e, json: $json');
      rethrow; // Rethrow the error after logging
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'category_name': categoryName,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'max': max,
      'isApproved': isApproved,
      'price': price,
    };
  }
}

class Order {
  final int id;
  final List<CartItem> cart;
  final int sipDurum;
  final int odemDurum;
  final int stokDurum;
  final int userId;
  final int totalPrice;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final String orderUser;

  Order({
    required this.id,
    required this.cart,
    required this.sipDurum,
    required this.odemDurum,
    required this.stokDurum,
    required this.userId,
    required this.totalPrice,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.orderUser,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<CartItem> cartItems = [];
    try {
      if (json['cart'] is String) {
        cartItems = (jsonDecode(json['cart']) as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      } else if (json['cart'] is List) {
        cartItems = (json['cart'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error parsing Order cart: $e, json: $json');
      rethrow; // Rethrow the error after logging
    }

    return Order(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0, // Default to 0
      cart: cartItems,
      sipDurum: json['sip_durum'] is int ? json['sip_durum'] : int.tryParse(json['sip_durum'].toString()) ?? 0, // Default to 0
      odemDurum: json['odem_durum'] is int ? json['odem_durum'] : int.tryParse(json['odem_durum'].toString()) ?? 0, // Default to 0
      stokDurum: json['stok_durum'] is int ? json['stok_durum'] : int.tryParse(json['stok_durum'].toString()) ?? 0, // Default to 0
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0, // Default to 0
      totalPrice: json['total_price'] is int ? json['total_price'] : int.tryParse(json['total_price'].toString()) ?? 0, // Default to 0
      note: json['note']?.toString(), // Nullable
      createdAt: json['created_at']?.toString() ?? '', // Default to empty string
      updatedAt: json['updated_at']?.toString() ?? '', // Default to empty string
      orderUser: json['order_user']?.toString() ?? '', // Default to empty string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart': jsonEncode(cart.map((item) => item.toJson()).toList()),
      'sip_durum': sipDurum,
      'odem_durum': odemDurum,
      'stok_durum': stokDurum,
      'user_id': userId,
      'total_price': totalPrice,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_user': orderUser,
    };
  }
}
