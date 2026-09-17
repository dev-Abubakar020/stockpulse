import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:stockpulse/views/starterScreens/allProducts.dart';
import 'package:stockpulse/views/starterScreens/homeView.dart';
import 'package:stockpulse/views/starterScreens/purchasePage.dart';
import 'package:stockpulse/views/starterScreens/saleView.dart';
import 'package:stockpulse/views/starterScreens/morescreen.dart';
import '../controllers/dashboardController.dart';


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

      return Scaffold(
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Purchases',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              activeIcon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      );
    });
  }
}



//Future<void> _checkShopProfile() async {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) {
//       if (mounted) Get.offAllNamed(Routes.login);
//       return;
//     }
//
//     try {
//       final hasShop = await Get.find<ShopRepository>().currentUserHasShop();
//       if (!mounted) return;
//       if (!hasShop) Get.offAllNamed(Routes.createShop);
//     } catch (error) {
//       if (!mounted) return;
//       Get.snackbar(
//         'Shop profile required',
//         'Complete your shop profile before continuing. Details: $error',
//         duration: const Duration(seconds: 5),
//       );
//       Get.offAllNamed(Routes.createShop);
//       return;
//     } finally {
//       if (mounted) setState(() => isChecking = false);
//     }
//   }