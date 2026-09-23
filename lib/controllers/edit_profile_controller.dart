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
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileController extends GetxController {
  final AuthRepository authRepository;

  EditProfileController(this.authRepository);

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final profileImageUrl = ''.obs;
  final selectedImage = Rxn<XFile>();
  final imageBytes = Rxn<Uint8List>();
  final imagePicker = ImagePicker();

  final isSaving = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user =
          authRepository.currentUser ??
          Supabase.instance.client.auth.currentUser;
      emailController.text = user?.email ?? '';

      final metadata = user?.userMetadata ?? <String, dynamic>{};
      var name =
          (metadata['name'] ??
                  metadata['full_name'] ??
                  metadata['display_name'] ??
                  user?.email?.split('@').first ??
                  '')
              .toString();
      var img =
          (metadata['profile_img'] ??
                  metadata['avatar_url'] ??
                  metadata['picture'] ??
                  '')
              .toString();

      if (user != null) {
        final profile = await authRepository.getProfile(user.id);
        if (profile != null) {
          if (profile['name'] != null && profile['name'].toString().isNotEmpty) {
            name = profile['name'].toString();
          } else if (profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) {
            name = profile['full_name'].toString();
          }
          if (profile['profile_img'] != null && profile['profile_img'].toString().isNotEmpty) {
            img = profile['profile_img'].toString();
          } else if (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty) {
            img = profile['avatar_url'].toString();
          }
        }
      }

      nameController.text = name;
      profileImageUrl.value = img;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image == null) return;

    selectedImage.value = image;
    final bytes = await image.readAsBytes();
    imageBytes.value = bytes;
  }

  void removeSelectedImage() {
    selectedImage.value = null;
    imageBytes.value = null;
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();

    final nameError = CustomValidator.validateName(name);
    if (nameError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: nameError,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isSaving.value = true;
      await authRepository.updateProfile(
        name: name,
        image: selectedImage.value,
        existingImageUrl: profileImageUrl.value.isNotEmpty
            ? profileImageUrl.value
            : null,
      );

      // Refresh Shop / More screen state
      if (Get.isRegistered<ShopCreateController>()) {
        await Get.find<ShopCreateController>().fetchShopDetails();
      }

      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: AppConstants.profileUpdatedSuccessMsg,
      );

      Get.back();
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
