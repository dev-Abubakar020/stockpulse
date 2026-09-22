import 'package:stockpulse/utils/app_constants.dart';

class CustomValidator {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.requiredField(fieldName ?? AppConstants.emptyString);
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emailRequired;
    }

    final emailRegExp = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value.trim())) {
      return AppConstants.invalidEmail;
    }

    return null;
  }

  /// Login only
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }

    return null;
  }

  /// Signup / Change password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }

    if (value.length < 8) {
      return AppConstants.passwordMinLength;
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return AppConstants.passwordUppercase;
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return AppConstants.passwordLowercase;
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return AppConstants.passwordNumber;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return AppConstants.passwordSpecialChar;
    }

    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.nameRequired;
    }
    if (value.trim().length < 2) {
      return AppConstants.nameMinLength;
    }
    return null;
  }

  /// Confirm Password validation
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AppConstants.confirmPasswordRequired;
    }
    if (password != confirmPassword) {
      return AppConstants.passwordsDoNotMatch;
    }
    return null;
  }

  /// Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.phoneRequired;
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return AppConstants.invalidPhone;
    }
    return null;
  }

  /// OTP validation
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.otpRequired;
    }
    if (value.trim().length < 6) {
      return AppConstants.invalidOtp;
    }
    return null;
  }
}
