import 'package:get/get.dart';
import 'package:stockpulse/controllers/shopCreateController.dart';
import 'package:stockpulse/repositories/shop_repository.dart';

class ShopCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopCreateController>(
      () => ShopCreateController(Get.find<ShopRepository>()),
    );
  }
}
