import 'package:stockpulse/common/bindings/loginBinding.dart';
import 'package:stockpulse/common/bindings/signUpBinding.dart';
import 'package:stockpulse/common/bindings/shopCreateBinding.dart';
import 'package:stockpulse/views/login.dart';
import 'package:stockpulse/views/onboarding.dart';
import 'package:stockpulse/views/signup.dart';
import 'package:stockpulse/views/forgotPassword.dart';
import 'package:stockpulse/views/otpverification.dart';
import 'package:stockpulse/views/phonedetailScreen.dart';
import 'package:stockpulse/views/dashboard.dart';
import 'package:stockpulse/views/create_shop.dart';

import '../../views/addcategories.dart';
import '../../views/allcategories.dart';
import '../../views/starterScreens/Setting.dart';
import '../../views/starterScreens/allProducts.dart';
import '../../views/starterScreens/homeView.dart';
import '../../views/starterScreens/morescreen.dart';
import '../../views/starterScreens/purchasePage.dart';
import '../../views/starterScreens/saleView.dart';
import '../../views/starterScreens/addProductWizardView.dart';
import '../bindings/AllProductsBinding.dart';
import '../bindings/dashboardBinding.dart';
import '../bindings/addProductWizardBinding.dart';
import 'app_routes.dart';

import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppPages {
  static final pages = [
    ///Links


    ///Starting screens
    GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.phoneDetails,
      page: () => const PhoneDetailScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otpVerification,
      page: () => const OtpVerificationScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
        name: Routes.dashboard,
        binding:DashboardBinding(),
        page: () => const DashboardScreen(),
    ),
    GetPage(
      name: Routes.createShop,
      page: () => const CreateShop(),
      binding: ShopCreateBinding(),
    ),

    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
    ),
    GetPage(
      name: Routes.sale,
      page: () =>  SaleView(),
    ),
    GetPage(
      name: Routes.moreScreen,
      page: () =>  MoreScreen(),
    ),
    GetPage(
      name: Routes.settingPage,
      page: () =>  SettingPage(),
    ),
    GetPage(
      name: Routes.allCategories,
      page: () =>  AllCategories(),
    ),
    GetPage(
      name: Routes.addCategories,
      page: () =>  AddCategories(),
    ),
    GetPage(
      name: Routes.allProducts,
      page: () =>  AllProducts(),
      binding: AllProductsBinding(),
    ),
    GetPage(
      name: Routes.allPurchase,
      page: () =>  PurchasePage(),
    ),
    GetPage(
      name: Routes.addProductWizard,
      page: () => const AddProductWizardView(),
      binding: AddProductWizardBinding(),
    ),
    // GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
  ];
}
