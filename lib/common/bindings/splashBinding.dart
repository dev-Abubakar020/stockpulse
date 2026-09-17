import 'package:get/get.dart';
import 'package:stockpulse/controllers/splashController.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
