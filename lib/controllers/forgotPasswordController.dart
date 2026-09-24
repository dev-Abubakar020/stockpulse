import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../common/exceptional/platform_exceptions.dart';
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
  final selectedRecoveryMethod = 0.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  String? _verificationId;
  String phoneNumberForOtp = '';

  void togglePassword() {
    obscurePassword.toggle();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.toggle();
  }

  Future<void> sendRecoveryCode() async {
    final input = emailOrPhoneController.text.trim();

    if (selectedRecoveryMethod.value == 0) {
      final emailError = CustomValidator.validateEmail(input);
      if (emailError != null) {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.warningTitle,
          message: emailError,
        );
        return;
      }
    } else {
      final phoneError = CustomValidator.validatePhone(input);
      if (phoneError != null) {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.warningTitle,
          message: phoneError,
        );
        return;
      }
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isLoading.value = true;
      if (selectedRecoveryMethod.value == 0) {
        // Email Recovery
        await authRepository.sendPasswordResetEmail(input);
        CustomSnackBar.successSnackBar(
          title: AppConstants.successTitle,
          message: AppConstants.resetLinkSentMsg,
        );
        emailOrPhoneController.clear();
        Get.toNamed(Routes.login);
      } else {
        // Phone Recovery
        phoneNumberForOtp = input;

        await authRepository.sendPhoneOtp(
          phoneNumber: input,
          onCodeSent: (verificationId) {
            _verificationId = verificationId;
            isOtpSent.value = true;
            isLoading.value = false;
            if (Get.currentRoute != Routes.otpVerification) {
              Get.toNamed(
                Routes.otpVerification,
                arguments: {'type': 'forgot_password'},
              );
            }
          },
          onError: (error) {
            isLoading.value = false;
            final exception = AppException.fromException(error);
            CustomSnackBar.errorSnackBar(
              title: AppConstants.otpErrorTitle,
              message: exception.message,
            );
          },
        );
      }
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      if (selectedRecoveryMethod.value == 0) {
        isLoading.value = false;
      }
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
      isLoading.value = true;
      await authRepository.verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: otp,
      );
      Get.toNamed(Routes.resetPassword);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.verificationFailedTitle,
        message: exception.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword() async {
    final pass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    final passError = CustomValidator.validatePassword(pass);
    if (passError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: passError,
      );
      return;
    }

    final confirmError = CustomValidator.validateConfirmPassword(
      pass,
      confirmPass,
    );
    if (confirmError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: confirmError,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isLoading.value = true;
      await authRepository.resetPassword(pass);
      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: AppConstants.passwordUpdatedSuccessMsg,
      );
      Get.offAllNamed(Routes.login);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
