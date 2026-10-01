import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/controllers/homecontroller.dart';

import '../../models/productItemModel.dart';
import '../common/exceptional/platform_exceptions.dart';
import '../common/widgets/custom_snackbar.dart';
import '../models/category_model.dart';
import '../repositories/product_repository.dart';
import '../services/networkManager.dart';
import '../services/role_service.dart';
import '../utils/app_constants.dart';
import 'allProductsController.dart';

class AddProductWizardController extends GetxController {
  // Step navigation (1, 2, 3)
  final RxInt currentStep = 1.obs;
  final Rxn<ProductItemModel> editingProduct = Rxn<ProductItemModel>();

  // STEP 1 Page
  final Rxn<String> networkImageUrl = Rxn<String>();
  final Rxn<XFile> pickedFile = Rxn<XFile>();
  final RxBool isUploading = false.obs;
  final nameController = TextEditingController();
  final categories = <CategoryModel>[].obs;
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final barcodeController = TextEditingController();
  final isCategoriesLoading = false.obs;
  final List<String> units = [
    'Piece (pcs)',
    'Kilogram (kg)',
    'Litre (L)',
    'Meter (m)',
  ];
  final RxString selectedUnit = 'Piece (pcs)'.obs;
  bool get isDecimalUnit =>
      selectedUnit.value == 'Kilogram (kg)' ||
          selectedUnit.value == 'Litre (L)' ||
          selectedUnit.value == 'Meter (m)';
  String get unitSymbol {
    switch (selectedUnit.value) {
      case 'Piece (pcs)':
        return 'pcs';
      case 'Kilogram (kg)':
        return 'kg';
      case 'Litre (L)':
        return 'L';
      case 'Meter (m)':
        return 'm';
      default:
        return '';
    }
  }


  // STEP 2 Fields
  final purchasePriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final RxDouble estimatedProfit = 0.0.obs;
  final RxDouble marginPercentage = 0.0.obs;
  final initialStockController = TextEditingController(text: '24');
  final lowStockController = TextEditingController(text: '5');
  final RxBool trackStock = true.obs;
  final RxBool activeForSale = true.obs;


  double get initialStock =>
      double.tryParse(initialStockController.text) ?? 0;

  double get lowStockLimit =>
      double.tryParse(lowStockController.text) ?? 0;

  double get quantityStep => isDecimalUnit ? 0.1 : 1.0;

  String formatQuantity(double value) {
    if (!isDecimalUnit) return value.toInt().toString();

    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void onInit() {
    super.onInit();

    // Check if a product was passed for editing
    if (Get.arguments is ProductItemModel) {
      editingProduct.value = Get.arguments;
      _prefillFields();
    } else {
      nameController.text = '';
      barcodeController.text = '';
    }

    fetchCategories();
    // Add listeners to price changes for automatic margin calculation
    purchasePriceController.addListener(calculateMargin);
    salePriceController.addListener(calculateMargin);
  }

  String? get barcodeValue {
    final value = barcodeController.text.trim().toUpperCase();

    return value.isEmpty ? null : value;
  }

  void _prefillFields() {
    final p = editingProduct.value!;

    nameController.text = p.article;
    barcodeController.text = p.barcode ?? '';
    selectedUnit.value = p.unit;

    purchasePriceController.text =
        p.purchasePrice.toStringAsFixed(2);

    salePriceController.text =
        p.salePrice.toStringAsFixed(2);

    initialStockController.text =
        formatQuantity(p.currentStock);

    lowStockController.text =
        formatQuantity(p.minStockThreshold);

    activeForSale.value = p.isActive;
    networkImageUrl.value = p.imageUrl;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedFile.value = image;
    }
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  void incrementStock() {
    final value = initialStock + quantityStep;
    initialStockController.text = formatQuantity(value);
  }

  void decrementStock() {
    final value = initialStock;

    if (value <= 0) return;

    final newValue =
    (value - quantityStep).clamp(0.0, double.infinity).toDouble();

    initialStockController.text = formatQuantity(newValue);
  }

  void decrementLowStock() {
    final value = lowStockLimit;

    if (value <= 0) return;

    final newValue =
    (value - quantityStep).clamp(0.0, double.infinity).toDouble();

    lowStockController.text = formatQuantity(newValue);
  }

  void incrementLowStock() {
    final value = lowStockLimit + quantityStep;
    lowStockController.text = formatQuantity(value);
  }

  void calculateMargin() {
    final double purchase =
        double.tryParse(purchasePriceController.text) ?? 0.0;
    final double sale = double.tryParse(salePriceController.text) ?? 0.0;

    if (sale > 0) {
      estimatedProfit.value = sale - purchase;
      marginPercentage.value = (estimatedProfit.value / sale) * 100;
    } else {
      estimatedProfit.value = 0.0;
      marginPercentage.value = 0.0;
    }
  }

  Future<void> saveProduct() async {
    if (isUploading.value) return;
    if (!await NetworkManager.instance.checkInternet()) return;

    final roleService = Get.find<RoleService>();

    // Ensure latest membership/role is loaded
    if (!roleService.isLoaded.value ||
        roleService.role.value == null) {
      await roleService.fetchMembership();
    }

    debugPrint('========== PRODUCT PERMISSION ==========');
    debugPrint('Role: ${roleService.role.value}');
    debugPrint('Loaded: ${roleService.isLoaded.value}');
    debugPrint('Has Membership: ${roleService.hasMembership.value}');
    debugPrint('Active: ${roleService.isActive.value}');
    debugPrint('Shop ID: ${roleService.shopId.value}');
    debugPrint('isOwner: ${roleService.isOwner}');
    debugPrint('canManageProducts: ${roleService.canManageProducts}');
    debugPrint('========================================');

    if (!roleService.canManageProducts) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.errorTitle,
        message: AppConstants.permissionDeniedAction,
      );
      return;
    }

    try {
      isUploading.value = true;

      final repository = Get.find<ProductRepository>();
      final isEdit = editingProduct.value != null;

      String? imageUrl = networkImageUrl.value;

      if (pickedFile.value != null) {
        final bytes = await pickedFile.value!.readAsBytes();
        final ext = pickedFile.value!.name.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$ext';

        imageUrl = await repository.uploadProductImage(
          fileName,
          bytes,
        );
      }

      final productData = ProductItemModel(
        id: isEdit ? editingProduct.value!.id : '',
        article: nameController.text.trim(),
        categoryId: selectedCategory.value?.id,
        unit: selectedUnit.value,
        shopId: int.tryParse(roleService.shopId.value),
        purchasePrice:
        double.tryParse(purchasePriceController.text.trim()) ?? 0.0,

        salePrice:
        double.tryParse(salePriceController.text.trim()) ?? 0.0,

        currentStock:
        double.tryParse(initialStockController.text.trim()) ?? 0.0,

        minStockThreshold:
        double.tryParse(lowStockController.text.trim()) ?? 0.0,
        barcode: barcodeValue,
        isActive: activeForSale.value,
        imageUrl: imageUrl,
      );

      if (isEdit) {
        await repository.updateProduct(
          productData.id,
          productData.toJson(),
        );
      } else {
        await repository.addProduct(productData);
      }

      if (Get.isRegistered<ProductController>()) {
        await Get.find<ProductController>().fetchProducts();
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchHomeData();
      }
    } catch (e) {
      debugPrint('SAVE PRODUCT ERROR: $e');

      final exception = AppException.fromException(e);

      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isUploading.value = false;
    }
  }


  bool validateStep1() {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.requiredFieldTitle,
        message: AppConstants.productNameRequired,
      );
      return false;
    }
    if (selectedCategory.value == null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.requiredFieldTitle,
        message: AppConstants.selectCategoryRequired,
      );
      return false;
    }
    return true;
  }

  bool validateStep2() {
    final purchasePrice = purchasePriceController.text.trim();
    final salePrice = salePriceController.text.trim();

    if (purchasePrice.isEmpty) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.requiredFieldTitle,
        message: AppConstants.purchasePriceRequired,
      );
      return false;
    }
    if (salePrice.isEmpty) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.requiredFieldTitle,
        message: AppConstants.salePriceRequired,
      );
      return false;
    }

    if (double.tryParse(purchasePrice) == null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.invalidInputTitle,
        message: AppConstants.validNumberPurchasePrice,
      );
      return false;
    }
    if (double.tryParse(salePrice) == null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.invalidInputTitle,
        message: AppConstants.validNumberSalePrice,
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
    barcodeController.text = '';
    purchasePriceController.text = '0';
    salePriceController.text = '0';
    selectedCategory.value = categories.isNotEmpty ? categories.first : null;
    selectedUnit.value = 'Piece (pcs)';
    initialStockController.text = '24';
    lowStockController.text = '5';
    trackStock.value = true;
    activeForSale.value = true;
    calculateMargin();
  }

  @override
  void onClose() {
    purchasePriceController.removeListener(calculateMargin);
    salePriceController.removeListener(calculateMargin);

    purchasePriceController.dispose();
    salePriceController.dispose();

    initialStockController.dispose();
    lowStockController.dispose();

    nameController.dispose();
    barcodeController.dispose();

    super.onClose();
  }

  Future<void> fetchCategories() async {
    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isCategoriesLoading.value = true;
      if (kDebugMode) {
        print('DEBUG: Fetching categories from Supabase repository...');
      }
      final repository = Get.find<ProductRepository>();

      final list = await repository.getCategories();
      if (kDebugMode) {
        print(
          'DEBUG: Successfully retrieved ${list.length} categories from Supabase.',
        );
      }
      for (var cat in list) {
        if (kDebugMode) {
          print(
            'DEBUG: Category ID: ${cat.id}, Name: ${cat.name}, Active: ${cat.isActive}',
          );
        }
      }

      categories.assignAll(list);

      if (editingProduct.value != null &&
          editingProduct.value!.categoryId != null) {
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
      final exception = AppException.fromException(e);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isCategoriesLoading.value = false;
    }
  }
}
