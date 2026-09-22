import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/exceptional/validator.dart';
import '../common/widgets/custom_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository authRepository;
  ForgotPasswordController(this.authRepository);

  final emailOrPhoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final selectedRecoveryMethod = 0.obs; // 0 for Email, 1 for Phone
  
  String? _verificationId;
  String phoneNumberForOtp = '';

  Future<void> sendRecoveryCode() async {
    final input = emailOrPhoneController.text.trim();
    final emailError = CustomValidator.validateEmail(input);
    if (emailError != null) {
      CustomSnackBar.warningSnackBar(
        title: 'Warning',
        message: emailError,
      );
      return;
    }

    try {
      isLoading.value = true;
      if (selectedRecoveryMethod.value == 0) {
        // Email Recovery
        await authRepository.sendPasswordResetEmail(input);
        CustomSnackBar.successSnackBar(
          title:'Success',
          message: 'Password reset link sent to your email',
        );
      } else {
        // Phone Recovery
        final localPhone = input.replaceAll(RegExp(r'\D'), '');
        if (localPhone.length < 7) {
          Get.snackbar('Error', 'Invalid phone number');
          return;
        }
        
        // Assuming dial code is handled or pre-pended. 
        // For simplicity here, we use the input directly if it has +, else we need a dial code.
        // In the UI, the user will likely provide the full number or we use a default.
        phoneNumberForOtp = input;
        
        await authRepository.sendPhoneOtp(
          phoneNumber: input,
          onCodeSent: (verificationId) {
            _verificationId = verificationId;
            isOtpSent.value = true;
            isLoading.value = false;
            if (Get.currentRoute != Routes.otpVerification) {
              Get.toNamed(Routes.otpVerification, arguments: {'type': 'forgot_password'});
            }
          },
          onError: (error) {
            isLoading.value = false;
            Get.snackbar('OTP Error', error);
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (selectedRecoveryMethod.value == 0) {
        isLoading.value = false;
      }
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length < 6) {
      Get.snackbar('Error', 'Enter a valid 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      Get.snackbar('Error', 'Verification session expired');
      return;
    }

    try {
      isLoading.value = true;
      await authRepository.verifyOtpAndSignIn(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      // After verifying phone, we can proceed to reset password
      Get.toNamed(Routes.resetPassword);
    } catch (e) {
      Get.snackbar('Verification Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword() async {
    final pass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (pass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar('Error', 'Password fields cannot be empty');
      return;
    }

    if (pass != confirmPass) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    if (pass.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    try {
      isLoading.value = true;
      await authRepository.resetPassword(pass);
      Get.snackbar('Success', 'Password updated successfully');
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
