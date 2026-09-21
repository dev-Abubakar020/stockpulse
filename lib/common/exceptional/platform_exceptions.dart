import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;

  const AppException([
    this.message = 'Something went wrong. Please try again.',
  ]);

  /// Converts known error codes into user-friendly messages.
  factory AppException.fromCode(String code) {
    final normalizedCode = code.toLowerCase().trim();

    switch (normalizedCode) {
    // =========================
    // SUPABASE AUTH
    // =========================

      case 'user_already_exists':
      case 'email_exists':
        return const AppException(
          'An account already exists with this email address.',
        );

      case 'email_address_invalid':
        return const AppException(
          'Please enter a valid email address.',
        );

      case 'weak_password':
        return const AppException(
          'The password is too weak. Please choose a stronger password.',
        );

      case 'invalid_credentials':
        return const AppException(
          'Invalid email or password.',
        );

      case 'user_not_found':
        return const AppException(
          'No account was found with these credentials.',
        );

      case 'user_banned':
        return const AppException(
          'This account has been disabled. Please contact support.',
        );

      case 'email_not_confirmed':
        return const AppException(
          'Please verify your email address before signing in.',
        );

      case 'phone_not_confirmed':
        return const AppException(
          'Please verify your phone number before signing in.',
        );

      case 'signup_disabled':
        return const AppException(
          'New account registration is currently disabled.',
        );

      case 'email_provider_disabled':
        return const AppException(
          'Email authentication is currently disabled.',
        );

      case 'phone_provider_disabled':
        return const AppException(
          'Phone authentication is currently disabled.',
        );

    // =========================
    // OTP
    // =========================

      case 'otp_expired':
        return const AppException(
          'The verification code has expired. Please request a new one.',
        );

      case 'otp_disabled':
        return const AppException(
          'OTP authentication is currently unavailable.',
        );

      case 'captcha_failed':
        return const AppException(
          'Security verification failed. Please try again.',
        );

    // =========================
    // SESSION
    // =========================

      case 'session_not_found':
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return const AppException(
          'Your session has expired. Please sign in again.',
        );

    // =========================
    // RATE LIMIT
    // =========================

      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return const AppException(
          'Too many requests. Please wait and try again.',
        );

    // =========================
    // POSTGRES / DATABASE
    // =========================

    /// Unique constraint violation
      case '23505':
        return const AppException(
          'This record already exists.',
        );

    /// Foreign key violation
      case '23503':
        return const AppException(
          'This operation cannot be completed because related data exists.',
        );

    /// NOT NULL violation
      case '23502':
        return const AppException(
          'Required information is missing.',
        );

    /// Permission / RLS
      case '42501':
        return const AppException(
          'You do not have permission to perform this action.',
        );

    /// PostgREST single record not found
      case 'pgrst116':
        return const AppException(
          'The requested record was not found.',
        );

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
      if (exception.code != null) {
        final mapped = AppException.fromCode(exception.code!);

        if (!_isDefaultMessage(mapped.message)) {
          return mapped;
        }
      }

      return AppException(exception.message);
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

      return const AppException(
        'A database error occurred. Please try again.',
      );
    }

    // =========================
    // NETWORK
    // =========================
    if (exception is SocketException) {
      return const AppException(
        'No internet connection. Please check your network.',
      );
    }

    if (exception is TimeoutException) {
      return const AppException(
        'The request timed out. Please try again.',
      );
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
      return const AppException(
        'Invalid data format received.',
      );
    }

    // =========================
    // UNKNOWN
    // =========================
    return const AppException();
  }

  /// Handle Flutter/device PlatformException.
  static AppException _fromPlatformException(
      PlatformException exception,
      ) {
    switch (exception.code.toLowerCase()) {
      case 'permission_denied':
        return const AppException(
          'Permission denied. Please allow the required permission.',
        );

      case 'camera_access_denied':
        return const AppException(
          'Camera permission is required to use this feature.',
        );

      case 'camera_unavailable':
        return const AppException(
          'Camera is currently unavailable.',
        );

      case 'storage_permission_denied':
        return const AppException(
          'Storage permission is required.',
        );

      default:
        return const AppException(
          'A device error occurred. Please try again.',
        );
    }
  }

  static bool _isDefaultMessage(String message) {
    return message == 'Something went wrong. Please try again.';
  }

  @override
  String toString() => message;
}