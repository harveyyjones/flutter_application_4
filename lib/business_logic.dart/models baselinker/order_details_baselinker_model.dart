import 'dart:convert';

class BaselinkerOrderDetails {
  final int id;
  final String currency;
  final String token;
  final int price;
  final String paymentId;
  final int musteriId;
  final int adresId;
  final String basketId;
  final List<BasketItem> baskets;
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
  final String musteriAdi;
  final String musteriAdres;
  final String depoUserAd;
  final Address adres;

  BaselinkerOrderDetails({
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
    required this.musteriAdi,
    required this.musteriAdres,
    required this.depoUserAd,
    required this.adres,
  });

  factory BaselinkerOrderDetails.fromJson(Map<String, dynamic> json) {
    print('Parsing BaselinkerOrderDetails from JSON: $json'); // Added debug print
    return BaselinkerOrderDetails(
      id: json['id'] ?? 0,
      currency: json['currency'] ?? '',
      token: json['token'] ?? '',
      price: json['price'] ?? 0,
      paymentId: json['payment_id'] ?? '',
      musteriId: json['musteri_id'] ?? 0,
      adresId: json['adres_id'] ?? 0,
      basketId: json['basket_id'] ?? '',
      baskets: _parseBaskets(json['baskets']),
      orderStatus: json['order_status'] ?? 0,
      stockStatus: json['stock_status'] ?? 0,
      cargoFirma: json['cargo_firma'] ?? '',
      cargoTakipNo: json['cargo_takip_no'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      depoUserId: json['depo_user_id'] ?? 0,
      currentId: json['current_id'] ?? 0,
      notes: json['notes'] ?? '',
      cargoTutari: json['cargo_tutari'] ?? '',
      musteriAdi: json['musteri_adi'] ?? '',
      musteriAdres: json['musteri_adres'] ?? '',
      depoUserAd: json['depo_user_ad'] ?? '',
      adres: Address.fromJson(json['adres'] ?? {}),
    );
  }

  static List<BasketItem> _parseBaskets(String basketsJson) {
    List<dynamic> basketsList = jsonDecode(basketsJson);
    return basketsList.map((item) => BasketItem.fromJson(item)).toList();
  }
}

class Address {
  final int id;
  final int musteriId;
  final String name;
  final int tip;
  final String ad;
  final String soyad;
  final String telefon;
  final String sehir;
  final String pKodu;
  final String acikAdres;
  final String ulke;
  final String sokak;
  final String? vNumarasi;
  final String? firmaAdi;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.musteriId,
    required this.name,
    required this.tip,
    required this.ad,
    required this.soyad,
    required this.telefon,
    required this.sehir,
    required this.pKodu,
    required this.acikAdres,
    required this.ulke,
    required this.sokak,
    this.vNumarasi,
    this.firmaAdi,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      musteriId: json['musteri_id'] ?? 0,
      name: json['name'] ?? '',
      tip: json['tip'] ?? 0,
      ad: json['ad'] ?? '',
      soyad: json['soyad'] ?? '',
      telefon: json['telefon'] ?? '',
      sehir: json['sehir'] ?? '',
      pKodu: json['p_kodu'] ?? '',
      acikAdres: json['acik_adres'] ?? '',
      ulke: json['ulke'] ?? '',
      sokak: json['sokak'] ?? '',
      vNumarasi: json['v_numarasi'],
      firmaAdi: json['firma_adi'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }
}

class BasketItem {
  final int id;
  final String name;
  final String barcode;
  final String categoryName;
  final int qty;
  final double salePrice;
  final double price;
  final String image;

  bool isScanned = false;

  BasketItem({
    required this.id,
    required this.name,
    required this.barcode,
    required this.categoryName,
    required this.qty,
    required this.salePrice,
    required this.price,
    required this.image,
    this.isScanned = false, // Added default value
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      barcode: json['barcode'] ?? '',
      categoryName: json['category_name'] ?? '',
      qty: int.tryParse(json['qty'].toString()) ?? 0,  // Updated to parse as int
      salePrice: double.tryParse(json['sale_price'].toString()) ?? 0.0,  // Updated to parse as double
      price: double.tryParse(json['price'].toString()) ?? 0.0,  // Added parsing for price
      image: json['image'] ?? '',
    );
  }
}
