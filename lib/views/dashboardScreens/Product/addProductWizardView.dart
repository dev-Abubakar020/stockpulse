import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';

import '../../../common/theme/theme_helper.dart';
import '../../../controllers/addProductWizardController.dart';
import '../../../models/category_model.dart';
import '../../../utils/app_constants.dart';

class AddProductWizardView extends GetView<AddProductWizardController> {
  const AddProductWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: Obx(
          () => controller.currentStep.value == 3
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: theme.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    if (controller.currentStep.value > 1) {
                      controller.previousStep();
                    } else {
                      Get.back();
                    }
                  },
                ),
        ),
        title: Obx(
          () => Text(
            controller.editingProduct.value != null
                ? AppConstants.editProduct
                : AppConstants.addProductTitle,
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(
            () => controller.currentStep.value == 3
                ? IconButton(
                    icon: Icon(Icons.close, color: theme.textPrimary),
                    onPressed: () => Get.back(),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Text(
                        '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Step Progress Indicator Row Bar
          Obx(() => _buildStepProgressIndicator(context)),

          // Current active step view
          Expanded(
            child: Obx(() {
              switch (controller.currentStep.value) {
                case 1:
                  return _buildStep1ProductDetails(context);
                case 2:
                  return _buildStep2PricingStock(context);
                case 3:
                  return _buildStep3Success(context);
                default:
                  return const SizedBox.shrink();
              }
            }),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET STEP PROGRESS INDICATOR ====================
  Widget _buildStepProgressIndicator(BuildContext context) {
    final theme = context.appTheme;
    final int step = controller.currentStep.value;

    return Container(
      color: theme.surface,
      child: Column(
        children: [
          Row(
            children: [
              _buildStepNode(
                1,
                AppConstants.stepDetails,
                step >= 1,
                step == 1,
                theme,
              ),
              _buildStepLine(step >= 2, theme),
              _buildStepNode(
                2,
                AppConstants.stepPricingStock,
                step >= 2,
                step == 2,
                theme,
              ),
              _buildStepLine(step >= 3, theme),
              _buildStepNode(
                3,
                AppConstants.stepReview,
                step == 3,
                step == 3,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(
    int stepNum,
    String title,
    bool isDoneOrCurrent,
    bool isCurrent,
    AppThemeHelper theme,
  ) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? theme.primary
                  : isDoneOrCurrent
                  ? theme.primary.withValues(alpha: 0.15)
                  : theme.surfaceMuted,
              border: Border.all(
                color: isCurrent || isDoneOrCurrent
                    ? theme.primary
                    : theme.border,
                width: 2,
              ),
            ),
            child: Center(
              child: isDoneOrCurrent && !isCurrent
                  ? Icon(Icons.check, size: 14, color: theme.primary)
                  : Text(
                      '$stepNum',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : theme.textSecondary,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? theme.primary : theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive, AppThemeHelper theme) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? theme.primary : theme.border,
    );
  }

  // ==================== STEP 1: PRODUCT DETAILS ====================
  Widget _buildStep1ProductDetails(BuildContext context) {
    final theme = context.appTheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              // Wizard subtitle label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Text(
                          AppConstants.quickInventoryWizard,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Product Image Box Placeholder container
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Obx(() {
                  final pickedFile = controller.pickedFile.value;
                  final networkUrl = controller.networkImageUrl.value;

                  final hasImage =
                      pickedFile != null ||
                      (networkUrl != null && networkUrl.isNotEmpty);

                  return Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.border, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ───────── IMAGE ─────────
                          if (pickedFile != null)
                            Image.file(File(pickedFile.path), fit: BoxFit.cover)
                          else if (networkUrl != null && networkUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: networkUrl,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 300),

                              // Shimmer while loading
                              placeholder: (_, _) => Shimmer.fromColors(
                                baseColor: theme.isDark
                                    ? const Color(0xFF131D2E)
                                    : const Color(0xFFE2E8F0),
                                highlightColor: theme.isDark
                                    ? const Color(0xFF1E2D44)
                                    : const Color(0xFFF8FAFC),
                                child: Container(color: Colors.white),
                              ),

                              // Error
                              errorWidget: (_, _, _) => Container(
                                color: theme.surfaceMuted,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: theme.textSecondary,
                                  size: 36,
                                ),
                              ),
                            ),

                          // ───────── EMPTY STATE ─────────
                          if (!hasImage)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: theme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: theme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppConstants.addProductImage,
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppConstants.supportsImageFormats,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                          // ───────── EDIT BUTTON ─────────
                          if (hasImage)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.5,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // NAME field
              _buildFieldLabel(
                AppConstants.nameHeader,
                isRequired: true,
                theme,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller.nameController,
                AppConstants.enterProductNameHint,
                theme,
              ),
              const SizedBox(height: 20),

              // Category row selection label + New Category link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel(
                    AppConstants.categoryHeader,
                    isRequired: true,
                    theme,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Get.toNamed(Routes.addCategories);
                      controller.fetchCategories();
                    },
                    child: Text(
                      AppConstants.newCategoryBtn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Custom Category drop-down
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Obx(() {
                  if (controller.isCategoriesLoading.value) {
                    return const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.categories.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        AppConstants.noCategoriesAvailable,
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<CategoryModel>(
                      value: controller.selectedCategory.value,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.textSecondary,
                      ),
                      dropdownColor: theme.surface,
                      items: controller.categories.map((category) {
                        return DropdownMenuItem<CategoryModel>(
                          value: category,
                          child: Text(
                            category.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: theme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (category) {
                        if (category != null) {
                          controller.selectCategory(category);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // SKU Field box
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel(AppConstants.skuBarcodeHeader, theme),
                  Text(
                    AppConstants.eanUpcSubHeader,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller.barcodeController,
                AppConstants.enterCodeHint,
                theme,
                textCapitalization: TextCapitalization.characters,
                prefixIcon: Icon(
                  Icons.qr_code_2_rounded,
                  color: theme.textSecondary,
                ),
              ),
              // _buildTextField(
              //   controller.barcodeController,
              //   AppConstants.enterCodeHint,
              //   theme,
              //   // suffixIcon: IconButton(
              //   //   icon: Icon(Icons.qr_code_scanner, color: theme.primary),
              //   //   onPressed: () {},
              //   // ),
              // ),
              const SizedBox(height: 20),

              // MEASUREMENT UNIT field
              _buildFieldLabel(
                AppConstants.measurementUnitHeader,
                isRequired: true,
                theme,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedUnit.value,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.textSecondary,
                    ),
                    items: controller.units.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedUnit.value = val;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom continue action sticky footer bar button
        Container(
          padding: EdgeInsets.only(top: 20),
          color: theme.surface,
          child: ElevatedButton(
            onPressed: () => controller.nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppConstants.continueToPricingStock,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STEP 2: PRICING & STOCK ====================
  Widget _buildStep2PricingStock(BuildContext context) {
    final theme = context.appTheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 18),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConstants.pricingDetailsHeader,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppConstants.step2Of3,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purchase Price and Sale Price horizontal row fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(
                          AppConstants.purchasePriceLabel,
                          isRequired: true,
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller.purchasePriceController,
                          AppConstants.zeroPrice,
                          theme,
                          keyboardType: TextInputType.number,
                          prefixText: AppConstants.defaultCurrency,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.costPerUnit,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(
                          AppConstants.salePriceLabel,
                          isRequired: true,
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller.salePriceController,
                          AppConstants.zeroPrice,
                          theme,
                          keyboardType: TextInputType.number,
                          prefixText: AppConstants.defaultCurrency,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.retailCustomerPrice,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Profit Estimation & Margin Banner widget item box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF0FDF4,
                  ), // Very soft green background match design
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF15803D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.estimatedProfit,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppConstants.defaultCurrency}${controller.estimatedProfit.value.toStringAsFixed(2)}${AppConstants.perUnitSuffix}',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Text(
                        '${controller.marginPercentage.value.toStringAsFixed(1)}${AppConstants.marginSuffix}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                AppConstants.stockInventoryHeader,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Initial Stock Quantity counter widget box stepper row
              _buildFieldLabel(
                AppConstants.initialStockQty,
                isRequired: true,
                theme,
              ),
              const SizedBox(height: 8),

              Obx(() {
                final isDecimal = controller.isDecimalUnit;

                return Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: theme.textPrimary),
                        onPressed: controller.decrementStock,
                      ),

                      const VerticalDivider(width: 1),

                      Expanded(
                        child: TextField(
                          controller: controller.initialStockController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: isDecimal,
                          ),
                          inputFormatters: _quantityFormatters(isDecimal),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            suffixText: controller.unitSymbol,
                            suffixStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),

                      const VerticalDivider(width: 1),

                      IconButton(
                        icon: Icon(Icons.add, color: theme.textPrimary),
                        onPressed: controller.incrementStock,
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Low Stock Alert Limit stepper row element
              _buildFieldLabel(
                AppConstants.lowStockAlertLimit,
                isRequired: true,
                theme,
              ),
              const SizedBox(height: 8),

              Obx(() {
                final isDecimal = controller.isDecimalUnit;

                return Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: theme.textPrimary),
                        onPressed: controller.decrementLowStock,
                      ),

                      const VerticalDivider(width: 1),

                      Expanded(
                        child: TextField(
                          controller: controller.lowStockController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: isDecimal,
                          ),
                          inputFormatters: _quantityFormatters(isDecimal),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            suffixText: controller.unitSymbol,
                            suffixStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),

                      const VerticalDivider(width: 1),

                      IconButton(
                        icon: Icon(Icons.add, color: theme.textPrimary),
                        onPressed: controller.incrementLowStock,
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Track Stock Switch Toggle Row
              _buildSwitchRow(
                AppConstants.trackStockQty,
                AppConstants.deductAutoSale,
                controller.trackStock,
                theme,
              ),
              const Divider(height: 24),

              // Active & Available Switch Toggle Row
              _buildSwitchRow(
                AppConstants.activeAvailableSale,
                AppConstants.visibleCatalogPos,
                controller.activeForSale,
                theme,
              ),
            ],
          ),
        ),

        // Bottom Double Action Bar Footer Buttons
        Container(
          padding: const EdgeInsets.all(20),
          color: theme.surface,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => controller.previousStep(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.border),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppConstants.backBtn,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => controller.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Obx(
                    () => Text(
                      controller.editingProduct.value != null
                          ? AppConstants.updateAndReview
                          : AppConstants.saveAndReview,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== STEP 3: SUCCESS & CONFIRMATION SCREEN ====================
  Widget _buildStep3Success(BuildContext context) {
    final theme = context.appTheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            children: [
              // Large center success badge check icon mark
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 36,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Obx(
                  () => Text(
                    controller.editingProduct.value != null
                        ? AppConstants.productUpdatedSuccess
                        : AppConstants.productAddedSuccess,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: theme.textSecondary,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: controller.nameController.text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: controller.editingProduct.value != null
                              ? AppConstants.hasBeenUpdatedInventory
                              : AppConstants.hasBeenListedLive,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Product Info Summary Card Preview container block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Product Image
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: theme.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            image: _buildProductImage(controller),
                          ),
                          alignment: Alignment.center,
                          child:
                              controller.pickedFile.value == null &&
                                  controller.networkImageUrl.value == null
                              ? const Text('🥤', style: TextStyle(fontSize: 24))
                              : null,
                        ),

                        const SizedBox(width: 14),

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      AppConstants.liveStatus,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      controller.nameController.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.sora(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  _buildBadge(
                                    controller.selectedCategory.value?.name ??
                                        '',
                                    theme,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildBadge(
                                    controller.selectedUnit.value,
                                    theme,
                                    isGreen: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Print Button
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.primary.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Icon(
                              Icons.print_outlined,
                              size: 20,
                              color: theme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      AppConstants.barcodeHeader,
                      controller.barcodeController.text,
                      theme,
                    ),
                    _buildSummaryRow(
                      AppConstants.purchasePriceLabel,
                      '${AppConstants.defaultCurrency}${controller.purchasePriceController.text}',
                      theme,
                    ),
                    _buildSummaryRow(
                      AppConstants.salePriceLabel,
                      '${AppConstants.defaultCurrency}${controller.salePriceController.text}',
                      theme,
                      isBoldValue: true,
                    ),
                    _buildSummaryRow(
                      AppConstants.currentStockHeader,
                      '${controller.formatQuantity(controller.initialStock)} '
                      '${controller.unitSymbol}',
                      theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action action buttons footer footer
        Container(
          padding: const EdgeInsets.all(20),
          color: theme.surface,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppConstants.viewInInventory,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => controller.resetWizard(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  AppConstants.addAnotherProduct,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== HELPER BUILDERS ====================
  Widget _buildFieldLabel(
    String text,
    AppThemeHelper theme, {
    bool isRequired = false,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),

          if (isRequired)
            TextSpan(
              text: ' *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    AppThemeHelper theme, {
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? prefixText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,

      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: theme.textPrimary,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: theme.textHint,
        ),

        prefixIcon: prefixIcon,
        prefixText: prefixText,

        prefixStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: theme.textPrimary,
          fontWeight: FontWeight.w500,
        ),

        suffixIcon: suffixIcon,

        filled: true,
        fillColor: theme.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.border, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    RxBool value,
    AppThemeHelper theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Switch.adaptive(
            value: value.value,
            // ignore: deprecated_member_use
            activeColor: theme.primary,
            onChanged: (val) => value.value = val,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    String text,
    AppThemeHelper theme, {
    bool isGreen = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFFDCFCE7) : theme.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isGreen ? const Color(0xFF15803D) : theme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    AppThemeHelper theme, {
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: theme.textSecondary,
          ),
        ),
        Text(
          value,
          style: isBoldValue
              ? GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                )
              : GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
        ),
      ],
    );
  }

  DecorationImage? _buildProductImage(AddProductWizardController controller) {
    if (controller.pickedFile.value != null) {
      return DecorationImage(
        image: FileImage(File(controller.pickedFile.value!.path)),
        fit: BoxFit.cover,
      );
    }
    if (controller.networkImageUrl.value != null) {
      return DecorationImage(
        image: NetworkImage(controller.networkImageUrl.value!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  List<TextInputFormatter> _quantityFormatters(bool allowDecimal) {
    return [
      FilteringTextInputFormatter.allow(
        allowDecimal ? RegExp(r'^\d*\.?\d{0,3}') : RegExp(r'^\d*'),
      ),
    ];
  }
}
