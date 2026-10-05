import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/common/exceptional/platform_exceptions.dart';
import 'package:stockpulse/common/exceptional/validator.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';
import 'package:stockpulse/controllers/shopCreateController.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';

class EditProfileController extends GetxController {
  final AuthRepository authRepository;

  EditProfileController(this.authRepository);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final profileImageUrl = ''.obs;
  final selectedImage = Rxn<XFile>();
  final imageBytes = Rxn<Uint8List>();

  final imagePicker = ImagePicker();

  final isSaving = false.obs;
  final isLoading = false.obs;
  final isFormChanged = false.obs;

  String _initialName = '';
  String _initialPhone = '';
  String _initialImageUrl = '';

  @override
  void onInit() {
    super.onInit();

    nameController.addListener(_checkFormChanged);
    phoneController.addListener(_checkFormChanged);

    ever(selectedImage, (_) => _checkFormChanged());
    ever(profileImageUrl, (_) => _checkFormChanged());

    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.onClose();
  }

  // ============================================================
  // CHECK FORM CHANGES
  // ============================================================

  void _checkFormChanged() {
    final hasNameChanged = nameController.text.trim() != _initialName;

    final hasPhoneChanged = phoneController.text.trim() != _initialPhone;

    final hasImageChanged =
        selectedImage.value != null ||
        profileImageUrl.value != _initialImageUrl;

    isFormChanged.value = hasNameChanged || hasPhoneChanged || hasImageChanged;
  }

  // ============================================================
  // LOAD USER PROFILE
  // ============================================================

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final user = authRepository.currentUser;
      if (user == null) return;

      emailController.text = user.email ?? '';

      final profile = await authRepository.getProfile(user.id);
      if (profile == null) return;

      nameController.text = profile.fullName ?? '';
      phoneController.text = profile.phone ?? '';
      profileImageUrl.value = profile.profileImg ?? '';

      _initialName = nameController.text.trim();
      _initialPhone = phoneController.text.trim();
      _initialImageUrl = profileImageUrl.value.trim();

      isFormChanged.value = false;
    } catch (e) {
      debugPrint('Load user profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) return;

    selectedImage.value = image;

    imageBytes.value = await image.readAsBytes();
  }

  // ============================================================
  // REMOVE SELECTED IMAGE
  // ============================================================

  void removeSelectedImage() {
    selectedImage.value = null;
    imageBytes.value = null;
    profileImageUrl.value = '';
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> updateProfile() async {
    if (isSaving.value) return;

    final name = nameController.text.trim();

    final phone = phoneController.text.trim();

    // ----------------------------------------------------------
    // Validate name
    // ----------------------------------------------------------

    final nameError = CustomValidator.validateName(name);

    if (nameError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: nameError,
      );

      return;
    }

    // ----------------------------------------------------------
    // Validate phone
    // ----------------------------------------------------------

    final phoneError = CustomValidator.validatePhone(phone);

    if (phoneError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: phoneError,
      );

      return;
    }

    // ----------------------------------------------------------
    // Internet
    // ----------------------------------------------------------

    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isSaving.value = true;

      await authRepository.updateProfile(
        name: name,
        phone: phone,
        image: selectedImage.value,
        existingImageUrl: profileImageUrl.value.isNotEmpty
            ? profileImageUrl.value
            : null,
      );

      // Fetch updated profile from profiles table
      final user = authRepository.currentUser;

      if (user != null) {
        final profile = await authRepository.getProfile(user.id);

        profileImageUrl.value = profile?.profileImg ?? '';
      }

      // Update baseline
      _initialName = name;
      _initialPhone = phone;
      _initialImageUrl = profileImageUrl.value;

      selectedImage.value = null;
      imageBytes.value = null;
      isFormChanged.value = false;

      // Refresh Shop / More screen
      if (Get.isRegistered<ShopCreateController>()) {
        await Get.find<ShopCreateController>().fetchShopDetails();
      }

      Get.back();

      await Future.delayed(const Duration(milliseconds: 200));

      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: AppConstants.profileUpdatedSuccessMsg,
      );
    } catch (e) {
      final exception = AppException.fromException(e);

      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
