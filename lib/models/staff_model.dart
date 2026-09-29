class StaffModel {
  final String userId;
  final String name;
  final String? profileImg;
  final String role;
  final bool isActive;
  final DateTime? joinedAt;

  const StaffModel({
    required this.userId,
    required this.name,
    this.profileImg,
    required this.role,
    required this.isActive,
    this.joinedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['full_name'] ?? 'Staff Member',
      profileImg: json['profile_img'],
      role: json['role'] ?? 'staff',
      isActive: json['is_active'] ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
    );
  }
}