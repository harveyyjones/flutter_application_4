import 'dart:convert';


class CartItem {
  final int id;
  final String image;
  final String categoryName;
  final String name;
  final String barcode;
  final String price;
  final String qty;
  final String max;
  bool isApproved = false;

  CartItem({
    required this.id,
    required this.image,
    required this.categoryName,
    required this.name,
    required this.barcode,
    required this.price,
    required this.qty,
    required this.max,
    this.isApproved = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      image: json['image'].toString(),
      categoryName: json['category_name'].toString(),
      name: json['name'].toString(),
      barcode: json['barcode'].toString(),
      price: json['price'].toString(),
      qty: json['qty'].toString(),
      max: json['max'].toString(),
      isApproved: json['isApproved'] as bool? ?? false,
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
      'isApproved': isApproved,
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

// Modify the fetchOrders function
Future<List<Order>> fetchOrders() async {
  try {
    final orders = await fetchOrders();
    // Convert the returned orders to the correct type if necessary
    return orders.map((order) => Order.fromJson(order.toJson())).toList();
  } catch (e) {
    print('Error fetching orders: $e');
    rethrow;
  }
}
