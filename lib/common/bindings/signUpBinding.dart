import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:stockpulse/controllers/signupController.dart';
import 'package:stockpulse/repositories/auth_repository.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(
      () => SignupController(Get.find<AuthRepository>()),
    );
  }
}
