
class OrderDetails {
  final int id;
  // Removed cart reference
  final int sipDurum;
  final int odemDurum;
  final int stokDurum;
  final int currentId;
  final int userId;
  final double totalPrice;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String orderUser;
  final String depoUserId;
  final String? deletedAt;
  final String shippingImage;
  final String bayiAdi;
  final String siparisVeren;
  final String depoUserAd;

  OrderDetails({
    required this.id,
    // Removed cart parameter
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
    required this.depoUserId,
    this.deletedAt,
    required this.shippingImage,
    required this.bayiAdi,
    required this.siparisVeren,
    required this.depoUserAd,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    // Removed cartJson and cartItems logic
    return OrderDetails(
      id: json['id'],
      // Removed cart assignment
      sipDurum: json['sip_durum'],
      odemDurum: json['odem_durum'],
      stokDurum: json['stok_durum'],
      currentId: json['current_id'],
      userId: json['user_id'],
      totalPrice: json['total_price'].toDouble(),
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderUser: json['order_user'],
      depoUserId: json['depo_user_id'],
      deletedAt: json['deleted_at'],
      shippingImage: json['shipping_image'] ?? '',
      bayiAdi: json['bayi_adi'],
      siparisVeren: json['siparis_veren'],
      depoUserAd: json['depo_user_ad'],
    );
  }
}

// Removed CartItem class entirely
