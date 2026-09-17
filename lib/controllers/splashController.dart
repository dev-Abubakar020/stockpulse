import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  var visible = true.obs;
  final LocalStorageService storage = Get.find<LocalStorageService>();
  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    _startFade();
    _navigate();
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(getInitialRoute());
  }

  static String getInitialRoute() {
    final storage = Get.find<LocalStorageService>();

    if (storage.isFirstTime()) {
      return Routes.onboarding;
    }

    final session = Supabase.instance.client.auth.currentSession;
    final bool isAuthenticated = session != null || storage.isLoggedIn();

    if (isAuthenticated) {
      return Routes.dashboard;
    } else {
      return Routes.login;
    }
  }

  void _startFade() async {
    while (!_disposed) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_disposed) visible.toggle();
    }
  }
}
