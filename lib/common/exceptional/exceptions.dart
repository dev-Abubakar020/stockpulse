import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Supabase/Auth/Database exceptions
/// and converts them into user-friendly messages.
class CustomExceptions implements Exception {
  final String message;

  const CustomExceptions([
    this.message = 'An unexpected error occurred. Please try again.',
  ]);

  /// Converts Supabase/PostgreSQL error codes
  /// into user-friendly messages.
  factory CustomExceptions.fromCode(String code) {
    final normalizedCode = code.toLowerCase().trim();

    switch (normalizedCode) {
    // =========================
    // AUTHENTICATION
    // =========================

      case 'user_already_exists':
      case 'email_exists':
        return const CustomExceptions(
          'An account already exists with this email address.',
        );

      case 'email_address_invalid':
        return const CustomExceptions(
          'Please enter a valid email address.',
        );

      case 'weak_password':
        return const CustomExceptions(
          'The password is too weak. Please choose a stronger password.',
        );

      case 'invalid_credentials':
        return const CustomExceptions(
          'Invalid email or password. Please check your credentials.',
        );

      case 'user_not_found':
        return const CustomExceptions(
          'No account was found with these credentials.',
        );

      case 'user_banned':
        return const CustomExceptions(
          'This account has been disabled. Please contact support.',
        );

      case 'email_not_confirmed':
        return const CustomExceptions(
          'Please verify your email address before signing in.',
        );

      case 'phone_not_confirmed':
        return const CustomExceptions(
          'Please verify your phone number before signing in.',
        );

      case 'signup_disabled':
        return const CustomExceptions(
          'New account registration is currently disabled.',
        );

      case 'email_provider_disabled':
        return const CustomExceptions(
          'Email authentication is currently disabled.',
        );

      case 'phone_provider_disabled':
        return const CustomExceptions(
          'Phone authentication is currently disabled.',
        );

    // =========================
    // OTP / VERIFICATION
    // =========================

      case 'otp_expired':
        return const CustomExceptions(
          'The verification code has expired. Please request a new one.',
        );

      case 'otp_disabled':
        return const CustomExceptions(
          'OTP authentication is currently unavailable.',
        );

      case 'captcha_failed':
        return const CustomExceptions(
          'Security verification failed. Please try again.',
        );

    // =========================
    // SESSION
    // =========================

      case 'session_not_found':
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return const CustomExceptions(
          'Your session has expired. Please sign in again.',
        );

    // =========================
    // RATE LIMITING
    // =========================

      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return const CustomExceptions(
          'Too many requests. Please wait and try again.',
        );

    // =========================
    // POSTGRES / DATABASE
    // =========================

    // Unique constraint violation
      case '23505':
        return const CustomExceptions(
          'This record already exists.',
        );

    // Foreign key violation
      case '23503':
        return const CustomExceptions(
          'This operation cannot be completed because related data exists.',
        );

    // NOT NULL violation
      case '23502':
        return const CustomExceptions(
          'Required information is missing.',
        );

    // Permission / RLS issue
      case '42501':
        return const CustomExceptions(
          'You do not have permission to perform this action.',
        );

    // PostgREST single row not found
      case 'pgrst116':
        return const CustomExceptions(
          'The requested record was not found.',
        );

    // =========================
    // GENERAL
    // =========================

      case 'network_error':
        return const CustomExceptions(
          'Network error. Please check your internet connection.',
        );

      case 'timeout':
        return const CustomExceptions(
          'The request timed out. Please try again.',
        );

      default:
        return const CustomExceptions();
    }
  }

  /// Converts actual Supabase exception objects
  /// into CustomExceptions.
  factory CustomExceptions.fromException(dynamic exception) {
    // =========================
    // AUTH EXCEPTION
    // =========================
    if (exception is AuthException) {
      if (exception.code != null) {
        return CustomExceptions.fromCode(exception.code!);
      }

      return CustomExceptions(exception.message);
    }

    // =========================
    // DATABASE EXCEPTION
    // =========================
    if (exception is PostgrestException) {
      if (exception.code != null) {
        final mappedException = CustomExceptions.fromCode(
          exception.code!,
        );

        // Return mapped message if code is recognized
        if (mappedException.message !=
            'An unexpected error occurred. Please try again.') {
          return mappedException;
        }
      }

      return const CustomExceptions(
        'A database error occurred. Please try again.',
      );
    }

    // =========================
    // UNKNOWN EXCEPTION
    // =========================
    return const CustomExceptions();
  }

  @override
  String toString() => message;
}