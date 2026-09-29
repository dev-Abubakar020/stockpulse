import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/role_service.dart';
import 'package:stockpulse/services/session_cleanup_service.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isRecoveryProcessing = false;
  bool _isAuthErrorShowing = false;
  bool _isStaffInviteProcessing = false;
  String? pendingStaffInvitationToken;

  bool get isStaffInviteFlow =>
      pendingStaffInvitationToken?.isNotEmpty == true;
  void clearStaffInvitation() {
    pendingStaffInvitationToken = null;
  }

  @override
  void onInit() {
    super.onInit();
    _initStream();
  }

  void _initStream() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (error) => debugPrint('Deep Link Error: $error'),
    );
  }

  bool isRecoveryUri(Uri uri) {
    return uri.scheme == 'https' &&
        uri.host == 'www.rishtajourney.com' &&
        uri.path == '/reset-password' &&
        uri.queryParameters['token_hash']?.isNotEmpty == true &&
        uri.queryParameters['type'] == 'recovery';
  }

  bool isStaffInviteUri(Uri uri) {
    return uri.scheme == 'https' &&
        uri.host == 'www.rishtajourney.com' &&
        uri.path == '/staff-invite' &&
        uri.queryParameters['token']?.isNotEmpty == true;
  }

  Future<String> determineInitialRoute() async {
    final storage = Get.find<LocalStorageService>();
    final authRepo = Get.find<AuthRepository>();
    String initialRoute = Routes.login;
    bool recoveryLinkProcessed = false;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        if (isRecoveryUri(initialUri)) {
          final tokenHash = initialUri.queryParameters['token_hash']!;
          await authRepo.verifyRecoveryToken(tokenHash);
          storage.setRecoveryInProgress(true);
          initialRoute = Routes.resetPassword;
          recoveryLinkProcessed = true;
        } else if (isStaffInviteUri(initialUri)) {
          pendingStaffInvitationToken = initialUri.queryParameters['token']!;
          debugPrint('COLD START STAFF INVITE DEEP LINK DETECTED: $pendingStaffInvitationToken');
          initialRoute = Routes.register;
          recoveryLinkProcessed = true;
        }
      }
    } catch (e) {
      debugPrint('Cold-start Deep Link Error: $e');
      authRepo.clearRecoveryState();
      storage.setRecoveryInProgress(false);
      clearUserSessionData();
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      initialRoute = Routes.login;
      recoveryLinkProcessed = false;
    }

    if (!recoveryLinkProcessed) {
      if (storage.isRecoveryInProgress()) {
        authRepo.clearRecoveryState();
        storage.setRecoveryInProgress(false);
        clearUserSessionData();
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {}
        initialRoute = Routes.login;
      } else {
        initialRoute = await _getInitialRoute();
      }
    }

    return initialRoute;
  }

  Future<String> _getInitialRoute() async {
    final storage = Get.find<LocalStorageService>();
    if (storage.isFirstTime()) {
      return Routes.onboarding;
    }
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return Routes.login;
    }

    final roleService = Get.isRegistered<RoleService>()
        ? Get.find<RoleService>()
        : Get.put(RoleService(), permanent: true);

    await roleService.fetchMembership();

    if (roleService.hasMembership.value) {
      if (roleService.isStaff && !roleService.isActive.value) {
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {}
        return Routes.login;
      }
      return Routes.dashboard;
    }

    final shopRepository = Get.isRegistered<ShopRepository>()
        ? Get.find<ShopRepository>()
        : ShopRepository();
    final hasShop = await shopRepository.currentUserHasShop();
    if (!hasShop) {
      return Routes.createShop;
    }
    return Routes.dashboard;
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (isRecoveryUri(uri)) {
      await _handleRecoveryLink(uri);
      return;
    }

    if (isStaffInviteUri(uri)) {
      await _handleStaffInvite(uri);
      return;
    }
  }

  Future<void> _handleRecoveryLink(Uri uri) async {
    if (_isRecoveryProcessing) return;

    final tokenHash = uri.queryParameters['token_hash'];
    final type = uri.queryParameters['type'];

    if (tokenHash == null ||
        tokenHash.isEmpty ||
        type != 'recovery') {
      _showRecoveryError(
        'Invalid password reset link.',
      );
      return;
    }

    _isRecoveryProcessing = true;

    try {
      final authRepo = Get.find<AuthRepository>();
      await authRepo.verifyRecoveryToken(tokenHash);
      Get.find<LocalStorageService>().setRecoveryInProgress(true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != Routes.resetPassword) {
          Get.offAllNamed(Routes.resetPassword);
        }
      });
    } on AuthException catch (e) {
      debugPrint('Recovery Auth Error: $e');
      try {
        final authRepo = Get.find<AuthRepository>();
        authRepo.clearRecoveryState();
        Get.find<LocalStorageService>().setRecoveryInProgress(false);
        clearUserSessionData();
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      _showRecoveryError(AppConstants.recError);
    } catch (e) {
      debugPrint('Recovery Error: $e');
      try {
        final authRepo = Get.find<AuthRepository>();
        authRepo.clearRecoveryState();
        Get.find<LocalStorageService>().setRecoveryInProgress(false);
        clearUserSessionData();
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      _showRecoveryError(
        AppConstants.unableToSentLink,
      );
    } finally {
      _isRecoveryProcessing = false;
    }
  }

  Future<void> _handleStaffInvite(Uri uri) async {
    if (_isStaffInviteProcessing) return;

    final token = uri.queryParameters['token'];

    if (token == null || token.isEmpty) {
      CustomSnackBar.warningSnackBar(
        title: 'Invalid Invitation',
        message: 'Staff invitation link is invalid.',
      );
      return;
    }
    _isStaffInviteProcessing = true;

    try {
      pendingStaffInvitationToken = token;
      debugPrint('WARM START STAFF INVITE DEEP LINK DETECTED: $pendingStaffInvitationToken');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(
          Routes.register,
          arguments: {
            'invitationToken': token,
          },
        );
      });
    } finally {
      _isStaffInviteProcessing = false;
    }
  }

  void _showRecoveryError(String message) {
    if (_isAuthErrorShowing) return;
    _isAuthErrorShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != Routes.login) {
        Get.offAllNamed(Routes.login);
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.warningTitle,
          message: message,
        );
        _isAuthErrorShowing = false;
      });
    });
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
