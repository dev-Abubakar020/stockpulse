import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:stockpulse/views/dashboardScreens/Product/allProducts.dart';
import 'package:stockpulse/views/dashboardScreens/homeView.dart';
import 'package:stockpulse/views/dashboardScreens/Purchase/purchasePage.dart';
import 'package:stockpulse/views/dashboardScreens/Sale/saleView.dart';
import 'package:stockpulse/views/dashboardScreens/More/morescreen.dart';
import '../../controllers/dashboardController.dart';
import '../saleReport.dart';


class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  static const Color primaryGreen = Color(0xFF1B5E3A);
  static const Color unselectedColor = Color(0xFF757575);

  static final List<Widget> _pages = [
    HomeView(),
    SaleView(),
    AllProducts(),
    PurchasePage(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isChecking.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (controller.handleBackPress()) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: controller.selectedIndex.value,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changePage,
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
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: AppConstants.homeTitle,
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: '${AppConstants.saleTitle}s',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.cube_box),
                  activeIcon: const Icon(CupertinoIcons.cube_box_fill),
                  label: AppConstants.productLabel,
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.signal_cellular_alt_outlined ),
                  activeIcon: Icon(Icons.signal_cellular_alt),
                  label: AppConstants.purchaseTitle,
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  activeIcon: Icon(Icons.menu),
                  label: AppConstants.moreTitle,
                ),
              ],
            ),
          ),
        );
    });
  }
}
