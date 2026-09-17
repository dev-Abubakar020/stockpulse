import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductWizardController extends GetxController {
  // Step navigation (1, 2, 3)
  final RxInt currentStep = 1.obs;

  // STEP 1 Fields
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final RxString selectedCategory = 'Beverages'.obs;
  final RxString selectedUnit = 'Piece (pcs)'.obs;
  final RxString imagePath = ''.obs; // Holds mock or picked image state

  final List<String> categories = ['Beverages', 'Groceries', 'Snacks', 'Dairy', 'Personal Care'];
  final List<String> units = ['Piece (pcs)', 'Box', 'Kilogram (kg)', 'Litre (L)'];

  // STEP 2 Fields
  final purchasePriceController = TextEditingController(text: '120');
  final salePriceController = TextEditingController(text: '180');
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
    // Pre-populate name or code as example mock if needed
    nameController.text = 'Coca Cola 1.5L';
    skuController.text = '5449000000996';

    // Add listeners to price changes for automatic margin calculation
    purchasePriceController.addListener(calculateMargin);
    salePriceController.addListener(calculateMargin);
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
    if (initialStock.value > 0) initialStock.value--;
  }

  void incrementLowStock() => lowStockLimit.value++;
  void decrementLowStock() {
    if (lowStockLimit.value > 0) lowStockLimit.value--;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void nextStep() {
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
    nameController.text = 'Coca Cola 1.5L';
    skuController.text = '5449000000996';
    purchasePriceController.text = '120';
    salePriceController.text = '180';
    selectedCategory.value = 'Beverages';
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
}
