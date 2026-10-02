import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  LocalAuthService._();

  static final LocalAuthService instance = LocalAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Checks whether this device supports local authentication.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometric device support error: $e');
      return false;
    }
  }

  /// Checks whether biometric authentication can be used.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Can check biometrics error: $e');
      return false;
    }
  }

  /// Returns biometrics currently available/enrolled on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get available biometrics error: $e');
      return [];
    }
  }

  /// True when the device supports biometrics and at least one
  /// biometric method is enrolled.
  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();

      if (!supported) {
        return false;
      }

      final biometrics = await _localAuth.getAvailableBiometrics();

      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Biometric availability error: $e');
      return false;
    }
  }

  /// Authenticate using fingerprint / face biometric.
  ///
  /// Returns true only when authentication succeeds.
  Future<bool> authenticate({
    String reason = 'Authenticate to continue to StockPulse',
  }) async {
    try {
      final available = await isBiometricAvailable();

      if (!available) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      debugPrint(
        'LocalAuthException: ${e.code} - ${e.description}',
      );
      return false;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');

      return false;
    }
  }

  /// Cancels an authentication request if one is active.
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('Stop biometric authentication error: $e');
    }
  }
}