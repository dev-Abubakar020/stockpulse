import 'package:stockpulse/common/bindings/forgotPasswordBinding.dart';
import 'package:stockpulse/common/bindings/loginBinding.dart';
import 'package:stockpulse/common/bindings/signUpBinding.dart';
import 'package:stockpulse/common/bindings/shopCreateBinding.dart';
import 'package:stockpulse/views/authScreens/login.dart';
import 'package:stockpulse/views/starterScreens/onboarding.dart';
import 'package:stockpulse/views/authScreens/signup.dart';
import 'package:stockpulse/views/authScreens/forgotPassword.dart';
import 'package:stockpulse/views/authScreens/otpverification.dart';
import 'package:stockpulse/views/authScreens/phonedetailScreen.dart';
import 'package:stockpulse/views/authScreens/resetPassword.dart';
import 'package:stockpulse/views/dashboardScreens/dashboard.dart';
import 'package:stockpulse/views/create_shop.dart';

import '../../views/addcategories.dart';
import '../../views/addexpenses.dart';
import '../../views/addpurchase.dart';
import '../../views/addsale.dart';
import '../../views/allcategories.dart';
import '../../views/dashboardScreens/Setting.dart';
import '../../views/dashboardScreens/allProducts.dart';
import '../../views/dashboardScreens/homeView.dart';
import '../../views/dashboardScreens/morescreen.dart';
import '../../views/dashboardScreens/purchasePage.dart';
import '../../views/dashboardScreens/saleView.dart';
import '../../views/addProductWizardView.dart';
import '../../views/productDetailView.dart';
import '../bindings/AllProductsBinding.dart';
import '../bindings/PurchaseBinding.dart';
import '../bindings/dashboardBinding.dart';
import '../bindings/addProductWizardBinding.dart';
import '../bindings/saleBinding.dart';
import '../bindings/settingBinding.dart';
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
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ForgotPasswordBinding(),
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
      binding: SettingBinding(),
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
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.addProductWizard,
      page: () => const AddProductWizardView(),
      binding: AddProductWizardBinding(),
    ),

    GetPage(
      name: Routes.addSale,
      page: () => const AddSale(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: Routes.addPurchase,
      page: () => const AddPurchase(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.addExpense,
      page: () => const AddExpenses(),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: AllProductsBinding(),
    ),
    // GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
  ];
}
