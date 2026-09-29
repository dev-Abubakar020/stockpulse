import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_invite_model.dart';
import '../models/staff_model.dart';

class StaffRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<StaffInvitationModel> createInvitation(String email) async {
    final response = await _supabase.rpc(
      'create_staff_invitation',
      params: {
        'p_email': email.trim(),
      },
    );

    if (response == null || response is! List || response.isEmpty) {
      throw Exception('Unable to create staff invitation.');
    }

    return StaffInvitationModel.fromJson(
      Map<String, dynamic>.from(response.first),
    );
  }

  Future<void> sendInvitationEmail({
    required String invitationId,
  }) async {
    final response = await _supabase.functions.invoke(
      'send-staff-invitation',
      body: {
        'invitationId': invitationId,
      },
    );

    if (response.status != 200) {
      final message = response.data is Map
          ? response.data['error']?.toString()
          : null;

      throw Exception(
        message ?? 'Unable to send invitation email.',
      );
    }
  }

  Future<void> changeStaffStatus({
    required String userId,
    required bool isActive,
  }) async {
    await _supabase.rpc(
      'set_staff_status',
      params: {
        'p_user_id': userId,
        'p_is_active': isActive,
      },
    );
  }

  Future<void> resendInvitation({
    required String invitationId,
  }) async {
    await _supabase.rpc(
      'resend_staff_invitation',
      params: {
        'p_invitation_id': invitationId,
      },
    );

    await sendInvitationEmail(
      invitationId: invitationId,
    );
  }

  Future<void> cancelInvitation({
    required String invitationId,
  }) async {
    await _supabase.rpc(
      'cancel_staff_invitation',
      params: {
        'p_invitation_id': invitationId,
      },
    );
  }


  Future<List<StaffModel>> fetchStaff() async {
    final response = await _supabase.rpc('get_shop_staff');

    return (response as List)
        .map(
          (json) => StaffModel.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }
}