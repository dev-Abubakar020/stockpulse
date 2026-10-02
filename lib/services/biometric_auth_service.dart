import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import 'local_auth_service.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService instance =
  BiometricAuthService._();

  final GetStorage _box = GetStorage();

  final FlutterSecureStorage _secureStorage =
  const FlutterSecureStorage();

  final LocalAuthService _localAuth =
      LocalAuthService.instance;

  // GetStorage keys
  static const String _biometricEnabledKey =
      'biometric_enabled';

  static const String _biometricUserIdKey =
      'biometric_user_id';

  static const String _biometricEmailKey =
      'biometric_email';

  // Secure Storage key
  static const String _biometricPasswordKey =
      'biometric_password';

  bool get isBiometricEnabled =>
      _box.read<bool>(_biometricEnabledKey) ?? false;

  String? get biometricUserId =>
      _box.read<String>(_biometricUserIdKey);

  String? get biometricEmail =>
      _box.read<String>(_biometricEmailKey);

  /// Should fingerprint button be shown on login screen?
  Future<bool> canUseBiometricLogin() async {
    if (!isBiometricEnabled) {
      return false;
    }

    if (biometricUserId == null ||
        biometricEmail == null) {
      return false;
    }

    final password = await _secureStorage.read(
      key: _biometricPasswordKey,
    );

    if (password == null || password.isEmpty) {
      return false;
    }

    return await _localAuth.isBiometricAvailable();
  }

  /// Called AFTER normal Supabase login.
  ///
  /// User must already be authenticated before this method
  /// is called.
  Future<bool> enableBiometric({
    required String userId,
    required String email,
    required String password,
  }) async {
    try {
      final available =
      await _localAuth.isBiometricAvailable();

      if (!available) {
        return false;
      }

      final authenticated =
      await _localAuth.authenticate(
        reason:
        'Verify your identity to enable biometric login',
      );

      if (!authenticated) {
        return false;
      }

      await _secureStorage.write(
        key: _biometricPasswordKey,
        value: password,
      );

      await _box.write(
        _biometricUserIdKey,
        userId,
      );

      await _box.write(
        _biometricEmailKey,
        email.trim().toLowerCase(),
      );

      // Write this last so incomplete setup cannot appear enabled.
      await _box.write(
        _biometricEnabledKey,
        true,
      );

      return true;
    } catch (e) {
      debugPrint('Enable biometric error: $e');

      // Avoid partially configured biometric login.
      await clearBiometricData();

      return false;
    }
  }

  /// Authenticate fingerprint and return credentials.
  ///
  /// Supabase login will be performed by LoginController /
  /// AuthRepository, not this storage service.
  Future<BiometricCredentials?>
  getCredentialsAfterAuthentication() async {
    try {
      if (!await canUseBiometricLogin()) {
        return null;
      }

      final authenticated =
      await _localAuth.authenticate(
        reason: 'Login to StockPulse',
      );

      if (!authenticated) {
        return null;
      }

      final email = biometricEmail;

      final password = await _secureStorage.read(
        key: _biometricPasswordKey,
      );

      if (email == null ||
          password == null ||
          password.isEmpty) {
        return null;
      }

      return BiometricCredentials(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Biometric credential error: $e');
      return null;
    }
  }

  /// Call AFTER another user successfully logs in.
  ///
  /// This prevents User B from inheriting User A's
  /// biometric configuration.
  Future<void> handleAuthenticatedUserChange(
      String authenticatedUserId,
      ) async {
    try {
      final savedUserId = biometricUserId;

      if (savedUserId == null) {
        return;
      }

      if (savedUserId != authenticatedUserId) {
        await clearBiometricData();

        // Next step:
        // clear Remember Me data here as well through
        // the existing Remember Me implementation.
      }
    } catch (e) {
      debugPrint('Account change handling error: $e');
    }
  }

  Future<void> disableBiometric() async {
    await clearBiometricData();
  }

  Future<void> clearBiometricData() async {
    try {
      await _secureStorage.delete(
        key: _biometricPasswordKey,
      );

      await _box.remove(_biometricEnabledKey);
      await _box.remove(_biometricUserIdKey);
      await _box.remove(_biometricEmailKey);
    } catch (e) {
      debugPrint('Clear biometric data error: $e');
    }
  }
}

class BiometricCredentials {
  final String email;
  final String password;

  const BiometricCredentials({
    required this.email,
    required this.password,
  });
}