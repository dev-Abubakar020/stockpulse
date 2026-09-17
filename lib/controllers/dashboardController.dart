import 'package:get/get.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/route/app_routes.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isChecking = false.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.find<LocalStorageService>().setLoggedIn(false);
    Get.offAllNamed(Routes.login);
  }
}