import 'package:get/get.dart';
import '../../controllers/dashboardController.dart';
import '../../controllers/allProductsController.dart';
import '../../repositories/product_repository.dart';
import '../../controllers/purchase_controller.dart';
import '../../repositories/purchase_repo.dart';
import '../../controllers/sale_controller.dart';
import '../../repositories/sale_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());

    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<ProductController>(() => ProductController(Get.find<ProductRepository>()));

    Get.lazyPut<PurchaseRepository>(() => PurchaseRepository());
    Get.lazyPut<PurchaseController>(
      () => PurchaseController(
        repository: Get.find<PurchaseRepository>(),
        productController: Get.find<ProductController>(),
      ),
    );

    Get.lazyPut<SaleRepository>(() => SaleRepository());
    Get.lazyPut<SaleController>(
      () => SaleController(
        repository: Get.find<SaleRepository>(),
        productController: Get.find<ProductController>(),
      ),
    );
  }
}