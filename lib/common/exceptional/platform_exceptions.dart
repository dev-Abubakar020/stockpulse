import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_constants.dart';

class AppException implements Exception {
  final String message;

  const AppException([
    this.message = AppConstants.defaultErrorMessage,
  ]);
  

  /// Converts known error codes into user-friendly messages.
  factory AppException.fromCode(String code) {
    final normalizedCode =
    code.toLowerCase().trim();

    switch (normalizedCode) {
    // SUPABASE AUTH

      case 'user_already_exists':
      case 'email_exists':
        return const AppException(
          AppConstants.accountAlreadyExists,
        );

      case 'email_address_invalid':
        return const AppException(
          AppConstants.invalidEmailAddress,
        );

      case 'weak_password':
        return const AppException(
          AppConstants.weakPassword,
        );

      case 'invalid_credentials':
        return const AppException(
          AppConstants.invalidEmailOrPassword,
        );

      case 'user_not_found':
        return const AppException(
          AppConstants.userNotFound,
        );

      case 'user_banned':
        return const AppException(
          AppConstants.userBanned,
        );

      case 'email_not_confirmed':
        return const AppException(
          AppConstants.emailNotConfirmed,
        );

      case 'phone_not_confirmed':
        return const AppException(
          AppConstants.phoneNotConfirmed,
        );

      case 'signup_disabled':
        return const AppException(
          AppConstants.signupDisabled,
        );

      case 'email_provider_disabled':
        return const AppException(
          AppConstants.emailProviderDisabled,
        );

      case 'phone_provider_disabled':
        return const AppException(
          AppConstants.phoneProviderDisabled,
        );

    
    // OTP
    

      case 'otp_expired':
        return const AppException(
          AppConstants.otpExpired,
        );

      case 'otp_disabled':
        return const AppException(
          AppConstants.otpDisabled,
        );

      case 'captcha_failed':
        return const AppException(
          AppConstants.captchaFailed,
        );

    
    // SESSION
    

      case 'session_not_found':
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return const AppException(
          AppConstants.sessionExpired,
        );

    
    // RATE LIMIT
    

      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return const AppException(
          AppConstants.rateLimitExceeded,
        );

    
    // POSTGRES / DATABASE
    

    // Unique constraint
      case '23505':
        return const AppException(
          AppConstants.recordAlreadyExists,
        );

    // Foreign key
      case '23503':
        return const AppException(
          AppConstants.foreignKeyViolation,
        );

    // NOT NULL
      case '23502':
        return const AppException(
          AppConstants.notNullViolation,
        );

    // Permission / RLS
      case '42501':
        return const AppException(
          AppConstants.permissionDeniedAction,
        );

    // PostgREST single record not found
      case 'pgrst116':
        return const AppException(
          AppConstants.recordNotFound,
        );

    
    // BLUETOOTH / PRINTER
    

      case 'bluetooth_off':
      case 'bluetooth_disabled':
      case 'bluetooth_is_turned_off':
      case 'bluetooth_not_enabled':
      case 'bluetooth_unavailable':
        return const AppException(
          AppConstants.bluetoothOff,
        );

      case 'bluetooth_permission_denied':
      case 'bluetooth_scan_permission_denied':
      case 'bluetooth_connect_permission_denied':
        return const AppException(
          AppConstants.bluetoothPermissionDenied,
        );

      case 'printer_not_found':
      case 'device_not_found':
        return const AppException(
          AppConstants.printerNotFound,
        );

      case 'printer_connection_failed':
      case 'connection_failed':
        return const AppException(
          AppConstants.printerConnectionFailed,
        );

      case 'printer_disconnected':
      case 'device_disconnected':
        return const AppException(
          AppConstants.printerDisconnected,
        );

      case 'printer_print_failed':
      case 'printing_failed':
      case 'print_failed':
        return const AppException(
          AppConstants.printerPrintFailed,
        );

      default:
        return const AppException();
    }
  }

  // MAIN EXCEPTION CONVERTER

  /// Converts different exception types into one AppException.
  factory AppException.fromException(
      dynamic exception,
      ) {
    // Already converted
    if (exception is AppException) {
      return exception;
    }

    // SUPABASE AUTH
    if (exception is AuthException) {
      final code = exception.code;

      if (code != null) {
        final mapped =
        AppException.fromCode(code);

        if (!_isDefaultMessage(
          mapped.message,
        )) {
          return mapped;
        }
      }

      if (exception.message.isNotEmpty) {
        return AppException(
          exception.message,
        );
      }

      return const AppException(
        AppConstants.authFailed,
      );
    }

    // SUPABASE DATABASE

    if (exception is PostgrestException) {
      if (exception.code != null) {
        final mapped =
        AppException.fromCode(
          exception.code!,
        );

        if (!_isDefaultMessage(
          mapped.message,
        )) {
          return mapped;
        }
      }

      if (exception.message.isNotEmpty) {
        return AppException(
          exception.message,
        );
      }

      return const AppException(
        AppConstants.databaseError,
      );
    }

    
    // NETWORK
    

    if (exception is SocketException) {
      return const AppException(
        AppConstants.noInternetError,
      );
    }

    if (exception is TimeoutException) {
      return const AppException(
        AppConstants.requestTimeout,
      );
    }

    
    // PRINTER / BLUETOOTH
    //
    // IMPORTANT:
    // Check this BEFORE generic PlatformException because
    // thermal printer plugins may throw PlatformException with
    // useful Bluetooth information in message/details.
    

    final printerException =
    _fromPrinterMessage(
      exception.toString(),
    );

    if (printerException != null) {
      return printerException;
    }

    
    // FLUTTER PLATFORM
    

    if (exception is PlatformException) {
      return _fromPlatformException(
        exception,
      );
    }

    
    // FORMAT
    

    if (exception is FormatException) {
      return const AppException(
        AppConstants.invalidDataFormat,
      );
    }

    
    // GENERIC EXCEPTION WITH MESSAGE
    

    try {
      final msg = exception.message;

      if (msg != null &&
          msg is String &&
          msg.isNotEmpty) {
        // Check printer message again because some plugin
        // exceptions expose a .message property.
        final printerError =
        _fromPrinterMessage(msg);

        if (printerError != null) {
          return printerError;
        }

        return AppException(msg);
      }
    } catch (_) {}

    
    // STRING
    

    if (exception is String &&
        exception.isNotEmpty) {
      final printerError =
      _fromPrinterMessage(exception);

      if (printerError != null) {
        return printerError;
      }

      return AppException(exception);
    }

    
    // UNKNOWN
    

    return const AppException();
  }

  // PRINTER / BLUETOOTH MESSAGE MAPPER

  static AppException? _fromPrinterMessage(
      String message,
      ) {
    final msg =
    message.toLowerCase().trim();

    // ----------------------------------------------------------
    // Bluetooth OFF
    // ----------------------------------------------------------

    if (msg.contains(
      'bluetooth is turned off',
    ) ||
        msg.contains(
          'bluetooth turned off',
        ) ||
        msg.contains(
          'bluetooth is off',
        ) ||
        msg.contains(
          'bluetooth disabled',
        ) ||
        msg.contains(
          'bluetooth is disabled',
        ) ||
        msg.contains(
          'bluetooth not enabled',
        ) ||
        msg.contains(
          'bluetooth adapter is off',
        )) {
      return const AppException(
        AppConstants.bluetoothOff,
      );
    }

    // Bluetooth permission

    if ((msg.contains('bluetooth') ||
        msg.contains(
          'bluetooth_scan',
        ) ||
        msg.contains(
          'bluetooth_connect',
        )) &&
        (msg.contains('permission') ||
            msg.contains('denied'))) {
      return const AppException(
        AppConstants
            .bluetoothPermissionDenied,
      );
    }

    // Printer not found

    if (msg.contains(
      'printer not found',
    ) ||
        msg.contains(
          'device not found',
        ) ||
        msg.contains(
          'no printer found',
        )) {
      return const AppException(
        AppConstants.printerNotFound,
      );
    }

    // Printer disconnected
    // Check BEFORE generic connection failure.

    if (msg.contains(
      'printer disconnected',
    ) ||
        msg.contains(
          'device disconnected',
        ) ||
        msg.contains(
          'printer is not connected',
        ) ||
        msg.contains(
          'printer not connected',
        )) {
      return const AppException(
        AppConstants.printerDisconnected,
      );
    }

    // ----------------------------------------------------------
    // Printer connection failed
    // ----------------------------------------------------------

    if (msg.contains(
      'connection failed',
    ) ||
        msg.contains(
          'failed to connect',
        ) ||
        msg.contains(
          'unable to connect',
        ) ||
        msg.contains(
          'could not connect',
        )) {
      return const AppException(
        AppConstants
            .printerConnectionFailed,
      );
    }

    // ----------------------------------------------------------
    // Print failed
    // ----------------------------------------------------------

    if (msg.contains(
      'print failed',
    ) ||
        msg.contains(
          'printing failed',
        ) ||
        msg.contains(
          'failed to print',
        ) ||
        msg.contains(
          'unable to print',
        )) {
      return const AppException(
        AppConstants.printerPrintFailed,
      );
    }

    return null;
  }


  static AppException _fromPlatformException(
      PlatformException exception,
      ) {
    // First try known code
    final mappedCode =
    AppException.fromCode(
      exception.code,
    );

    if (!_isDefaultMessage(
      mappedCode.message,
    )) {
      return mappedCode;
    }

    // Check code + message + details for printer errors
    final printerException =
    _fromPrinterMessage(
      '${exception.code} '
          '${exception.message ?? ''} '
          '${exception.details ?? ''}',
    );

    if (printerException != null) {
      return printerException;
    }

    switch (
    exception.code.toLowerCase()) {
      case 'permission_denied':
        return const AppException(
          AppConstants
              .permissionDeniedDevice,
        );

      case 'camera_access_denied':
        return const AppException(
          AppConstants
              .cameraPermissionDenied,
        );

      case 'camera_unavailable':
        return const AppException(
          AppConstants.cameraUnavailable,
        );

      case 'storage_permission_denied':
        return const AppException(
          AppConstants
              .storagePermissionDenied,
        );

      default:
        return const AppException(
          AppConstants.deviceError,
        );
    }
  }

  // HELPER
  static bool _isDefaultMessage(
      String message,
      ) {
    return message ==
        AppConstants.defaultErrorMessage;
  }

  @override
  String toString() => message;
}