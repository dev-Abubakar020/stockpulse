enum StaffStatus {
  active,
  inactive,
  pending,
}

class StaffModel {
  final String? userId;
  final String name;
  final String? email;
  final String? profileImg;
  final String role;
  final StaffStatus status;
  final DateTime? joinedAt;
  final String? invitationId;

  const StaffModel({
    this.userId,
    required this.name,
    this.email,
    this.profileImg,
    required this.role,
    required this.status,
    this.joinedAt,
    this.invitationId,
  });

  bool get isActive => status == StaffStatus.active;

  bool get isInactive => status == StaffStatus.inactive;

  bool get isPending => status == StaffStatus.pending;

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final statusValue =
        json['status']?.toString().toLowerCase() ?? 'inactive';

    final StaffStatus status;

    switch (statusValue) {
      case 'active':
        status = StaffStatus.active;
        break;

      case 'pending':
        status = StaffStatus.pending;
        break;

      default:
        status = StaffStatus.inactive;
    }

    return StaffModel(
      userId: json['user_id']?.toString(),
      name: json['full_name']?.toString() ?? 'Staff Member',
      email: json['email']?.toString(),
      profileImg: json['profile_img']?.toString(),
      role: json['role']?.toString() ?? 'staff',
      status: status,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
      invitationId: json['invitation_id']?.toString(),
    );
  }
}