import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;

  const AppException([this.message = AppConstants.defaultErrorMessage]);

  /// Converts known error codes into user-friendly messages.
  factory AppException.fromCode(String code) {
    final normalizedCode = code.toLowerCase().trim();

    switch (normalizedCode) {
      // =========================
      // SUPABASE AUTH
      // =========================

      case 'user_already_exists':
      case 'email_exists':
        return const AppException(AppConstants.accountAlreadyExists);

      case 'email_address_invalid':
        return const AppException(AppConstants.invalidEmailAddress);

      case 'weak_password':
        return const AppException(AppConstants.weakPassword);

      case 'invalid_credentials':
        return const AppException(AppConstants.invalidEmailOrPassword);

      case 'user_not_found':
        return const AppException(AppConstants.userNotFound);

      case 'user_banned':
        return const AppException(AppConstants.userBanned);

      case 'email_not_confirmed':
        return const AppException(AppConstants.emailNotConfirmed);

      case 'phone_not_confirmed':
        return const AppException(AppConstants.phoneNotConfirmed);

      case 'signup_disabled':
        return const AppException(AppConstants.signupDisabled);

      case 'email_provider_disabled':
        return const AppException(AppConstants.emailProviderDisabled);

      case 'phone_provider_disabled':
        return const AppException(AppConstants.phoneProviderDisabled);

      // =========================
      // OTP
      // =========================

      case 'otp_expired':
        return const AppException(AppConstants.otpExpired);

      case 'otp_disabled':
        return const AppException(AppConstants.otpDisabled);

      case 'captcha_failed':
        return const AppException(AppConstants.captchaFailed);

      // =========================
      // SESSION
      // =========================

      case 'session_not_found':
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return const AppException(AppConstants.sessionExpired);

      // =========================
      // RATE LIMIT
      // =========================

      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return const AppException(AppConstants.rateLimitExceeded);

      // =========================
      // POSTGRES / DATABASE
      // =========================

      /// Unique constraint violation
      case '23505':
        return const AppException(AppConstants.recordAlreadyExists);

      /// Foreign key violation
      case '23503':
        return const AppException(AppConstants.foreignKeyViolation);

      /// NOT NULL violation
      case '23502':
        return const AppException(AppConstants.notNullViolation);

      /// Permission / RLS
      case '42501':
        return const AppException(AppConstants.permissionDeniedAction);

      /// PostgREST single record not found
      case 'pgrst116':
        return const AppException(AppConstants.recordNotFound);

      default:
        return const AppException();
    }
  }

  /// Converts different exception types into one AppException.
  factory AppException.fromException(dynamic exception) {
    // Already converted
    if (exception is AppException) {
      return exception;
    }

    // =========================
    // SUPABASE AUTH
    // =========================
    if (exception is AuthException) {
      final code = exception.code;

      if (code != null) {
        final mapped = AppException.fromCode(code);

        if (!_isDefaultMessage(mapped.message)) {
          return mapped;
        }
      }

      if (exception.message.isNotEmpty) {
        return AppException(exception.message);
      }

      return const AppException(AppConstants.authFailed);
    }

    // =========================
    // SUPABASE DATABASE
    // =========================
    if (exception is PostgrestException) {
      if (exception.code != null) {
        final mapped = AppException.fromCode(exception.code!);

        if (!_isDefaultMessage(mapped.message)) {
          return mapped;
        }
      }

      if (exception.message.isNotEmpty) {
        return AppException(exception.message);
      }

      return const AppException(AppConstants.databaseError);
    }

    // =========================
    // NETWORK
    // =========================
    if (exception is SocketException) {
      return const AppException(AppConstants.noInternetError);
    }

    if (exception is TimeoutException) {
      return const AppException(AppConstants.requestTimeout);
    }

    // =========================
    // FLUTTER PLATFORM
    // =========================
    if (exception is PlatformException) {
      return _fromPlatformException(exception);
    }

    // =========================
    // FORMAT
    // =========================
    if (exception is FormatException) {
      return const AppException(AppConstants.invalidDataFormat);
    }

    // =========================
    // FIREBASE / GENERIC EXCEPTION WITH MESSAGE
    // =========================
    try {
      final msg = exception.message;
      if (msg != null && msg is String && msg.isNotEmpty) {
        return AppException(msg);
      }
    } catch (_) {}

    if (exception is String && exception.isNotEmpty) {
      return AppException(exception);
    }

    // =========================
    // UNKNOWN
    // =========================
    return const AppException();
  }

  /// Handle Flutter/device PlatformException.
  static AppException _fromPlatformException(PlatformException exception) {
    switch (exception.code.toLowerCase()) {
      case 'permission_denied':
        return const AppException(AppConstants.permissionDeniedDevice);

      case 'camera_access_denied':
        return const AppException(AppConstants.cameraPermissionDenied);

      case 'camera_unavailable':
        return const AppException(AppConstants.cameraUnavailable);

      case 'storage_permission_denied':
        return const AppException(AppConstants.storagePermissionDenied);

      default:
        return const AppException(AppConstants.deviceError);
    }
  }

  static bool _isDefaultMessage(String message) {
    return message == AppConstants.defaultErrorMessage;
  }

  @override
  String toString() => message;
}
