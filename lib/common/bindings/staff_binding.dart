import 'package:get/get.dart';
import 'package:stockpulse/controllers/staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffController>(
          () => StaffController(),
    );
  }
}
