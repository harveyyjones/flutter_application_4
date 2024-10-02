import 'dart:convert';

class CartItem {
  final int id;
  final String image;
  final String categoryName;
  final String name;
  final String barcode;
  var quantity;
  final int max;
  bool isApproved;
  final double price;

  CartItem({
    required this.id,
    required this.image,
    required this.categoryName,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.max,
    this.isApproved = false,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      image: json['image'].toString(),
      categoryName: json['category_name'].toString(),
      name: json['name'].toString(),
      barcode: json['barcode'].toString(),
      quantity: int.parse(json['qty'].toString()), // Ensure quantity is an int
      max: int.parse(json['max'].toString()),
      isApproved: json['isApproved'] as bool? ?? false,
      price: double.parse(json['price'].toString()),
    );
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
      userId: json['user_id'],
      totalPrice: json['total_price'],
      note: json['note'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      orderUser: json['order_user'],
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