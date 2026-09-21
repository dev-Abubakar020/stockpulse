import 'package:get/get.dart';
import '../../controllers/allProductsController.dart';
import '../../controllers/sale_controller.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/sale_repository.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<ProductRepository>(
          () => ProductRepository(),
    );
    Get.lazyPut<SaleRepository>(
          () => SaleRepository(),
    );

    Get.lazyPut<SaleController>(
          () => SaleController(
        repository:
        Get.find<SaleRepository>(),
        productController:
        Get.find<ProductController>(),
      ),
    );
    // Purchase Controller
    Get.lazyPut<ProductController>(
          () => ProductController(
        Get.find<ProductRepository>(),
      ),
    );
  }
}