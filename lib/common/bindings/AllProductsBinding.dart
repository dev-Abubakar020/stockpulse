import 'package:get/get.dart';

import '../../controllers/allProductsController.dart';
import '../../repositories/product_repository.dart';


class AllProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(
          () => ProductRepository(),
    );

    Get.lazyPut<ProductController>(
          () => ProductController(
        Get.find<ProductRepository>(),
      ),
    );
  }
}