import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../common/widgets/custom_snackbar.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

import '../repositories/product_repository.dart';
import '../services/networkManager.dart';
import '../utils/app_constants.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ProductRepository _productRepository = ProductRepository();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var categoriesList = <CategoryModel>[].obs;
  var categoryCounts = <String, int>{}.obs;

  // Search and Filter state
  var searchQuery = ''.obs;
  var selectedFilterIndex = 0.obs;

  // Add Category form controllers
  final nameController = TextEditingController();
  var isCategoryActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch categories from database
  Future<void> fetchCategories() async {
    if (!await NetworkManager.instance.checkInternet()) {
      return;
    }

    try {
      isLoading.value = true;
      final list = await _categoryRepository.getAllCategories();

      try {
        final products = await _productRepository.getProducts();
        final counts = <String, int>{};
        for (var p in products) {
          if (p.categoryId != null) {
            counts[p.categoryId!] = (counts[p.categoryId!] ?? 0) + 1;
          }
        }
        categoryCounts.assignAll(counts);
      } catch (e) {
        debugPrint('Error fetching product counts for categories: $e');
      }

      categoriesList.assignAll(list);
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtered categories based on search and tab selection
  List<CategoryModel> get filteredCategories {
    return categoriesList.where((category) {
      // 1. Filter by Search Query
      final matchesSearch = category.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );

      // 2. Filter by Status Tab
      bool matchesStatus = true;
      if (selectedFilterIndex.value == 1) {
        matchesStatus = category.isActive == true;
      } else if (selectedFilterIndex.value == 2) {
        matchesStatus = category.isActive == false;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Change selected filter tab
  void changeFilter(int index) {
    selectedFilterIndex.value = index;
  }

  // Add a new category
  Future<bool> saveCategory() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: 'Category name cannot be empty',
      );
      return false;
    }

    if (!await NetworkManager.instance.checkInternet()) {
      return false;
    }

    try {
      isSaving.value = true;

      final newCategory = CategoryModel(
        name: name,
        isActive: isCategoryActive.value,
      );

      final saved = await _categoryRepository.addCategory(newCategory);

      categoriesList.add(saved);

      resetForm();

      Get.back();

      // Then show success snackbar on previous screen
      Future.delayed(const Duration(milliseconds: 200), () {
        CustomSnackBar.successSnackBar(
          title: AppConstants.successTitle,
          message: 'Category added successfully',
        );
      });

      return true;
    } catch (e) {
      final exception = AppException.fromException(e);

      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update status of a category
  Future<void> changeCategoryStatus(
    CategoryModel category,
    bool isActive,
  ) async {
    if (category.id == null) return;
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      await _categoryRepository.updateCategoryStatus(category.id!, isActive);

      // Update local state
      int index = categoriesList.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categoriesList[index] = category.copyWith(isActive: isActive);
      }

      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: AppConstants.categoryStatusUpdated,
      );
    } catch (e) {
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    }
  }

  // Reset form inputs
  void resetForm() {
    nameController.text = '';
    isCategoryActive.value = true;
  }

  void clearForm() {
    nameController.clear();
    isCategoryActive.value = true;
  }
}
