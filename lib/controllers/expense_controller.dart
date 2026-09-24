import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/custom_snackbar.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repo.dart';

class ExpenseCategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategoryInfo(this.name, this.icon, this.color);
}

class ExpenseController extends GetxController {
  final ExpenseRepository _repository = ExpenseRepository();
  final ShopRepository _shopRepository = ShopRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------
  // STATE
  // ---------------------------------------------------------

  final searchQuery = ''.obs;
  final expenses = <ExpenseModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final currencySymbol = 'Rs.'.obs;

  final selectedCategory = 'Rent'.obs;
  final selectedDate = DateTime.now().obs;

  // ---------------------------------------------------------
  // FORM CONTROLLERS
  // ---------------------------------------------------------

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  // ---------------------------------------------------------
  // CATEGORIES WITH UI METADATA (Icons & Colors for UI only)
  // ---------------------------------------------------------

  static const List<ExpenseCategoryInfo> categoryMeta = [
    ExpenseCategoryInfo('Rent', Icons.home_rounded, Color(0xFF7C3AED)),
    ExpenseCategoryInfo('Electricity', Icons.bolt_rounded, Color(0xFFD97706)),
    ExpenseCategoryInfo('Gas / Fuel', Icons.local_gas_station_rounded, Color(0xFFDC2626)),
    ExpenseCategoryInfo('Staff Salaries', Icons.group_rounded, Color(0xFF2563EB)),
    ExpenseCategoryInfo('Maintenance & Repairs', Icons.build_rounded, Color(0xFF059669)),
    ExpenseCategoryInfo('Marketing & Advertising', Icons.campaign_rounded, Color(0xFFDB2777)),
    ExpenseCategoryInfo('Transport & Logistics', Icons.local_shipping_rounded, Color(0xFF0891B2)),
    ExpenseCategoryInfo('Packaging & Supplies', Icons.inventory_2_rounded, Color(0xFF65A30D)),
    ExpenseCategoryInfo('Internet & Phone', Icons.wifi_rounded, Color(0xFF6366F1)),
    ExpenseCategoryInfo('Bank Charges', Icons.account_balance_rounded, Color(0xFF475569)),
    ExpenseCategoryInfo('Insurance', Icons.shield_rounded, Color(0xFF0F766E)),
    ExpenseCategoryInfo('Miscellaneous', Icons.more_horiz_rounded, Color(0xFF78716C)),
  ];

  List<String> get categories => categoryMeta.map((c) => c.name).toList();

  ExpenseCategoryInfo get currentCategoryMeta {
    return categoryMeta.firstWhere(
      (m) => m.name == selectedCategory.value,
      orElse: () => categoryMeta.last,
    );
  }

  static ExpenseCategoryInfo getCategoryMeta(String categoryName) {
    return categoryMeta.firstWhere(
      (m) => m.name == categoryName,
      orElse: () => categoryMeta.last,
    );
  }

  List<ExpenseModel> get filteredExpenses {
    if (searchQuery.value.trim().isEmpty) {
      return expenses;
    }
    final query = searchQuery.value.trim().toLowerCase();
    return expenses.where((e) {
      final matchesCategory = e.category.toLowerCase().contains(query);
      final matchesDesc = e.description?.toLowerCase().contains(query) ?? false;
      final matchesAmount = e.amount.toString().contains(query);
      return matchesCategory || matchesDesc || matchesAmount;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  // ---------------------------------------------------------
  // FETCH EXPENSES FOR CURRENT SHOP
  // ---------------------------------------------------------

  Future<void> fetchExpenses([int? explicitShopId]) async {
    try {
      isLoading.value = true;
      int? targetShopId = explicitShopId;

      final shop = await _shopRepository.getShop();
      if (shop != null) {
        if (shop['id'] != null) {
          targetShopId = (shop['id'] as num).toInt();
        }
        if (shop['selectedsymbole'] != null &&
            (shop['selectedsymbole'] as String).isNotEmpty) {
          currencySymbol.value = shop['selectedsymbole'] as String;
        }
      }

      if (targetShopId == null) {
        CustomSnackBar.errorSnackBar(
          title: AppConstants.errorTitle,
          message: 'Shop details not found',
        );
        return;
      }

      expenses.value = await _repository.getExpenses(targetShopId);
    } catch (e) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: 'Failed to load expenses',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------
  // ADD EXPENSE
  // ---------------------------------------------------------

  Future<bool> addExpense() async {
    final amountText = amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: AppConstants.validAmountWarning,
      );
      return false;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: 'User not authenticated',
      );
      return false;
    }

    final shop = await _shopRepository.getShop();
    if (shop == null || shop['id'] == null) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: 'Shop details not found',
      );
      return false;
    }

    final shopId = (shop['id'] as num).toInt();

    try {
      isSaving.value = true;

      final expense = ExpenseModel(
        shopId: shopId,
        category: selectedCategory.value,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        amount: amount,
        expenseDate: selectedDate.value,
        createdBy: user.id,
      );

      final savedExpense = await _repository.addExpense(expense);
      expenses.insert(0, savedExpense);

      resetForm();
      Get.back();

      Future.delayed(const Duration(milliseconds: 200), () {
        CustomSnackBar.successSnackBar(
          title: AppConstants.successTitle,
          message: AppConstants.expenseAddedSuccess,
        );
      });

      return true;
    } catch (e) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: 'Failed to add expense',
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ---------------------------------------------------------
  // DELETE EXPENSE
  // ---------------------------------------------------------

  Future<void> deleteExpense(ExpenseModel expense) async {
    if (expense.id == null) return;

    try {
      isLoading.value = true;
      await _repository.deleteExpense(expense.id!);
      expenses.removeWhere((item) => item.id == expense.id);

      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: 'Expense deleted successfully',
      );
    } catch (e) {
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: 'Failed to delete expense',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------
  // TOTAL EXPENSE
  // ---------------------------------------------------------

  double get totalExpenses {
    return expenses.fold(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  // ---------------------------------------------------------
  // RESET FORM
  // ---------------------------------------------------------

  void resetForm() {
    amountController.clear();
    descriptionController.clear();
    selectedCategory.value = 'Rent';
    selectedDate.value = DateTime.now();
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
