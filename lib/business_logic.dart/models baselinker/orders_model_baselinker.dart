import 'dart:convert';

class BaselinkerOrder {
  final int id;
  final String currency;
  final String token;
  // final int price;  // Kept as int, but will handle decimal values
  final String paymentId;
  final int musteriId;
  final int adresId;
  final String basketId;
  final List<BaselinkerBasketItem> baskets;
  final int orderStatus;
  final int stockStatus;
  final String? cargoFirma;
  final String? cargoTakipNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int depoUserId;
  final int currentId;
  final String? notes;
  // final String? cargoTutari;

  BaselinkerOrder({
    required this.id,
    required this.currency,
    required this.token,
    // required this.price,
    required this.paymentId,
    required this.musteriId,
    required this.adresId,
    required this.basketId,
    required this.baskets,
    required this.orderStatus,
    required this.stockStatus,
    this.cargoFirma,
    this.cargoTakipNo,
    required this.createdAt,
    required this.updatedAt,
    required this.depoUserId,
    required this.currentId,
    this.notes,
    // this.cargoTutari,
  });

  factory BaselinkerOrder.fromJson(Map<String, dynamic> json) {
    return BaselinkerOrder(
      id: _parseInt(json['id']),
      currency: json['currency']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      // price: _parseInt(json['price']),  // Using modified _parseInt
      paymentId: json['payment_id']?.toString() ?? '',
      musteriId: _parseInt(json['musteri_id']),
      adresId: _parseInt(json['adres_id']),
      basketId: json['basket_id']?.toString() ?? '',
      baskets: _parseBaskets(json['baskets']),
      orderStatus: _parseInt(json['order_status']),
      stockStatus: _parseInt(json['stock_status']),
      cargoFirma: json['cargo_firma']?.toString(),
      cargoTakipNo: json['cargo_takip_no']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
      depoUserId: _parseInt(json['depo_user_id']),
      currentId: _parseInt(json['current_id']),
      notes: json['notes']?.toString(),
      // cargoTutari: json['cargo_tutari']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    
    // If it's already an integer, return it
    if (value is int) return value;
    
    // If it's a double, truncate decimal part
    if (value is double) return value.truncate();
    
    // If it's a string, handle potential decimal values
    if (value is String) {
      // Split by decimal point and take only the integer part
      String integerPart = value.split('.')[0];
      return int.tryParse(integerPart) ?? 0;
    }
    
    return 0;  // Default return if none of the above work
  }

  static List<BaselinkerBasketItem> _parseBaskets(dynamic basketsJson) {
    if (basketsJson is String) {
      List<dynamic> basketsList = jsonDecode(basketsJson);
      return basketsList.map((item) => BaselinkerBasketItem.fromJson(item)).toList();
    } else if (basketsJson is List) {
      return basketsJson.map((item) => BaselinkerBasketItem.fromJson(item)).toList();
    }
    return [];
  }
}

class BaselinkerBasketItem {
  final int id;
  final String name;
  final String barcode;
  final String categoryName;
  final String qty;
  // final dynamic salePrice;
  final String image;

  BaselinkerBasketItem({
    required this.id,
    required this.name,
    required this.barcode,
    required this.categoryName,
    required this.qty,
    // required this.salePrice,
    required this.image,
  });

  factory BaselinkerBasketItem.fromJson(Map<String, dynamic> json) {
    return BaselinkerBasketItem(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(),
      barcode: json['barcode'].toString(),
      categoryName: json['category_name'].toString(),
      qty: json['qty'].toString(),
      // salePrice: json['sale_price'],
      image: json['image'].toString(),
    );
  }
}