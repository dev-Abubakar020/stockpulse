import 'package:stockpulse/common/bindings/edit_profile_binding.dart';
import 'package:stockpulse/common/bindings/forgotPasswordBinding.dart';
import 'package:stockpulse/common/bindings/loginBinding.dart';
import 'package:stockpulse/common/bindings/signUpBinding.dart';
import 'package:stockpulse/common/bindings/shopCreateBinding.dart';
import 'package:stockpulse/controllers/purchase_report_Controller.dart';
import 'package:stockpulse/controllers/sale_report_Controller.dart';
import 'package:stockpulse/views/PurchaseReport.dart';
import 'package:stockpulse/views/authScreens/edit_profile.dart';
import 'package:stockpulse/views/authScreens/login.dart';
import 'package:stockpulse/views/starterScreens/onboarding.dart';
import 'package:stockpulse/views/authScreens/signup.dart';
import 'package:stockpulse/views/authScreens/forgotPassword.dart';
import 'package:stockpulse/views/authScreens/otpverification.dart';
import 'package:stockpulse/views/authScreens/phonedetailScreen.dart';
import 'package:stockpulse/views/authScreens/resetPassword.dart';
import 'package:stockpulse/views/dashboardScreens/dashboard.dart';
import 'package:stockpulse/views/create_shop.dart';
import '../../views/dashboardScreens/More/addcategories.dart';
import '../../views/expense/addexpenses.dart';
import '../../views/expense/allexpense.dart';
import '../../views/dashboardScreens/Purchase/addpurchase.dart';
import '../../views/dashboardScreens/Product/addProductWizardView.dart';
import '../../views/dashboardScreens/Sale/addsale.dart';
import '../../views/dashboardScreens/More/allcategories.dart';
import '../../views/authScreens/editshop.dart';
import '../../views/dashboardScreens/Product/allProducts.dart';
import '../../views/dashboardScreens/homeView.dart';
import '../../views/dashboardScreens/More/morescreen.dart';
import '../../views/dashboardScreens/Purchase/purchasePage.dart';
import '../../views/dashboardScreens/Sale/saleView.dart';
import '../../views/dashboardScreens/Product/productDetailView.dart';
import '../../views/dashboardScreens/Sale/saleDetailView.dart';
import '../../views/dashboardScreens/Purchase/purchaseDetailView.dart';
import '../../views/saleReport.dart';
import '../bindings/AllProductsBinding.dart';
import '../bindings/PurchaseBinding.dart';
import '../bindings/categoryBinding.dart';
import '../bindings/dashboardBinding.dart';
import '../bindings/expenseBinding.dart';
import '../bindings/addProductWizardBinding.dart';
import '../bindings/saleBinding.dart';
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
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
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
      name: Routes.editBDetails,
      page: () => const EditShopDetails(),
      binding: ShopCreateBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      binding: DashboardBinding(),
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: Routes.createShop,
      page: () => const CreateShop(),
      binding: ShopCreateBinding(),
    ),

    GetPage(name: Routes.home, page: () => const HomeView()),
    GetPage(name: Routes.sale, page: () => SaleView()),
    GetPage(name: Routes.moreScreen, page: () => MoreScreen()),
    GetPage(
      name: Routes.allCategories,
      page: () => AllCategories(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.addCategories,
      page: () => AddCategories(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.allProducts,
      page: () => AllProducts(),
      binding: AllProductsBinding(),
    ),
    GetPage(
      name: Routes.allPurchase,
      page: () => PurchasePage(),
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
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.allExpenses,
      page: () => const AllExpenses(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.saleReport,
      page: () => SaleReport(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SaleReportController());
      }),
    ),
    GetPage(
      name: Routes.purchaseReport,
      page: () => PurchaseReport(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PurchaseReportController());
      }),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: AllProductsBinding(),
    ),
    GetPage(
      name: Routes.saleDetail,
      page: () => const SaleDetailView(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: Routes.purchaseDetail,
      page: () => const PurchaseDetailView(),
      binding: PurchaseBinding(),
    ),
    // GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
  ];
}
