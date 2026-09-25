import 'package:get/get.dart';
import 'package:stockpulse/controllers/allProductsController.dart';
import 'package:stockpulse/controllers/category_controller.dart';
import 'package:stockpulse/controllers/dashboardController.dart';
import 'package:stockpulse/controllers/edit_profile_controller.dart';
import 'package:stockpulse/controllers/expense_controller.dart';
import 'package:stockpulse/controllers/homecontroller.dart';
import 'package:stockpulse/controllers/purchase_controller.dart';
import 'package:stockpulse/controllers/sale_controller.dart';
import 'package:stockpulse/controllers/shopCreateController.dart';
import 'package:stockpulse/repositories/product_repository.dart';
import 'package:stockpulse/repositories/purchase_repo.dart';
import 'package:stockpulse/repositories/sale_repository.dart';
import 'package:stockpulse/repositories/shop_repository.dart';

/// Centralized session cleanup utility to wipe user-scoped GetX state and repositories
/// without deleting permanent infrastructure services (AuthRepository, LocalStorageService, NetworkManager, ThemeController).
void clearUserSessionData() {
  try {
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }
    if (Get.isRegistered<ProductController>()) {
      Get.delete<ProductController>(force: true);
    }
    if (Get.isRegistered<ProductRepository>()) {
      Get.delete<ProductRepository>(force: true);
    }
    if (Get.isRegistered<SaleController>()) {
      Get.delete<SaleController>(force: true);
    }
    if (Get.isRegistered<SaleRepository>()) {
      Get.delete<SaleRepository>(force: true);
    }
    if (Get.isRegistered<PurchaseController>()) {
      Get.delete<PurchaseController>(force: true);
    }
    if (Get.isRegistered<PurchaseRepository>()) {
      Get.delete<PurchaseRepository>(force: true);
    }
    if (Get.isRegistered<ExpenseController>()) {
      Get.delete<ExpenseController>(force: true);
    }
    if (Get.isRegistered<CategoryController>()) {
      Get.delete<CategoryController>(force: true);
    }
    if (Get.isRegistered<ShopCreateController>()) {
      Get.delete<ShopCreateController>(force: true);
    }
    if (Get.isRegistered<ShopRepository>()) {
      Get.delete<ShopRepository>(force: true);
    }
    if (Get.isRegistered<EditProfileController>()) {
      Get.delete<EditProfileController>(force: true);
    }
  } catch (e) {
    // Suppress cleanup errors during hot reload / test runs
  }
}
