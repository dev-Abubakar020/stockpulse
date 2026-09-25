import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/bindings/initialBinding.dart';
import 'package:stockpulse/common/route/app_pages.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/app_theme.dart';
import 'package:stockpulse/firebase_options.dart';
import 'package:stockpulse/repositories/auth_repository.dart';
import 'package:stockpulse/services/deep_link_service.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:stockpulse/views/authScreens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );

  await LocalStorageService.init();

  Get.put(LocalStorageService(), permanent: true);
  Get.put(NetworkManager(), permanent: true);
  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  final deepLinkService = Get.put(DeepLinkService(), permanent: true);

  final initialRoute = await deepLinkService.determineInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<LocalStorageService>();
    final savedDark = storage.isDarkMode();
    final initialThemeMode = savedDark == true ? ThemeMode.dark : ThemeMode.light;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      unknownRoute: GetPage(
        name: Routes.login,
        page: () => const LoginScreen(),
      ),
    );
  }
}
