import 'package:get/get.dart';

import '../../controllers/allProductsController.dart';
import '../../controllers/purchase_controller.dart';
import '../../repositories/purchase_repo.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<PurchaseRepository>(
          () => PurchaseRepository(),
    );

    // Purchase Controller
    Get.lazyPut<PurchaseController>(
          () => PurchaseController(
        repository: Get.find<PurchaseRepository>(),
        productController: Get.find<ProductController>(),
      ),
    );
  }
}