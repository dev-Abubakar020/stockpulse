import "package:get/get_core/src/get_main.dart";
import "package:get/get_instance/src/bindings_interface.dart";
import "package:get/get_instance/src/extension_instance.dart";
import "package:stockpulse/common/theme/theme_helper.dart";
import "package:stockpulse/repositories/auth_repository.dart";
import "package:stockpulse/repositories/shop_repository.dart";

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<ShopRepository>(ShopRepository(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}
