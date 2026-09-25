import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/bindings/initialBinding.dart';
import 'package:stockpulse/common/route/app_pages.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/app_theme.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';
import 'package:stockpulse/firebase_options.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:stockpulse/views/authScreens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:stockpulse/services/session_cleanup_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep native splash visible while initializing services
  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );

  // Local Storage
  await LocalStorageService.init();

  final storage = Get.put(
    LocalStorageService(),
    permanent: true,
  );

  // Network Manager
  Get.put(
    NetworkManager(),
    permanent: true,
  );

  // Auth Repository
  final authRepo = Get.put<AuthRepository>(
    AuthRepository(),
    permanent: true,
  );

  // Cold-start deep link check (Owner of initial recovery-link processing)
  String initialRoute = Routes.login;
  bool recoveryLinkProcessed = false;

  try {
    final appLinks = AppLinks();
    final initialUri = await appLinks.getInitialLink();

    if (initialUri != null) {
      debugPrint('Cold-start Deep Link: scheme=${initialUri.scheme}, host=${initialUri.host}, path=${initialUri.path}, hasTokenHash=${initialUri.queryParameters['token_hash'] != null}, type=${initialUri.queryParameters['type']}');

      if (_isRecoveryUri(initialUri)) {
        final tokenHash = initialUri.queryParameters['token_hash']!;
        debugPrint('Processing cold-start recovery token hash...');
        await authRepo.verifyRecoveryToken(tokenHash);
        storage.setRecoveryInProgress(true);
        initialRoute = Routes.resetPassword;
        recoveryLinkProcessed = true;
        debugPrint('Cold-start recovery verification succeeded. Initial route set to resetPassword.');
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

  // If no recovery link was processed, check if an incomplete recovery session existed (app killed during recovery)
  if (!recoveryLinkProcessed) {
    if (storage.isRecoveryInProgress()) {
      debugPrint('Detected incomplete recovery session from previous run (app killed). Cleaning up...');
      authRepo.clearRecoveryState();
      storage.setRecoveryInProgress(false);
      clearUserSessionData();
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      initialRoute = Routes.login;
    } else {
      initialRoute = await getInitialRoute();
    }
  }

  runApp(
    MyApp(
      initialRoute: initialRoute,
    ),
  );

  FlutterNativeSplash.remove();
}

bool _isRecoveryUri(Uri uri) {
  return uri.scheme == 'https' &&
      uri.host == 'www.rishtajourney.com' &&
      uri.path == '/reset-password' &&
      uri.queryParameters['token_hash']?.isNotEmpty == true &&
      uri.queryParameters['type'] == 'recovery';
}

// ============================================================
// APP
// ============================================================

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;

  final AppLinks _appLinks = AppLinks();

  bool _isRecoveryProcessing = false;
  bool _isAuthErrorShowing = false;

  @override
  void initState() {
    super.initState();

    _initializeDeepLinks();
  }

  // ============================================================
  // SUPABASE AUTH LISTENER
  // ============================================================

  Future<void> _initializeDeepLinks() async {
    // App already running → link clicked via stream
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {
        _handleDeepLink(uri);
      },
      onError: (error) {
        debugPrint('Deep Link Error: $error');
      },
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Incoming Deep Link: scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}, hasTokenHash=${uri.queryParameters['token_hash'] != null}, type=${uri.queryParameters['type']}');

    if (!_isRecoveryUri(uri)) {
      return;
    }

    if (_isRecoveryProcessing) return;

    final tokenHash = uri.queryParameters['token_hash'];
    final type = uri.queryParameters['type'];

    if (tokenHash == null ||
        tokenHash.isEmpty ||
        type != 'recovery') {
      _showRecoveryError('Invalid password reset link.');
      return;
    }

    _isRecoveryProcessing = true;

    try {
      debugPrint('Verifying password recovery token from stream...');

      final authRepo = Get.find<AuthRepository>();
      await authRepo.verifyRecoveryToken(tokenHash);
      Get.find<LocalStorageService>().setRecoveryInProgress(true);

      debugPrint('Recovery user verified successfully.');

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

      _showRecoveryError(
        'This password reset link is invalid or has expired. '
            'Please request a new one.',
      );
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
        'Unable to verify password reset link. '
            'Please request a new one.',
      );
    } finally {
      _isRecoveryProcessing = false;
    }
  }

  // ============================================================
  // AUTH STATE
  // ============================================================

  void _showRecoveryError(String message) {
    if (_isAuthErrorShowing) return;

    _isAuthErrorShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (Get.currentRoute != Routes.login) {
        Get.offAllNamed(Routes.login);
      }

      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          if (!mounted) return;

          CustomSnackBar.warningSnackBar(
            title: AppConstants.warningTitle,
            message: message,
          );

          _isAuthErrorShowing = false;
        },
      );
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<LocalStorageService>();

    final savedDark = storage.isDarkMode();

    final initialThemeMode = savedDark == true
        ? ThemeMode.dark
        : ThemeMode.light;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: AppConstants.appName,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,

      // Routes
      initialRoute: widget.initialRoute,
      getPages: AppPages.pages,

      // Dependencies
      initialBinding: InitialBinding(),

      // Unknown route
      unknownRoute: GetPage(
        name: Routes.login,
        page: () => const LoginScreen(),
      ),
    );
  }
}

// ============================================================
// INITIAL ROUTE
// ============================================================

Future<String> getInitialRoute() async {
  final storage = Get.find<LocalStorageService>();

  // First time app opening
  if (storage.isFirstTime()) {
    return Routes.onboarding;
  }

  final session = Supabase.instance.client.auth.currentSession;

  // Not logged in
  if (session == null) {
    return Routes.login;
  }

  // Logged in -> check whether shop exists
  final shopRepository = ShopRepository();

  final hasShop = await shopRepository.currentUserHasShop();

  if (!hasShop) {
    return Routes.createShop;
  }

  return Routes.dashboard;
}
