import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/services/session_cleanup_service.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../common/exceptional/validator.dart';
import '../common/widgets/custom_snackbar.dart';
import '../services/deep_link_service.dart';
import '../services/role_service.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;

  LoginController(this.authRepository);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isPhoneLoading = false.obs;
  final isOtpSent = false.obs;
  final obscurePassword = true.obs;

  String? _verificationId;
  String phoneNumberForOtp = '';

  Future<void> _handlePostLoginNavigation() async {
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
          debugPrint('Error claiming staff invitation on login: $e');
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
        await _handlePostLoginNavigation();
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

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailError = CustomValidator.validateEmail(email);
    final passwordError = CustomValidator.validateLoginPassword(password);

    if (emailError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: emailError,
      );
      return;
    }
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

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _handlePostLoginNavigation();
      }
    } catch (e) {
      final exception = AppException.fromException(e);

      CustomSnackBar.errorSnackBar(
        title: AppConstants.loginFailedTitle,
        message: exception.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp({required String dialCode}) async {
    final localPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');

    final phoneError = CustomValidator.validatePhone(localPhone);
    if (phoneError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: phoneError,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    final normalizedPhone = localPhone.replaceFirst(RegExp(r'^0+'), '');
    final phone = '$dialCode$normalizedPhone';
    phoneNumberForOtp = phone;

    try {
      isPhoneLoading.value = true;
      await authRepository.sendPhoneOtp(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          _verificationId = verificationId;
          isOtpSent.value = true;
          isPhoneLoading.value = false;
          Get.toNamed(Routes.otpVerification);
        },
        onError: (error) {
          isPhoneLoading.value = false;
          final exception = AppException.fromException(error);
          CustomSnackBar.errorSnackBar(
            title: AppConstants.otpErrorTitle,
            message: exception.message,
          );
        },
      );

    } catch (e) {
      isPhoneLoading.value = false;
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    final otpError = CustomValidator.validateOtp(otp);
    if (otpError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: otpError,
      );
      return;
    }

    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: AppConstants.sessionExpiredMsg,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isPhoneLoading.value = true;

      final response = await authRepository.verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: otp,
      );

      if (response.user != null) {
        await _handlePostLoginNavigation();
      }
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.verificationFailedTitle,
        message: exception.message,
      );
    } finally {
      isPhoneLoading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.toggle();
  }

  Future<void> logout() async {
    if (!await NetworkManager.instance.checkInternet()) return;
    try {
      await Supabase.instance.client.auth.signOut();
      Get.find<LocalStorageService>().setLoggedIn(false);
      Get.find<LocalStorageService>().setRecoveryInProgress(false);
      Get.offAllNamed(Routes.login);
      clearUserSessionData();
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    }
  }
}
