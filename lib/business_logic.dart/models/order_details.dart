class OrderDetails {
  final int id;
  // Removed cart reference
  final int sipDurum;
  final int odemDurum;
  final int stokDurum;
  final int currentId;
  final int userId;
  final double totalPrice;
  final String? note; // Nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final String orderUser;
  final String? depoUserId; // Nullable
  final String? deletedAt; // Nullable
  final String? shippingImage; // Nullable
  final String bayiAdi;
  final String siparisVeren;
  final String? depoUserAd; // Nullable

  OrderDetails({
    required this.id,
    // Removed cart parameter
    required this.sipDurum,
    required this.odemDurum,
    required this.stokDurum,
    required this.currentId,
    required this.userId,
    required this.totalPrice,
    this.note, // Nullable
    required this.createdAt,
    required this.updatedAt,
    required this.orderUser,
    this.depoUserId, // Nullable
    this.deletedAt, // Nullable
    this.shippingImage, // Nullable
    required this.bayiAdi,
    required this.siparisVeren,
    this.depoUserAd, // Nullable
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      sipDurum: json['sip_durum'] ?? 0, // Default to 0 if null
      odemDurum: json['odem_durum'] ?? 0, // Default to 0 if null
      stokDurum: json['stok_durum'] ?? 0, // Default to 0 if null
      currentId: json['current_id'] ?? 0, // Default to 0 if null
      userId: json['user_id'] ?? 0, // Default to 0 if null
      totalPrice: (json['total_price'] ?? 0).toDouble(), // Default to 0 if null
      note: json['note'] ?? '', // Default to empty string if null
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderUser: json['order_user'] ?? '', // Default to empty string if null
      depoUserId: json['depo_user_id'], // Keep as is, can be null
      deletedAt: json['deleted_at'], // Keep as is, can be null
      shippingImage: json['shipping_image'] ?? '', // Default to empty string if null
      bayiAdi: json['bayi_adi'] ?? '', // Default to empty string if null
      siparisVeren: json['siparis_veren'] ?? '', // Default to empty string if null
      depoUserAd: json['depo_user_ad'] ?? '', // Default to empty string if null
    );
  }
}

// Removed CartItem class entirely
