import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/exceptional/platform_exceptions.dart';
import 'package:image_picker/image_picker.dart';
import '../common/route/app_routes.dart';

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


  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

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

  Future<void> _syncProfileToDatabase({
    required String userId,
    required String name,
    String? email,
    String? imageUrl,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final profileData = <String, dynamic>{
      'id': userId,
      'name': name.trim(),
      'full_name': name.trim(),
      if (email != null && email.isNotEmpty) 'email': email.trim(),
      if (imageUrl != null && imageUrl.isNotEmpty) ...{
        'profile_img': imageUrl,
        'avatar_url': imageUrl,
      },
      'updated_at': now,
    };

    try {
      await _supabase.from('profiles').upsert(
        profileData,
        onConflict: 'id',
      );
    } catch (e) {
      debugPrint('Error upserting to profiles table: $e');
      try {
        await _supabase.from('profiles').upsert({
          'id': userId,
          'name': name.trim(),
          if (imageUrl != null && imageUrl.isNotEmpty) 'profile_img': imageUrl,
          'updated_at': now,
        }, onConflict: 'id');
      } catch (fallbackError) {
        debugPrint('Fallback error upserting to profiles table: $fallbackError');
      }
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error fetching from profiles table: $e');
      return null;
    }
  }

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    XFile? image,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
    );

    if (response.user != null) {
      String? imageUrl;
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
                'profile_img': imageUrl,
                'avatar_url': imageUrl,
              },
            ),
          );
        } catch (e) {
          debugPrint('Error uploading profile image during signup: $e');
        }
      }

      await _syncProfileToDatabase(
        userId: response.user!.id,
        name: name,
        email: email,
        imageUrl: imageUrl,
      );
    }

    return response;
  }

  Future<UserResponse> updateProfile({
    required String name,
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

    final metadata = Map<String, dynamic>.from(user.userMetadata ?? {});
    metadata['name'] = name.trim();
    metadata['full_name'] = name.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      metadata['profile_img'] = imageUrl;
      metadata['avatar_url'] = imageUrl;
    }

    final response = await _supabase.auth.updateUser(UserAttributes(data: metadata));

    await _syncProfileToDatabase(
      userId: user.id,
      name: name,
      email: user.email,
      imageUrl: imageUrl,
    );

    return response;
  }

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

  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'com.autosmart.stockpulse://reset-password',
    );
  }

  /// Verify password recovery token from email deep link
  Future<AuthResponse> verifyRecoveryToken(String tokenHash) async {
    if (tokenHash.trim().isEmpty) {
      throw const AppException('Invalid password reset link.');
    }

    return await _supabase.auth.verifyOTP(
      tokenHash: tokenHash.trim(),
      type: OtpType.recovery,
    );
  }

  Future<void> resetPassword(String newPassword) async {

    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    //first logout
    await _supabase.auth.signOut();
    // Get.offAllNamed(Routes.login);
  }

  User? get currentUser => _supabase.auth.currentUser;

  Session? get currentSession => _supabase.auth.currentSession;

  bool get isLoggedIn => currentSession != null;
}
