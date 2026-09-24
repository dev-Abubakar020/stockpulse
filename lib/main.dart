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
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:stockpulse/views/authScreens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Get.put(
    LocalStorageService(),
    permanent: true,
  );

  // Network Manager
  Get.put(
    NetworkManager(),
    permanent: true,
  );

  // Decide where app should start
  final initialRoute = await getInitialRoute();

  runApp(
    MyApp(
      initialRoute: initialRoute,
    ),
  );

  FlutterNativeSplash.remove();
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
    // App already running → link clicked
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {
        _handleDeepLink(uri);
      },
      onError: (error) {
        debugPrint('Deep Link Error: $error');
      },
    );

    // App closed → opened from recovery link
    try {
      final initialUri = await _appLinks.getInitialLink();

      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Initial Deep Link Error: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Incoming Deep Link: $uri');

    // Ignore unrelated links
    if (uri.scheme != 'com.autosmart.stockpulse' ||
        uri.host != 'reset-password') {
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
      debugPrint('Verifying password recovery token...');

      final response =
      await Supabase.instance.client.auth.verifyOTP(
        tokenHash: tokenHash,
        type: OtpType.recovery,
      );

      if (response.user == null ||
          response.session == null) {
        throw const AuthException(
          'Unable to verify password reset link.',
        );
      }

      debugPrint(
        'Recovery user verified: ${response.user!.email}',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.resetPassword);
      });
    } on AuthException catch (e) {
      debugPrint('Recovery Auth Error: $e');

      _showRecoveryError(
        'This password reset link is invalid or has expired. '
            'Please request a new one.',
      );
    } catch (e) {
      debugPrint('Recovery Error: $e');

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
  // AUTH / DEEP LINK ERROR
  // ============================================================

  void _handleAuthError(Object error) {
    debugPrint('Supabase Auth Error: $error');

    if (error is! AuthException) return;

    final message = error.message.toLowerCase();

    final isExpiredLink =
        error.code == 'access_denied' ||
            error.statusCode == 'otp_expired' ||
            message.contains('email link is invalid or has expired');

    if (isExpiredLink && !_isAuthErrorShowing) {
      _isAuthErrorShowing = true;
      _showExpiredLinkWarning();
    }
  }

  // ============================================================
  // EXPIRED LINK
  // ============================================================

  void _showExpiredLinkWarning() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Don't navigate again if already on login
      if (Get.currentRoute != Routes.login) {
        Get.offAllNamed(Routes.login);
      }

      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          if (!mounted) return;

          CustomSnackBar.warningSnackBar(
            title: AppConstants.warningTitle,
            message: AppConstants.emailLinkExpiredMsg,
          );
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