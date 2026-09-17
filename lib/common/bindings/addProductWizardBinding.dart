import 'package:get/get.dart';
import '../../controllers/addProductWizardController.dart';

class AddProductWizardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductWizardController>(() => AddProductWizardController());
  }
}
