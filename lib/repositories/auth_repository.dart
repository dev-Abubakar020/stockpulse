import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../models/profile_model.dart';
import '../services/local_storage_service.dart';
import '../services/session_cleanup_service.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final Future<void> _googleInitialization;

  AuthRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client,
      _googleInitialization = GoogleSignIn.instance.initialize(
        serverClientId: AppConstants.googleWebClientId,
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? AppConstants.googleIosClientId
            : null,
      );

  // ============================================================
  // LOGIN
  // ============================================================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<String> uploadProfileImage({
    required String userId,
    required XFile image,
  }) async {
    final extension = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : 'jpg';

    final path =
        '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from('shop-images')
        .uploadBinary(
          path,
          await image.readAsBytes(),
          fileOptions: FileOptions(
            contentType: 'image/$extension',
            upsert: true,
          ),
        );

    return _supabase.storage.from('shop-images').getPublicUrl(path);
  }

  // ============================================================
  // SYNC PROFILE TO DATABASE
  // ============================================================

  Future<void> syncProfileToDatabase({
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? imageUrl,
  }) async {
    try {
      final profile = ProfileModel(
        id: userId,
        fullName: name.trim(),
        phone: phone,
        profileImg: imageUrl,
      );

      await _supabase
          .from('profiles')
          .upsert(profile.toJson(), onConflict: 'id');
    } catch (e) {
      debugPrint('Error syncing profiles table: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return ProfileModel.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching from profiles table: $e');
      return null;
    }
  }

  // ============================================================
  // SIGNUP
  // ============================================================

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    XFile? image,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'full_name': name.trim(),
        'phone': phone.trim(),
      },
    );

    if (response.user != null) {
      String? imageUrl;

      // --------------------------------------------------------
      // Upload profile image
      // --------------------------------------------------------

      if (image != null) {
        try {
          imageUrl = await uploadProfileImage(
            userId: response.user!.id,
            image: image,
          );

          await _supabase.auth.updateUser(
            UserAttributes(
              data: {
                'name': name.trim(),
                'full_name': name.trim(),
                'phone': phone.trim(),
                'profile_img': imageUrl,
                'avatar_url': imageUrl,
              },
            ),
          );
        } catch (e) {
          debugPrint('Error uploading profile image during signup: $e');
        }
      }

      // --------------------------------------------------------
      // Save profile in profiles table
      // --------------------------------------------------------

      await syncProfileToDatabase(
        userId: response.user!.id,
        name: name,
        phone: phone,
        imageUrl: imageUrl,
      );
    }

    return response;
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> updateProfile({
    required String name,
    required String phone,
    XFile? image,
    String? existingImageUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AppException('User is not authenticated.');
    }

    String? imageUrl = existingImageUrl;

    if (image != null) {
      imageUrl = await uploadProfileImage(userId: user.id, image: image);
    }

    await syncProfileToDatabase(
      userId: user.id,
      name: name,
      phone: phone,
      imageUrl: imageUrl,
    );
  }
  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<AuthResponse?> signInWithGoogle() async {
    await _googleInitialization;

    final googleUser = await GoogleSignIn.instance.authenticate();

    final idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const AppException(
        'Google Sign-In failed. No authentication token was received.',
      );
    }

    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  // ============================================================
  // SEND PHONE OTP
  // ============================================================

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await fb.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (fb.PhoneAuthCredential credential) {},

      verificationFailed: (fb.FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },

      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // ============================================================
  // VERIFY PHONE OTP
  // ============================================================

  Future<fb.UserCredential> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    if (userCredential.user == null) {
      throw StateError('Firebase did not return an authenticated user');
    }

    return userCredential;
  }

  // ============================================================
  // PASSWORD RECOVERY STATE
  // ============================================================

  bool _hasVerifiedRecovery = false;
  String? _verifiedRecoveryUserId;

  bool get hasVerifiedRecovery => _hasVerifiedRecovery;

  String? get verifiedRecoveryUserId => _verifiedRecoveryUserId;

  // ============================================================
  // SEND PASSWORD RESET EMAIL
  // ============================================================

  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'com.autosmart.stockpulse://reset-password',
    );
  }

  // ============================================================
  // VERIFY PASSWORD RECOVERY TOKEN
  // ============================================================

  Future<AuthResponse> verifyRecoveryToken(String tokenHash) async {
    if (tokenHash.trim().isEmpty) {
      _hasVerifiedRecovery = false;
      _verifiedRecoveryUserId = null;

      throw const AppException('Invalid password reset link.');
    }

    try {
      // Clear stale user session
      clearUserSessionData();

      final response = await _supabase.auth.verifyOTP(
        tokenHash: tokenHash.trim(),
        type: OtpType.recovery,
      );

      if (response.user == null || response.session == null) {
        _hasVerifiedRecovery = false;
        _verifiedRecoveryUserId = null;

        throw const AuthException('Unable to verify password reset link.');
      }

      _hasVerifiedRecovery = true;
      _verifiedRecoveryUserId = response.user!.id;

      try {
        Get.find<LocalStorageService>().setRecoveryInProgress(true);
      } catch (_) {}

      debugPrint(
        'Recovery verified successfully for user ID: '
        '$_verifiedRecoveryUserId',
      );

      return response;
    } catch (e) {
      _hasVerifiedRecovery = false;
      _verifiedRecoveryUserId = null;

      try {
        Get.find<LocalStorageService>().setRecoveryInProgress(false);
      } catch (_) {}

      rethrow;
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> resetPassword(String newPassword) async {
    final currentUser = _supabase.auth.currentUser;

    if (!_hasVerifiedRecovery ||
        currentUser == null ||
        currentUser.id != _verifiedRecoveryUserId) {
      _hasVerifiedRecovery = false;
      _verifiedRecoveryUserId = null;

      try {
        Get.find<LocalStorageService>().setRecoveryInProgress(false);
      } catch (_) {}

      throw const AppException(
        'Password recovery session is invalid or has expired.',
      );
    }

    await _supabase.auth.updateUser(UserAttributes(password: newPassword));

    _hasVerifiedRecovery = false;
    _verifiedRecoveryUserId = null;

    try {
      Get.find<LocalStorageService>().setRecoveryInProgress(false);
    } catch (_) {}

    await _supabase.auth.signOut();

    clearUserSessionData();
  }

  // ============================================================
  // CLEAR RECOVERY STATE
  // ============================================================

  void clearRecoveryState() {
    _hasVerifiedRecovery = false;
    _verifiedRecoveryUserId = null;

    try {
      Get.find<LocalStorageService>().setRecoveryInProgress(false);
    } catch (_) {}

    clearUserSessionData();
  }

  // ============================================================
  // AUTH GETTERS
  // ============================================================

  User? get currentUser => _supabase.auth.currentUser;

  Session? get currentSession => _supabase.auth.currentSession;

  bool get isLoggedIn => currentSession != null;
}
