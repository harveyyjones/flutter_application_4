import 'dart:convert';

class BaselinkerOrder {
  final int id;
  final String currency;
  final String token;
  final int price;
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
  final String? cargoTutari;

  BaselinkerOrder({
    required this.id,
    required this.currency,
    required this.token,
    required this.price,
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
    this.cargoTutari,
  });

  factory BaselinkerOrder.fromJson(Map<String, dynamic> json) {
    return BaselinkerOrder(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      currency: json['currency'].toString(),
      token: json['token'].toString(),
      price: json['price'] is int ? json['price'] : int.parse(json['price'].toString()),
      paymentId: json['payment_id'].toString(),
      musteriId: json['musteri_id'] is int ? json['musteri_id'] : int.parse(json['musteri_id'].toString()),
      adresId: json['adres_id'] is int ? json['adres_id'] : int.parse(json['adres_id'].toString()),
      basketId: json['basket_id'].toString(),
      baskets: _parseBaskets(json['baskets']),
      orderStatus: json['order_status'] is int ? json['order_status'] : int.parse(json['order_status'].toString()),
      stockStatus: json['stock_status'] is int ? json['stock_status'] : int.parse(json['stock_status'].toString()),
      cargoFirma: json['cargo_firma']?.toString(),
      cargoTakipNo: json['cargo_takip_no']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      depoUserId: json['depo_user_id'] is int ? json['depo_user_id'] : int.parse(json['depo_user_id'].toString()),
      currentId: json['current_id'] is int ? json['current_id'] : int.parse(json['current_id'].toString()),
      notes: json['notes']?.toString(),
      cargoTutari: json['cargo_tutari']?.toString(),
    );
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
  final dynamic salePrice;
  final String image;

  BaselinkerBasketItem({
    required this.id,
    required this.name,
    required this.barcode,
    required this.categoryName,
    required this.qty,
    required this.salePrice,
    required this.image,
  });

  factory BaselinkerBasketItem.fromJson(Map<String, dynamic> json) {
    return BaselinkerBasketItem(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(), // Ensured conversion to String
      barcode: json['barcode'].toString(), // Ensured conversion to String
      categoryName: json['category_name'].toString(), // Ensured conversion to String
      qty: json['qty'].toString(), // Ensured conversion to String
      salePrice: json['sale_price'],
      image: json['image'].toString(), // Ensured conversion to String
    );
  }
}
