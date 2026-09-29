import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../models/staff_invite_model.dart';
import '../repositories/staff_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_model.dart';

class StaffController extends GetxController {
  final StaffRepository _repository = StaffRepository();

  final staffList = <StaffModel>[].obs;
  final isSending = false.obs;
  final searchQuery = ''.obs;
  final selectedFilterIndex = 0.obs;
  final isLoading = false.obs;

  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchStaff();
  }

  Future<StaffInvitationModel?> sendInvitation() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      CustomSnackBar.errorSnackBar(
        title: 'Validation Error',
        message: 'Please enter staff email address.',
      );
      return null;
    }

    if (!GetUtils.isEmail(email)) {
      CustomSnackBar.errorSnackBar(
        title: 'Validation Error',
        message:'Please enter a valid email address.',
      );
      return null;
    }

    try {
      isSending.value = true;

      // 1. Create pending invitation in database
      final invitation = await _repository.createInvitation(email);
      // 2. Send actual invitation email
      await _repository.sendInvitationEmail(
        invitationId: invitation.id,
      );
      await fetchStaff();
      // 3. Clear form and close screen FIRST
      clearForm();
      Get.back(result: invitation);

      // 4. Show success snackbar on the parent screen
      CustomSnackBar.successSnackBar(
        title: 'Invitation Sent',
        message: 'Staff invitation has been sent to $email.',
        );

      return invitation;
    } on PostgrestException catch (e) {
      CustomSnackBar.errorSnackBar(
        title: 'Invitation Failed',
        message:  e.message);
      return null;
    } catch (e) {
      CustomSnackBar.errorSnackBar(
        title: 'Invitation Failed',
        message:  e.toString(),
        );
      return null;
    } finally {
      isSending.value = false;
    }
  }

  List<StaffModel> get filteredStaff {
    var list = staffList.toList();

    final query = searchQuery.value.trim().toLowerCase();

    // Search
    if (query.isNotEmpty) {
      list = list.where((staff) {
        return staff.name.toLowerCase().contains(query) ||
            (staff.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter order:
    // 0 = All
    // 1 = Pending
    // 2 = Active
    // 3 = Inactive

    switch (selectedFilterIndex.value) {
      case 1:
        list = list
            .where((staff) => staff.status == StaffStatus.pending)
            .toList();
        break;

      case 2:
        list = list
            .where((staff) => staff.status == StaffStatus.active)
            .toList();
        break;

      case 3:
        list = list
            .where((staff) => staff.status == StaffStatus.inactive)
            .toList();
        break;
    }

    return list;
  }

  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;

      final data = await _repository.fetchStaff();

      staffList.assignAll(data);
    } on PostgrestException catch (e) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: e.message,
      );
    } catch (e) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: AppConstants.unableToLoadStaffMsg,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
  }

  Future<void> changeStaffStatus(
      StaffModel staff,
      bool isActive,
      ) async
  {
    if (staff.userId == null || staff.isPending) return;
    if (staff.isActive == isActive) return;

    try {
      await _repository.changeStaffStatus(
        userId: staff.userId!,
        isActive: isActive,
      );

      await fetchStaff();
      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: isActive
            ? '${staff.name} has been activated.'
            : '${staff.name} has been deactivated.',
      );
    } on PostgrestException catch (e) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.unableToUpdateStaffTitle,
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.unableToUpdateStaffTitle,
        message: AppConstants.defaultErrorMessage,
      );
    }
  }

  Future<void> resendInvitation(StaffModel staff) async {
    if (!staff.isPending ||
        staff.invitationId == null ||
        !staff.isInviteExpired) {
      return;
    }

    try {
      isSending.value = true;

      await _repository.resendInvitation(
        invitationId: staff.invitationId!,
      );

      await fetchStaff();

      CustomSnackBar.successSnackBar(
        title: 'Invitation Sent',
        message: 'Invitation has been resent to ${staff.email}.',
      );
    } on PostgrestException catch (e) {
      CustomSnackBar.errorSnackBar(
        title: 'Unable to Resend',
        message: e.message,
      );
    } catch (e) {
      CustomSnackBar.errorSnackBar(
        title: 'Unable to Resend',
        message: e.toString(),
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> cancelInvitation(StaffModel staff) async {
    if (!staff.isPending || staff.invitationId == null) return;

    try {
      await _repository.cancelInvitation(
        invitationId: staff.invitationId!,
      );

      await fetchStaff();

      CustomSnackBar.successSnackBar(
        title: 'Invitation Cancelled',
        message: 'Staff invitation has been cancelled.',
      );
    } on PostgrestException catch (e) {
      CustomSnackBar.errorSnackBar(
        title: 'Unable to Cancel',
        message: e.message,
      );
    } catch (_) {
      CustomSnackBar.errorSnackBar(
        title: 'Unable to Cancel',
        message: AppConstants.defaultErrorMessage,
      );
    }
  }



  void clearForm() {
    emailController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}