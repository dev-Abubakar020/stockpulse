import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Supabase/Auth/Database exceptions
/// and converts them into user-friendly messages.
class CustomExceptions implements Exception {
  final String message;

  const CustomExceptions([this.message = AppConstants.defaultErrorMessage]);

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
        return const CustomExceptions(AppConstants.accountAlreadyExists);

      case 'email_address_invalid':
        return const CustomExceptions(AppConstants.invalidEmailAddress);

      case 'weak_password':
        return const CustomExceptions(AppConstants.weakPassword);

      case 'invalid_credentials':
        return const CustomExceptions(AppConstants.invalidEmailOrPassword);

      case 'user_not_found':
        return const CustomExceptions(AppConstants.userNotFound);

      case 'user_banned':
        return const CustomExceptions(AppConstants.userBanned);

      case 'email_not_confirmed':
        return const CustomExceptions(AppConstants.emailNotConfirmed);

      case 'phone_not_confirmed':
        return const CustomExceptions(AppConstants.phoneNotConfirmed);

      case 'signup_disabled':
        return const CustomExceptions(AppConstants.signupDisabled);

      case 'email_provider_disabled':
        return const CustomExceptions(AppConstants.emailProviderDisabled);

      case 'phone_provider_disabled':
        return const CustomExceptions(AppConstants.phoneProviderDisabled);

      // =========================
      // OTP / VERIFICATION
      // =========================

      case 'otp_expired':
        return const CustomExceptions(AppConstants.otpExpired);

      case 'otp_disabled':
        return const CustomExceptions(AppConstants.otpDisabled);

      case 'captcha_failed':
        return const CustomExceptions(AppConstants.captchaFailed);

      // =========================
      // SESSION
      // =========================

      case 'session_not_found':
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return const CustomExceptions(AppConstants.sessionExpired);

      // =========================
      // RATE LIMITING
      // =========================

      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return const CustomExceptions(AppConstants.rateLimitExceeded);

      // =========================
      // POSTGRES / DATABASE
      // =========================

      // Unique constraint violation
      case '23505':
        return const CustomExceptions(AppConstants.recordAlreadyExists);

      // Foreign key violation
      case '23503':
        return const CustomExceptions(AppConstants.foreignKeyViolation);

      // NOT NULL violation
      case '23502':
        return const CustomExceptions(AppConstants.notNullViolation);

      // Permission / RLS issue
      case '42501':
        return const CustomExceptions(AppConstants.permissionDeniedAction);

      // PostgREST single row not found
      case 'pgrst116':
        return const CustomExceptions(AppConstants.recordNotFound);

      // =========================
      // GENERAL
      // =========================

      case 'network_error':
        return const CustomExceptions(AppConstants.noInternetError);

      case 'timeout':
        return const CustomExceptions(AppConstants.requestTimeout);

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
        final mappedException = CustomExceptions.fromCode(exception.code!);

        // Return mapped message if code is recognized
        if (mappedException.message != AppConstants.defaultErrorMessage) {
          return mappedException;
        }
      }

      return const CustomExceptions(AppConstants.databaseError);
    }

    // =========================
    // UNKNOWN EXCEPTION
    // =========================
    return const CustomExceptions();
  }

  @override
  String toString() => message;
}
