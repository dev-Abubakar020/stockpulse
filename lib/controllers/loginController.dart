import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/biometric_auth_service.dart';
import 'package:stockpulse/services/local_auth_service.dart';
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
  final RxBool showLoginUI = false.obs;
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
    if (isGoogleLoading.value) return;
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isGoogleLoading.value = true;
      final response = await authRepository.signInWithGoogle();
      if (response != null && response.user != null) {
        await BiometricAuthService.instance.handleAuthenticatedUserChange(response.user!.id);
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
    if (isLoading.value) return;
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
        final userId = response.user!.id;

        // CRITICAL MULTI-USER CHECK: Only clear previous user if User B authenticated successfully
        await BiometricAuthService.instance.handleAuthenticatedUserChange(userId);

        // Prompt user to enable biometric if supported and not yet enabled for this user
        await _promptEnableBiometricIfNeeded(userId, email, password);

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

  Future<void> loginWithBiometric() async {
    if (isLoading.value) return;
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isLoading.value = true;
      final credentials = await BiometricAuthService.instance.loginWithBiometric();
      if (credentials == null) {
        isLoading.value = false;
        return;
      }

      final response = await authRepository.login(
        email: credentials.email,
        password: credentials.password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        await BiometricAuthService.instance.handleAuthenticatedUserChange(userId);
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

  Future<void> showBiometricOrManualPrompt() async {
    try {
      final biometricService = BiometricAuthService.instance;
      if (!await biometricService.canUseBiometricLogin()) return;

      await Get.bottomSheet(
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.fingerprint_rounded, color: Get.theme.primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.biometricAvailable,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Get.theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.manualLoginDetail,
                            style: TextStyle(
                              fontSize: 13,
                              color: Get.theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(AppConstants.manualLogin),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await loginWithBiometric();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(AppConstants.contLogin),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        isScrollControlled: true,
      );
    } catch (e) {
      debugPrint('Show biometric or manual prompt error: $e');
    }
  }

  Future<void> _promptEnableBiometricIfNeeded(String userId, String email, String password) async {
    try {
      final biometricService = BiometricAuthService.instance;
      final localAuth = LocalAuthService.instance;

      if (!await localAuth.isBiometricAvailable()) return;
      if (biometricService.isBiometricEnabled && biometricService.biometricUserId == userId) return;

      await Get.bottomSheet(
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.fingerprint_rounded, color: Get.theme.primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.enableBiometric,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Get.theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.enableBiometricSlug,
                            style: TextStyle(
                              fontSize: 13,
                              color: Get.theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(AppConstants.notNow),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          final success = await biometricService.enableBiometricForCurrentUser(
                            userId: userId,
                            email: email,
                            password: password,
                          );
                          if (success) {
                            CustomSnackBar.successSnackBar(
                              title: AppConstants.enableBiometric,
                              message: AppConstants.biometricDetail,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(AppConstants.enabled),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        isScrollControlled: true,
      );
    } catch (e) {
      debugPrint('Prompt enable biometric error: $e');
    }
  }

  Future<void> sendOtp({required String dialCode}) async {
    if (isPhoneLoading.value) return;
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

  // Future<void> verifyOtp() async {
  //   if (isPhoneLoading.value) return;
  //   final otp = otpController.text.trim();
  //
  //   final otpError = CustomValidator.validateOtp(otp);
  //   if (otpError != null) {
  //     CustomSnackBar.warningSnackBar(
  //       title: AppConstants.warningTitle,
  //       message: otpError,
  //     );
  //     return;
  //   }
  //
  //   final verificationId = _verificationId;
  //   if (verificationId == null || verificationId.isEmpty) {
  //     CustomSnackBar.errorSnackBar(
  //       title: AppConstants.errorTitle,
  //       message: AppConstants.sessionExpiredMsg,
  //     );
  //     return;
  //   }
  //
  //   if (!await NetworkManager.instance.checkInternet()) return;
  //
  //   try {
  //     isPhoneLoading.value = true;
  //
  //     final response = await authRepository.verifyOtpAndSignIn(
  //       verificationId: verificationId,
  //       smsCode: otp,
  //     );
  //
  //     if (response.user != null) {
  //       await BiometricAuthService.instance.handleAuthenticatedUserChange(response.user!.id);
  //       await _handlePostLoginNavigation();
  //     }
  //   } catch (e) {
  //     final exception = AppException.fromException(e);
  //     CustomSnackBar.errorSnackBar(
  //       title: AppConstants.verificationFailedTitle,
  //       message: exception.message,
  //     );
  //   } finally {
  //     isPhoneLoading.value = false;
  //   }
  // }

  void togglePassword() {
    obscurePassword.toggle();
  }

  Future<void> logout() async {
    if (!await NetworkManager.instance.checkInternet()) return;
    try {
      // Supabase session logout (does NOT destroy biometric/remembered config so biometric login remains available unless explicitly cleared or switched)
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
