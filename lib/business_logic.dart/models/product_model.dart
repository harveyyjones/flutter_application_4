import 'dart:ffi';

class Product {
  final int id;
  final String image;
  final String name;
  final String barcode;
  final String price;
   var qty;

  Product({
    required this.id,
    required this.image,
    required this.name,
    required this.barcode,
    required this.price,
    required this.qty,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      barcode: json['barcode'],
      price: json['price'],
      qty: json['qty'],
    );
  }
}

class CartItem {
  final String barcode;
  final String name;
  final String image;
  var  quantity; // Add this line
  bool isApproved;

  CartItem({
    required this.barcode,
    required this.name,
    required this.image,
    required this.quantity, // Add this line with a default value
    this.isApproved = false,
  });

  CartItem.fromProduct({
    required Product product,
  }) : barcode = product.barcode,
       name = product.name,
       image = product.image,
       quantity = product.qty,
       isApproved = false;

  // Convert CartItem to a Map
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'image': image,
      'quantity': quantity,
      'isApproved': isApproved,
    };
  }

  // Create a copy of CartItem with optional parameter updates
  CartItem copyWith({
    String? barcode,
    String? name,
    String? image,
    var quantity,
    bool? isApproved,
  }) {
    return CartItem(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  // Override toString for easier debugging
  @override
  String toString() {
    return 'CartItem(barcode: $barcode, name: $name, quantity: $quantity, isApproved: $isApproved)';
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.barcode == barcode &&
        other.name == name &&
        other.image == image &&
        other.quantity == quantity &&
        other.isApproved == isApproved;
  }

  // Override hashCode
  @override
  int get hashCode => barcode.hashCode ^ name.hashCode ^ image.hashCode ^ quantity.hashCode ^ isApproved.hashCode;

  CartItem.fromCartItem({
    required CartItem cartItem,
    required this.isApproved,
  }) : 
    barcode = cartItem.barcode,
    name = cartItem.name,
    image = cartItem.image,
    quantity = cartItem.quantity;
}
