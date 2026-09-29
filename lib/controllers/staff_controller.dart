import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      Get.snackbar(
        'Validation Error',
        'Please enter staff email address.',
      );
      return null;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address.',
      );
      return null;
    }

    try {
      isSending.value = true;

      // 1. Create pending invitation in database
      final invitation =
      await _repository.createInvitation(email);

      // 2. Send actual invitation email
      await _repository.sendInvitationEmail(
        invitationId: invitation.id,
      );

      // 3. Success
      clearForm();

      Get.snackbar(
        'Invitation Sent',
        'Staff invitation has been sent to $email.',
      );

      Get.back();

      return invitation;
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Invitation Failed',
        e.message,
      );

      return null;
    } catch (e) {
      // Keep actual error while testing
      Get.snackbar(
        'Invitation Failed',
        e.toString(),
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
        return staff.name.toLowerCase().contains(query);
      }).toList();
    }

    // Active
    if (selectedFilterIndex.value == 1) {
      list = list
          .where((staff) => staff.isActive)
          .toList();
    }

    // Inactive
    if (selectedFilterIndex.value == 2) {
      list = list
          .where((staff) => !staff.isActive)
          .toList();
    }

    return list;
  }

  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;

      final data = await _repository.fetchStaff();

      staffList.assignAll(data);
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to load staff members.',
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
    if (staff.isActive == isActive) return;

    try {
      await _repository.changeStaffStatus(
        userId: staff.userId,
        isActive: isActive,
      );

      await fetchStaff();

      Get.snackbar(
        'Success',
        isActive
            ? '${staff.name} has been activated.'
            : '${staff.name} has been deactivated.',
      );
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Unable to Update Staff',
        e.message,
      );
    } catch (_) {
      Get.snackbar(
        'Unable to Update Staff',
        'Something went wrong. Please try again.',
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