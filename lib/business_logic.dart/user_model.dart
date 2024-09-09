import 'dart:convert';

class UserModel {
  final int id;
  final String eposta;
  final String ad;
  final String soyad;
  final int dealerId;

  UserModel({
    required this.id,
    required this.eposta,
    required this.ad,
    required this.soyad,
    required this.dealerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      eposta: json['eposta'],
      ad: json['ad'],
      soyad: json['soyad'],
      dealerId: json['dealer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eposta': eposta,
      'ad': ad,
      'soyad': soyad,
      'dealer_id': dealerId,
    };
  }

  static UserModel? fromSharedPreferences(String? userString) {
    if (userString == null) return null;
    return UserModel.fromJson(json.decode(userString));
  }

  String toSharedPreferences() {
    return json.encode(toJson());
  }
}