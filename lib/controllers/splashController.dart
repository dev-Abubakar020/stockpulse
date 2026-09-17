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

    if (storage.isFirstTime()) {
      Get.offAllNamed(Routes.onboarding);
    } else {
      Get.offAllNamed(Routes.dashboard);
    }
  }

  void _startFade() async {
    while (!_disposed) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_disposed) visible.toggle();
    }
  }
}
