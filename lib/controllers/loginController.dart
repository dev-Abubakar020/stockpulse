import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final response = await authRepository.signInWithGoogle();
      if (response != null && response.user != null) {
        Get.find<LocalStorageService>().setLoggedIn(true);
        Get.offAllNamed(Routes.dashboard);
      }
    } on AuthException catch (e) {
      Get.snackbar('Google Sign-In Failed', e.message);
    } catch (e) {
      Get.snackbar('Google Sign-In Failed', e.toString());
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password are required');
      return;
    } else if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    try {
      isLoading.value = true;

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.find<LocalStorageService>().setLoggedIn(true);
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp({required String dialCode}) async {
    final localPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (localPhone.length < 7) {
      Get.snackbar('Error', 'Phone number is required');
      return;
    }

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
          Get.snackbar('OTP Error', error);
        },
      );
    } catch (e) {
      isPhoneLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar('Error', 'Enter a valid 6-digit OTP code');
      return;
    }

    if (_verificationId == null) {
      Get.snackbar('Error', 'Verification session expired. Resend OTP.');
      return;
    }

    try {
      isPhoneLoading.value = true;

      final verificationId = _verificationId;
      if (verificationId == null || verificationId.isEmpty) {
        Get.snackbar('Error', 'Verification session expired. Resend OTP.');
        return;
      }

      final response = await authRepository.verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: otp,
      );

      if (response.user != null) {
        Get.find<LocalStorageService>().setLoggedIn(true);
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      Get.snackbar('Verification Failed', e.toString());
    } finally {
      isPhoneLoading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.toggle();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.find<LocalStorageService>().setLoggedIn(false);
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
