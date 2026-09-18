import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/productItemModel.dart';
import '../models/category_model.dart';
import '../repositories/product_repository.dart';
import 'allProductsController.dart';

class AddProductWizardController extends GetxController {
  // Step navigation (1, 2, 3)
  final RxInt currentStep = 1.obs;

  // Track if we are editing an existing product
  final Rxn<ProductItemModel> editingProduct = Rxn<ProductItemModel>();

  // STEP 1 Fields
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final Rxn<CategoryModel> selectedCategory =
  Rxn<CategoryModel>();
  final RxString selectedUnit = 'Piece (pcs)'.obs;
  
  // Image handling
  final Rxn<String> networkImageUrl = Rxn<String>();
  final Rxn<XFile> pickedFile = Rxn<XFile>();
  final RxBool isUploading = false.obs;

  final categories = <CategoryModel>[].obs;
  final isCategoriesLoading = false.obs;

  final List<String> units = ['Piece (pcs)', 'Box', 'Kilogram (kg)', 'Litre (L)'];

  // STEP 2 Fields
  final purchasePriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final RxInt initialStock = 24.obs;
  final RxInt lowStockLimit = 5.obs;
  final RxBool trackStock = true.obs;
  final RxBool activeForSale = true.obs;

  // Live computed values
  final RxDouble estimatedProfit = 60.0.obs;
  final RxDouble marginPercentage = 33.3.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Check if a product was passed for editing
    if (Get.arguments is ProductItemModel) {
      editingProduct.value = Get.arguments;
      _prefillFields();
    } else {
      nameController.text = '';
      skuController.text = '';
    }

    fetchCategories();
    // Add listeners to price changes for automatic margin calculation
    purchasePriceController.addListener(calculateMargin);
    salePriceController.addListener(calculateMargin);
  }

  void _prefillFields() {
    final p = editingProduct.value!;
    nameController.text = p.article;
    skuController.text = p.barcode ?? '';
    selectedUnit.value = p.unit;
    purchasePriceController.text = p.purchasePrice.toInt().toString();
    salePriceController.text = p.salePrice.toInt().toString();
    initialStock.value = p.currentStock.toInt();
    lowStockLimit.value = p.minStockThreshold.toInt();
    activeForSale.value = p.isActive;
    networkImageUrl.value = p.imageUrl;
    
    // category will be set once fetchCategories finishes if it matches
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      pickedFile.value = image;
    }
  }

  void calculateMargin() {
    final double purchase = double.tryParse(purchasePriceController.text) ?? 0.0;
    final double sale = double.tryParse(salePriceController.text) ?? 0.0;

    if (sale > 0) {
      estimatedProfit.value = sale - purchase;
      marginPercentage.value = (estimatedProfit.value / sale) * 100;
    } else {
      estimatedProfit.value = 0.0;
      marginPercentage.value = 0.0;
    }
  }

  void incrementStock() => initialStock.value++;
  void decrementStock() {
    if (initialStock.value > 0) {
      initialStock.value--;
    }
  }

  void incrementLowStock() => lowStockLimit.value++;
  void decrementLowStock() {
    if (lowStockLimit.value > 0) lowStockLimit.value--;
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  Future<void> saveProduct() async {
    try {
      isUploading.value = true;
      final repository = Get.find<ProductRepository>();
      final isEdit = editingProduct.value != null;

      String? imageUrl = networkImageUrl.value;

      // Handle new image upload if picked
      if (pickedFile.value != null) {
        final bytes = await pickedFile.value!.readAsBytes();
        final ext = pickedFile.value!.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        imageUrl = await repository.uploadProductImage(fileName, bytes);
      }

      final productData = ProductItemModel(
        id: isEdit ? editingProduct.value!.id : '',
        article: nameController.text.trim(),
        categoryId: selectedCategory.value?.id,
        unit: selectedUnit.value,
        purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
        salePrice: double.tryParse(salePriceController.text) ?? 0.0,
        currentStock: initialStock.value.toDouble(),
        minStockThreshold: lowStockLimit.value.toDouble(),
        barcode: skuController.text.trim().isEmpty ? null : skuController.text.trim(),
        isActive: activeForSale.value,
        imageUrl: imageUrl,
      );

      if (isEdit) {
        await repository.updateProduct(productData.id, productData.toJson());
      } else {
        await repository.addProduct(productData);
      }

      // Refresh the all products controller list
      if (Get.isRegistered<ProductController>()) {
        Get.find<ProductController>().fetchProducts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${editingProduct.value != null ? 'update' : 'save'} product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  bool validateStep1() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Product name is required to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedCategory.value == null) {
      Get.snackbar(
        'Required Field',
        'Please select a category for this product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  bool validateStep2() {
    final purchasePrice = purchasePriceController.text.trim();
    final salePrice = salePriceController.text.trim();

    if (purchasePrice.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Purchase price is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
    if (salePrice.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Sale price is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }

    if (double.tryParse(purchasePrice) == null) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid number for purchase price',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
    if (double.tryParse(salePrice) == null) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid number for sale price',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void nextStep() async {
    if (currentStep.value == 1) {
      if (!validateStep1()) return;
    } else if (currentStep.value == 2) {
      if (!validateStep2()) return;
      await saveProduct();
    }

    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  void resetWizard() {
    currentStep.value = 1;
    nameController.text = '';
    skuController.text = '5449000000996';
    purchasePriceController.text = '0';
    salePriceController.text = '0';
    selectedCategory.value = categories.isNotEmpty ? categories.first : null;
    selectedUnit.value = 'Piece (pcs)';
    initialStock.value = 24;
    lowStockLimit.value = 5;
    trackStock.value = true;
    activeForSale.value = true;
    calculateMargin();
  }

  @override
  void onClose() {
    purchasePriceController.removeListener(calculateMargin);
    salePriceController.removeListener(calculateMargin);
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      if (kDebugMode) {
        print('DEBUG: Fetching categories from Supabase repository...');
      }
      final repository = Get.find<ProductRepository>();

      final list = await repository.getCategories();
      if (kDebugMode) {
        print('DEBUG: Successfully retrieved ${list.length} categories from Supabase.');
      }
      for (var cat in list) {
        if (kDebugMode) {
          print('DEBUG: Category ID: ${cat.id}, Name: ${cat.name}, Active: ${cat.isActive}');
        }
      }
      
      categories.assignAll(list);

      if (editingProduct.value != null && editingProduct.value!.categoryId != null) {
        selectedCategory.value = categories.firstWhereOrNull(
          (c) => c.id == editingProduct.value!.categoryId,
        );
      } else if (categories.isNotEmpty && selectedCategory.value == null) {
        selectedCategory.value = categories.first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Exception inside fetchCategories: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCategoriesLoading.value = false;
    }
  }
}
