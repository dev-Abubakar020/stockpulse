import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import 'local_auth_service.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService instance = BiometricAuthService._();

  final GetStorage _box = GetStorage();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthService _localAuth = LocalAuthService.instance;

  // GetStorage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserIdKey = 'biometric_user_id';
  static const String _biometricEmailKey = 'biometric_email';

  // Secure Storage keys
  static const String _securePasswordKey = 'secure_login_password';

  bool get isBiometricEnabled => _box.read<bool>(_biometricEnabledKey) ?? false;
  String? get biometricUserId => _box.read<String>(_biometricUserIdKey);
  String? get biometricEmail => _box.read<String>(_biometricEmailKey);

  /// Check whether biometric login can be shown on login screen
  Future<bool> canUseBiometricLogin() async {
    if (!isBiometricEnabled) return false;
    if (biometricUserId == null || biometricEmail == null) return false;

    final password = await _secureStorage.read(key: _securePasswordKey);
    if (password == null || password.isEmpty) return false;

    return await _localAuth.isBiometricAvailable();
  }

  /// Enable biometric login AFTER successful login
  Future<bool> enableBiometricForCurrentUser({
    required String userId,
    required String email,
    required String password,
  }) async {
    try {
      final available = await _localAuth.isBiometricAvailable();
      if (!available) return false;

      final authenticated = await _localAuth.authenticate(
        reason: 'Use your fingerprint to verify your identity.',
      );
      if (!authenticated) return false;

      await _secureStorage.write(key: _securePasswordKey, value: password);
      await _box.write(_biometricUserIdKey, userId);
      await _box.write(_biometricEmailKey, email.trim().toLowerCase());
      await _box.write(_biometricEnabledKey, true);

      return true;
    } catch (e) {
      debugPrint('Enable biometric error: $e');
      await clearBiometricData();
      return false;
    }
  }

  /// Authenticate using biometric and return credentials
  Future<BiometricCredentials?> loginWithBiometric() async {
    try {
      if (!await canUseBiometricLogin()) return null;

      final authenticated = await _localAuth.authenticate(
        reason: 'Login to StockPulse using biometrics',
      );
      if (!authenticated) return null;

      final email = biometricEmail;
      final password = await _secureStorage.read(key: _securePasswordKey);

      if (email == null || password == null || password.isEmpty) {
        return null;
      }

      return BiometricCredentials(email: email, password: password);
    } catch (e) {
      debugPrint('Biometric login error: $e');
      return null;
    }
  }

  /// CRITICAL MULTI-USER SCENARIO:
  /// Called AFTER User B successfully logs in.
  /// Compares saved biometric user ID vs new Supabase authenticated user ID.
  /// If different, clears previous user's security data.
  Future<void> handleAuthenticatedUserChange(String newUserId) async {
    try {
      final savedUserId = biometricUserId;
      if (savedUserId != null && savedUserId != newUserId) {
        debugPrint('Different user detected ($newUserId vs saved $savedUserId). Clearing previous user security data.');
        await clearAllSavedLoginData();
      }
    } catch (e) {
      debugPrint('Handle authenticated user change error: $e');
    }
  }

  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _securePasswordKey);
      await _box.remove(_biometricEnabledKey);
      await _box.remove(_biometricUserIdKey);
      await _box.remove(_biometricEmailKey);
    } catch (e) {
      debugPrint('Disable biometric error: $e');
    }
  }

  Future<void> clearBiometricData() async {
    await disableBiometric();
  }

  Future<void> clearAllSavedLoginData() async {
    try {
      await _secureStorage.delete(key: _securePasswordKey);
      await _box.remove(_biometricEnabledKey);
      await _box.remove(_biometricUserIdKey);
      await _box.remove(_biometricEmailKey);
    } catch (e) {
      debugPrint('Clear all saved login data error: $e');
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
