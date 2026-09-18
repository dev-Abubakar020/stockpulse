import 'package:get/get.dart';
import '../../controllers/addProductWizardController.dart';
import '../../controllers/category_controller.dart';

class AddProductWizardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductWizardController>(() => AddProductWizardController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
