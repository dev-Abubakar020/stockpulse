import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/deep_link_service.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/services/role_service.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../common/exceptional/validator.dart';
import '../common/widgets/custom_snackbar.dart';

class SignupController extends GetxController {
  final AuthRepository authRepository;
  SignupController(this.authRepository);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final imagePicker = ImagePicker();
  final selectedImage = Rxn<XFile>();
  final imageBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

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

  void removeImage() {
    selectedImage.value = null;
    imageBytes.value = null;
  }

  Future<void> _handlePostSignupNavigation() async {
    Get.find<LocalStorageService>().setLoggedIn(true);

    final deepLinkService = Get.isRegistered<DeepLinkService>()
        ? Get.find<DeepLinkService>()
        : null;
    final invitationToken = deepLinkService?.pendingStaffInvitationToken;

    if (invitationToken != null && invitationToken.isNotEmpty) {
      if (Supabase.instance.client.auth.currentSession != null) {
        try {
          await Supabase.instance.client.rpc(
            'claim_staff_invitation',
            params: {'p_token': invitationToken},
          );
          deepLinkService?.pendingStaffInvitationToken = null;
        } catch (e) {
          debugPrint('Error claiming staff invitation: $e');
        }
      }
    }

    final roleService = Get.isRegistered<RoleService>()
        ? Get.find<RoleService>()
        : Get.put(RoleService(), permanent: true);

    await roleService.fetchMembership();

    if (roleService.hasMembership.value) {
      if (roleService.isStaff && !roleService.isActive.value) {
        CustomSnackBar.errorSnackBar(
          title: 'Account Inactive',
          message: 'Your staff account is inactive. Please contact the shop owner.',
        );
        await Supabase.instance.client.auth.signOut();
        Get.offAllNamed(Routes.login);
        return;
      }
      Get.offAllNamed(Routes.dashboard);
      return;
    }

    final hasShop = await Get.find<ShopRepository>().currentUserHasShop();
    if (hasShop) {
      Get.offAllNamed(Routes.dashboard);
    } else {
      Get.offAllNamed(Routes.createShop);
    }
  }

  Future<void> signInWithGoogle() async {
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isGoogleLoading.value = true;
      final response = await authRepository.signInWithGoogle();
      if (response != null && response.user != null) {
        await _handlePostSignupNavigation();
      }
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.googleSignInFailedTitle,
        message: exception.message,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    final nameError = CustomValidator.validateName(name);
    if (nameError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: nameError,
      );
      return;
    }

    final emailError = CustomValidator.validateEmail(email);
    if (emailError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: emailError,
      );
      return;
    }

    final passwordError = CustomValidator.validatePassword(password);
    if (passwordError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: passwordError,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isLoading.value = true;
      final response = await authRepository.signup(
        name: name,
        email: email,
        password: password,
        image: selectedImage.value,
      );

      if (response.user == null) {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.checkYourEmailTitle,
          message: AppConstants.confirmEmailMsg,
        );
      } else if (response.session == null) {
        CustomSnackBar.successSnackBar(
          title: AppConstants.checkYourEmailTitle,
          message: AppConstants.confirmEmailMsg,
        );
        Get.offAllNamed(Routes.login);
      } else {
        await _handlePostSignupNavigation();
      }
    } catch (error) {
      final exception = AppException.fromException(error);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.signupFailedTitle,
        message: exception.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.toggle();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.toggle();
  }
}
