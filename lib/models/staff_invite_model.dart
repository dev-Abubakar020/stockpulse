class StaffInvitationModel {
  final String id;
  final String token;
  final String email;
  final int shopId;
  final String shopName;
  final DateTime expiresAt;

  const StaffInvitationModel({
    required this.id,
    required this.token,
    required this.email,
    required this.shopId,
    required this.shopName,
    required this.expiresAt,
  });

  factory StaffInvitationModel.fromJson(Map<String, dynamic> json) {
    return StaffInvitationModel(
      id: json['invitation_id'].toString(),
      token: json['invitation_token'].toString(),
      email: json['invited_email'] ?? '',
      shopId: json['shop_id'] as int,
      shopName: json['shop_name'] ?? '',
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}


