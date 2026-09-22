import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  var visible = true.obs;
  bool _disposed = false;

  final LocalStorageService storage = Get.find<LocalStorageService>();
  final ShopRepository shopRepository = ShopRepository();

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

    final route = await getInitialRoute();

    if (!_disposed) {
      Get.offAllNamed(route);
    }
  }

  Future<String> getInitialRoute() async {
    // 1. First time user
    if (storage.isFirstTime()) {
      return Routes.onboarding;
    }

    // 2. Check actual Supabase authentication
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return Routes.login;
    }

    // 3. User logged in -> check whether shop exists
    final hasShop = await shopRepository.currentUserHasShop();

    if (!hasShop) {
      return Routes.createShop;
    }

    // 4. Logged in + shop exists
    return Routes.dashboard;
  }

  void _startFade() async {
    while (!_disposed) {
      await Future.delayed(const Duration(milliseconds: 800));

      if (!_disposed) {
        visible.toggle();
      }
    }
  }
}