import 'package:get/get.dart';
import 'package:stockpulse/controllers/edit_profile_controller.dart';
import 'package:stockpulse/repositories/auth_repository.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(Get.find<AuthRepository>()),
    );
  }
}
