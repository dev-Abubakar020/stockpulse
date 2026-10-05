class ShopModel {
  final int? id;
  final String? authUid;
  final String? shopname;
  final String? ownername;
  final String? phone;
  final String? address;
  final String? currencySymbol;
  final String? currencyCode;
  final String? shopimg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShopModel({
    this.id,
    this.authUid,
    this.shopname,
    this.ownername,
    this.phone,
    this.address,
    this.currencySymbol,
    this.currencyCode,
    this.shopimg,
    this.createdAt,
    this.updatedAt,
  });

  // CREATE NEW SHOP MODEL
  factory ShopModel.create({
    required String userId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String currencySymbol,
    required String currencyCode,
    String? imageUrl,
  }) {
    final now = DateTime.now().toUtc();

    return ShopModel(
      authUid: userId,
      shopname: shopName.trim(),
      ownername: ownerName.trim(),
      phone: phone.trim().isEmpty ? null : phone.trim(),
      address: address.trim(),
      currencySymbol: currencySymbol,
      currencyCode: currencyCode,
      shopimg: imageUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: (json['id'] as num?)?.toInt(),
      authUid: json['auth_uid']?.toString(),
      shopname: json['shopename']?.toString(),
      ownername: json['ownerame']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      currencySymbol: json['selectedsymbole']?.toString(),
      currencyCode: json['selectedcurrency']?.toString(),
      shopimg: json['shopimg']?.toString(),
      createdAt: _parseDate(json['createdat']),
      updatedAt: _parseDate(json['updatedat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_uid': authUid,
      'shopename': shopname,
      'ownerame': ownername,
      'phone': phone,
      'address': address,
      'selectedsymbole': currencySymbol,
      'selectedcurrency': currencyCode,
      'shopimg': shopimg,
      'createdat': createdAt?.toIso8601String(),
      'updatedat': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  ShopModel copyWith({
    int? id,
    String? authUid,
    String? shopname,
    String? ownername,
    String? phone,
    String? address,
    String? currencySymbol,
    String? currencyCode,
    String? shopimg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      authUid: authUid ?? this.authUid,
      shopname: shopname ?? this.shopname,
      ownername: ownername ?? this.ownername,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      shopimg: shopimg ?? this.shopimg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
