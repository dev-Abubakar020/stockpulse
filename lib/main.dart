import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:stockpulse/common/bindings/initialBinding.dart';
import 'package:stockpulse/common/route/app_pages.dart';
import 'package:stockpulse/common/theme/app_theme.dart';
import 'package:stockpulse/firebase_options.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/route/app_routes.dart';

// Future<void> main() async {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
//
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   await Supabase.initialize(
//     url: AppConstants.supabaseUrl,
//     // ignore: deprecated_member_use
//     anonKey: AppConstants.supabaseAnonKey,
//   );
//
//   await LocalStorageService.init();
//   Get.put(LocalStorageService(), permanent: true);
//   FlutterNativeSplash.remove();
//   Get.put(NetworkManager());
//   runApp(const MyApp());
// }

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: AppConstants.supabaseAnonKey,
  );

  await LocalStorageService.init();
  Get.put(LocalStorageService(), permanent: true);
  Get.put(NetworkManager(), permanent: true);
  final initialRoute = await getInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<LocalStorageService>();
    final savedDark = storage.isDarkMode();
    final initialThemeMode = savedDark == true
        ? ThemeMode.dark
        : ThemeMode.light;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      themeMode: initialThemeMode,
      title: AppConstants.appName,
      darkTheme: AppTheme.darkTheme,
      initialBinding: InitialBinding(),
    );
  }
}

Future<String> getInitialRoute() async {
  final storage = Get.find<LocalStorageService>();
  if (storage.isFirstTime()) {
    return Routes.onboarding;
  }
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    return Routes.login;
  }

  // User logged in -> check shop
  final shopRepository = ShopRepository();
  final hasShop = await shopRepository.currentUserHasShop();

  if (!hasShop) {
    return Routes.createShop;
  }

  return Routes.dashboard;
}
