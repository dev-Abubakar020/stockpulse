import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxnString role = RxnString();
  final RxBool hasMembership = false.obs;
  final RxBool isActive = true.obs;
  final RxString shopId = ''.obs;
  final RxString shopName = ''.obs;
  final RxBool isLoaded = false.obs;

  bool get isOwner {
    final currentRole = role.value?.trim().toLowerCase();
    return currentRole == 'owner' ||
        currentRole == 'shop_owner' ||
        currentRole == 'shop owner' ||
        currentRole == 'admin';
  }
  bool get isStaff => role.value == 'staff';

  bool get canManageProducts => isOwner;
  bool get canCreateSale => isOwner || isStaff;
  bool get canManagePurchases => isOwner;
  bool get canManageExpenses => isOwner;
  bool get canManageStaff => isOwner;
  bool get canViewReports => isOwner || isStaff;
  bool get canEditShopDetails => isOwner;
  bool get canChangeSalePrice => isOwner;
  bool get canApplyDiscount => isOwner;
  bool get canViewPurchasePrice => isOwner;

  Future<Map<String, dynamic>?> fetchMembership() async {
    isLoaded.value = false;
    final user = _supabase.auth.currentUser;
    if (user == null) {
      clearRole();
      return null;
    }

    try {
      final response = await _supabase.rpc('get_my_membership');
      Map<String, dynamic>? data;
      if (response != null) {
        if (response is List && response.isNotEmpty) {
          data = Map<String, dynamic>.from(response.first);
        } else if (response is Map) {
          data = Map<String, dynamic>.from(response);
        }
      }

      if (data != null && data['role'] != null) {
        shopId.value = data['shop_id']?.toString() ?? '';
        shopName.value = data['shop_name']?.toString() ?? '';
        role.value = data['role']?.toString().toLowerCase();
        isActive.value = data['is_active'] == true;
        hasMembership.value = true;
        isLoaded.value = true;
        return data;
      }
    } catch (e) {
      debugPrint('Error fetching membership: $e');
    }

    clearRole();
    isLoaded.value = true;
    return null;
  }

  void clearRole() {
    role.value = null;
    hasMembership.value = false;
    isActive.value = true;
    shopId.value = '';
    shopName.value = '';
    isLoaded.value = false;
  }
}
