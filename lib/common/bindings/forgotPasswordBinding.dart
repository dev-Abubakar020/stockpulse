import 'package:get/get.dart';
import 'package:stockpulse/controllers/forgotPasswordController.dart';
import 'package:stockpulse/repositories/auth_repository.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<AuthRepository>()),
    );
  }
}
