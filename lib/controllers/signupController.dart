import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends GetxController {
  final AuthRepository authRepository;
  SignupController(this.authRepository);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  Future<void> _handlePostSignupNavigation() async {
    Get.find<LocalStorageService>().setLoggedIn(true);
    final hasShop = await Get.find<ShopRepository>().currentUserHasShop();
    if (hasShop) {
      Get.offAllNamed(Routes.dashboard);
    } else {
      Get.offAllNamed(Routes.createShop);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final response = await authRepository.signInWithGoogle();
      if (response != null && response.user != null) {
        await _handlePostSignupNavigation();
      }
    } on AuthException catch (e) {
      Get.snackbar('Google Sign-In Failed', e.message);
    } catch (e) {
      Get.snackbar('Google Sign-In Failed', e.toString());
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty) {
      Get.snackbar('Signup Failed', 'Please enter your name');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Signup Failed', 'Please enter a valid email address');
      return;
    }

    if (password.length < 8) {
      Get.snackbar('Signup Failed', 'Password must be at least 8 characters');
      return;
    }

    try {
      isLoading.value = true;
      final response = await authRepository.signup(
        name: name,
        email: email,
        password: password,
      );

      if (response.user == null) {
        Get.snackbar(
          'Check your email',
          'Your account was created. Confirm your email before signing in.',
        );
      } else if (response.session == null) {
        Get.snackbar(
          'Check your email',
          'Your account was created. Confirm your email before signing in.',
        );
        Get.offAllNamed(Routes.login);
      } else {
        await _handlePostSignupNavigation();
      }
    } catch (error) {
      Get.snackbar('Signup Failed', 'error');
    }  finally {
      isLoading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.toggle();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.toggle();
  }
}
