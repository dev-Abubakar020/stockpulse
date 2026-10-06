import "package:get/get_core/src/get_main.dart";
import "package:get/get_instance/src/bindings_interface.dart";
import "package:get/get_instance/src/extension_instance.dart";
import "package:stockpulse/common/theme/theme_helper.dart";
import "package:stockpulse/controllers/allProductsController.dart";
import "package:stockpulse/controllers/home_controller.dart";
import "package:stockpulse/repositories/auth_repository.dart";
import "package:stockpulse/repositories/shop_repository.dart";
import "package:stockpulse/services/role_service.dart";

import "../../controllers/dashboardController.dart";
import "../../controllers/shopCreateController.dart";
import "../../repositories/product_repository.dart";
import "../../services/networkManager.dart";
import "../../services/thermal_printer_service.dart";

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    if (!Get.isRegistered<RoleService>()) {
      Get.put(RoleService(), permanent: true);
    }

    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<ThermalPrinterService>(ThermalPrinterService(), permanent: true);

    // Repositories
    Get.lazyPut<ShopRepository>(() => ShopRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);

    // Controllers
    Get.lazyPut<ProductController>(
      () => ProductController(Get.find<ProductRepository>()),
      fenix: true,
    );

    Get.lazyPut<ShopCreateController>(
      () => ShopCreateController(
        Get.find<ShopRepository>(),
        Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
