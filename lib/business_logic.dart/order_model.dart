import 'dart:convert';
import 'service_for_orders.dart';

class CartItem {
  final int id;
  final String image;
  final String name;
  final String barcode;
  final String price;
  final String qty;
  bool isApproved = false;  // Add this field

  CartItem({
    required this.id,
    required this.image,
    required this.name,
    required this.barcode,
    required this.price,
    required this.qty,
    this.isApproved = false,  // Initialize with default value
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      barcode: json['barcode'],
      price: json['price'],
      qty: json['qty'],
      isApproved: json['isApproved'] ?? false,  // Handle the field if present in JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'barcode': barcode,
      'price': price,
      'qty': qty,
      'isApproved': isApproved,  // Add the field to JSON serialization
    };
  }
}


class Order {
  final int id;
  final List<CartItem> cart;
  final int sipDurum;
  final int odemDurum;
  final int stokDurum;
  final int currentId;
  final int userId;
  final int totalPrice;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final String orderUser;
  final dynamic depoUserId;
  final dynamic deletedAt;

  Order({
    required this.id,
    required this.cart,
    required this.sipDurum,
    required this.odemDurum,
    required this.stokDurum,
    required this.currentId,
    required this.userId,
    required this.totalPrice,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.orderUser,
    this.depoUserId,
    this.deletedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<CartItem> cartItems = [];
    if (json['cart'] is String) {
      cartItems = (jsonDecode(json['cart']) as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    } else if (json['cart'] is List) {
      cartItems = (json['cart'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'],
      cart: cartItems,
      sipDurum: json['sip_durum'],
      odemDurum: json['odem_durum'],
      stokDurum: json['stok_durum'],
      currentId: json['current_id'],
      userId: json['user_id'],
      totalPrice: json['total_price'],
      note: json['note'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      orderUser: json['order_user'],
      depoUserId: json['depo_user_id'],
      deletedAt: json['deleted_at'],
    );
  }

  // Add a method to convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart': jsonEncode(cart.map((item) => item.toJson()).toList()),
      'sip_durum': sipDurum,
      'odem_durum': odemDurum,
      'stok_durum': stokDurum,
      'current_id': currentId,
      'user_id': userId,
      'total_price': totalPrice,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_user': orderUser,
      'depo_user_id': depoUserId,
      'deleted_at': deletedAt,
    };
  }
}

// Add a method to fetch orders using the OrderService
Future<List<Order>> fetchOrders() async {
  final orderService = OrderService();
  return await orderService.fetchOrders();
}
