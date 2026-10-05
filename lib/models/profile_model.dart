class ProfileModel {
  final String id;
  final String? fullName;
  final String? phone;
  final String? profileImg;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    this.fullName,
    this.phone,
    this.profileImg,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      profileImg: json['profile_img']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName?.trim(),

      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),

      if (profileImg != null && profileImg!.trim().isNotEmpty)
        'profile_img': profileImg!.trim(),
    };
  }
}
