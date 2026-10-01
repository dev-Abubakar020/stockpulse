import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stockpulse/services/role_service.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:stockpulse/views/dashboardScreens/Product/allProducts.dart';
import 'package:stockpulse/views/dashboardScreens/homeView.dart';
import 'package:stockpulse/views/dashboardScreens/Sale/saleView.dart';
import 'package:stockpulse/views/dashboardScreens/More/morescreen.dart';
import '../../common/widgets/custom_snackbar.dart';
import '../../controllers/allProductsController.dart';
import '../../controllers/dashboardController.dart';
import '../../controllers/sale_controller.dart';
import 'Sale/addsale.dart';
import 'Sale/barcodescanner.dart';

class DashboardTabConfig {
  final Widget page;
  final BottomNavigationBarItem navItem;
  final bool isPermitted;

  DashboardTabConfig({
    required this.page,
    required this.navItem,
    required this.isPermitted,
  });
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primaryGreen = Color(0xFF1B5E3A);
  static const Color unselectedColor = Color(0xFF757575);

  static Widget _scannerNavIcon() {
    return Container(
      width: 46,
      height: 46,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.qr_code_scanner_rounded,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  Future<void> _openBarcodeScanner() async {
    final String? barcode = await Get.to<String>(
          () => const BarcodeScannerView(),
    );

    if (barcode == null || barcode.trim().isEmpty) {
      return;
    }

    final productController = Get.find<ProductController>();

    final product = await productController.findProductByBarcode(
      barcode,
    );

    if (product == null) {
      CustomSnackBar.warningSnackBar(
        title: 'Product Not Found',
        message: 'No product found with barcode $barcode.',
      );
      return;
    }

    debugPrint('SCANNED PRODUCT: ${product.article}');
    debugPrint('BARCODE: ${product.barcode}');

    Get.to(
          () => AddSale(
        initialProduct: product,
      ),
    );
  }


  List<DashboardTabConfig> _buildTabConfigs(
      RoleService roleService,
      ) {
    return [
      DashboardTabConfig(
        page: const HomeView(),
        navItem: const BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),
          activeIcon: Icon(
            Icons.home,
          ),
          label: AppConstants.homeTitle,
        ),
        isPermitted: true,
      ),
      DashboardTabConfig(
        page: const SaleView(),
        navItem: const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: '${AppConstants.saleTitle}s',
        ),
        isPermitted: true,
      ),


      DashboardTabConfig(
        page: const SizedBox.shrink(),
        navItem: BottomNavigationBarItem(
          icon: _scannerNavIcon(),
          activeIcon: _scannerNavIcon(),
          label: '',
        ),
        isPermitted: true,
      ),

      DashboardTabConfig(
        page: const AllProducts(),
        navItem: const BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.cube_box,
          ),
          activeIcon: Icon(
            CupertinoIcons.cube_box_fill,
          ),
          label: 'Inventory',
        ),
        isPermitted: true,
      ),

      DashboardTabConfig(
        page: const MoreScreen(),
        navItem: const BottomNavigationBarItem(
          icon: Icon(
            Icons.menu,
          ),
          activeIcon: Icon(
            Icons.menu,
          ),
          label: AppConstants.moreTitle,
        ),
        isPermitted: true,
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<DashboardController>();

    final roleService = Get.isRegistered<RoleService>()
        ? Get.find<RoleService>()
        : Get.put(
      RoleService(),
      permanent: true,
    );

    return Obx(() {

      if (controller.isChecking.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }


      final activeConfigs = _buildTabConfigs(roleService)
          .where(
            (config) => config.isPermitted,
      )
          .toList();

      final activePages = activeConfigs
          .map(
            (config) => config.page,
      )
          .toList();

      final activeNavItems = activeConfigs
          .map(
            (config) => config.navItem,
      )
          .toList();

      if (controller.selectedIndex.value >=
          activePages.length) {
        controller.selectedIndex.value = 0;
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (
            didPop,
            result,
            ) {
          if (didPop) return;
          if (controller.handleBackPress()) {
            SystemNavigator.pop();
          }
        },

        child: Scaffold(
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children: activePages,
          ),


          bottomNavigationBar: BottomNavigationBar(
            currentIndex:
            controller.selectedIndex.value,
            onTap: (index) {

              if (index == 2) {
                _openBarcodeScanner();
                return;
              }

              controller.changePage(index);
            },

            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryGreen,
            unselectedItemColor: unselectedColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: activeNavItems,
          ),
        ),
      );
    });
  }
}


// DashboardTabConfig(
// page: const PurchasePage(),
// navItem: const BottomNavigationBarItem(
// icon: Icon(Icons.list_alt),
// activeIcon: Icon(Icons.list_alt),
// label: '${AppConstants.purchaseTitle}s',
// ),
// isPermitted: roleService.canManagePurchases,
// ),


// class DashboardTabConfig {
//   final Widget page;
//   final BottomNavigationBarItem navItem;
//   final bool isPermitted;
//
//   DashboardTabConfig({
//     required this.page,
//     required this.navItem,
//     required this.isPermitted,
//   });
// }
//
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});
//
//   static const Color primaryGreen = Color(0xFF1B5E3A);
//   static const Color unselectedColor = Color(0xFF757575);
//
//   List<DashboardTabConfig> _buildTabConfigs(RoleService roleService) {
//     return [
//       DashboardTabConfig(
//         page: const HomeView(),
//         navItem: const BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           activeIcon: Icon(Icons.home),
//           label: AppConstants.homeTitle,
//         ),
//         isPermitted: true,
//       ),
//       DashboardTabConfig(
//         page: const SaleView(),
//         navItem: const BottomNavigationBarItem(
//           icon: Icon(Icons.shopping_cart_outlined),
//           activeIcon: Icon(Icons.shopping_cart),
//           label: '${AppConstants.saleTitle}s',
//         ),
//         isPermitted: true,
//       ),
//       DashboardTabConfig(
//         page: const AllProducts(),
//         navItem: const BottomNavigationBarItem(
//           icon: Icon(CupertinoIcons.cube_box),
//           activeIcon: Icon(CupertinoIcons.cube_box_fill),
//           label: AppConstants.productLabel,
//         ),
//         isPermitted: true,
//       ),
//
//       DashboardTabConfig(
//         page: const MoreScreen(),
//         navItem: const BottomNavigationBarItem(
//           icon: Icon(Icons.menu),
//           activeIcon: Icon(Icons.menu),
//           label: AppConstants.moreTitle,
//         ),
//         isPermitted: true,
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!Get.isRegistered<DashboardController>()) {
//       return const SizedBox.shrink();
//     }
//     final controller = Get.find<DashboardController>();
//
//     final roleService = Get.isRegistered<RoleService>()
//         ? Get.find<RoleService>()
//         : Get.put(RoleService(), permanent: true);
//
//     return Obx(() {
//       if (controller.isChecking.value) {
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
//
//       final activeConfigs = _buildTabConfigs(roleService)
//           .where((config) => config.isPermitted)
//           .toList();
//
//       final activePages = activeConfigs.map((c) => c.page).toList();
//       final activeNavItems = activeConfigs.map((c) => c.navItem).toList();
//
//       if (controller.selectedIndex.value >= activePages.length) {
//         controller.selectedIndex.value = 0;
//       }
//
//       return PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (didPop) return;
//           if (controller.handleBackPress()) {
//             SystemNavigator.pop();
//           }
//         },
//         child: Scaffold(
//           body: IndexedStack(
//             index: controller.selectedIndex.value,
//             children: activePages,
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: controller.selectedIndex.value,
//             onTap: controller.changePage,
//             type: BottomNavigationBarType.fixed,
//             backgroundColor: Colors.white,
//             selectedItemColor: primaryGreen,
//             unselectedItemColor: unselectedColor,
//             selectedLabelStyle: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontWeight: FontWeight.normal,
//               fontSize: 12,
//             ),
//             items: activeNavItems,
//           ),
//         ),
//       );
//     });
//   }
// }