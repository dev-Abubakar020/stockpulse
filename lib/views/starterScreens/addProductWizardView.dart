import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/theme/theme_helper.dart';
import '../../controllers/addProductWizardController.dart';

class AddProductWizardView extends GetView<AddProductWizardController> {
  const AddProductWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: Obx(() => controller.currentStep.value == 3
            ? const SizedBox.shrink()
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: theme.textPrimary, size: 20),
                onPressed: () {
                  if (controller.currentStep.value > 1) {
                    controller.previousStep();
                  } else {
                    Get.back();
                  }
                },
              )),
        title: Text(
          'Add Product',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(() => controller.currentStep.value == 3
              ? IconButton(
                  icon: Icon(Icons.close, color: theme.textPrimary),
                  onPressed: () => Get.back(),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      'Drafts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                )),
        ],
      ),
      body: SafeArea(
        child: Column(
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
      ),
    );
  }

  // ==================== WIDGET STEP PROGRESS INDICATOR ====================
  Widget _buildStepProgressIndicator(BuildContext context) {
    final theme = context.appTheme;
    final int step = controller.currentStep.value;

    return Container(
      color: theme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepNode(1, 'Details', step >= 1, step == 1, theme),
              _buildStepLine(step >= 2, theme),
              _buildStepNode(2, 'Pricing & Stock', step >= 2, step == 2, theme),
              _buildStepLine(step >= 3, theme),
              _buildStepNode(3, 'Review', step == 3, step == 3, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int stepNum, String title, bool isDoneOrCurrent, bool isCurrent, AppThemeHelper theme) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? theme.primary
                  : (isDoneOrCurrent ? theme.primary.withValues(alpha: 0.15) : theme.surfaceMuted),
              border: Border.all(
                color: isCurrent || isDoneOrCurrent ? theme.primary : theme.border,
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
            overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.all(24),
            children: [
              // Wizard subtitle label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Inventory Wizard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Product Image Box Placeholder container
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border, width: 1, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.camera_alt_outlined, color: theme.primary, size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add Product Image',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports PNG, JPG, or snap photo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // NAME field
              _buildFieldLabel('NAME *', theme),
              const SizedBox(height: 8),
              _buildTextField(controller.nameController, 'Enter product name', theme),
              const SizedBox(height: 20),

              // Category row selection label + New Category link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('CATEGORY *', theme),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      '+ New Category',
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategory.value,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: theme.textSecondary),
                    items: controller.categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.plusJakartaSans(color: theme.textPrimary, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedCategory.value = val;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal Category Chips selector items list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.categories.map((cat) {
                    final isSelected = controller.selectedCategory.value == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: theme.primary.withValues(alpha: 0.15),
                        backgroundColor: theme.surfaceMuted,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? theme.primary : theme.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSelected ? theme.primary : Colors.transparent),
                        ),
                        onSelected: (_) => controller.selectCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // SKU Field box
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('SKU / BARCODE', theme),
                  Text(
                    'EAN-13 / UPC',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller.skuController,
                'Scan or enter code',
                theme,
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: theme.primary),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),

              // MEASUREMENT UNIT field
              _buildFieldLabel('MEASUREMENT UNIT *', theme),
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
                    icon: Icon(Icons.keyboard_arrow_down, color: theme.textSecondary),
                    items: controller.units.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.plusJakartaSans(color: theme.textPrimary, fontSize: 14),
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
          padding: const EdgeInsets.all(20),
          color: theme.surface,
          child: ElevatedButton(
            onPressed: () => controller.nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Pricing & Stock',
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
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRICING DETAILS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Step 2 of 3',
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
                        _buildFieldLabel('Purchase Price *', theme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller.purchasePriceController,
                          'Rs. 0',
                          theme,
                          keyboardType: TextInputType.number,
                          prefixText: 'Rs. ',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cost per unit',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Sale Price *', theme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller.salePriceController,
                          'Rs. 0',
                          theme,
                          keyboardType: TextInputType.number,
                          prefixText: 'Rs. ',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Retail customer price',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary),
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
                  color: const Color(0xFFF0FDF4), // Very soft green background match design
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
                      child: const Icon(Icons.attach_money, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Profit',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rs. ${controller.estimatedProfit.value.toStringAsFixed(2)} / unit',
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Text(
                        '${controller.marginPercentage.value.toStringAsFixed(1)}% Margin',
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
                'STOCK & INVENTORY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Initial Stock Quantity counter widget box stepper row
              _buildFieldLabel('Initial Stock Quantity *', theme),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: theme.textPrimary),
                      onPressed: () => controller.decrementStock(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${controller.initialStock.value} pcs',
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    IconButton(
                      icon: Icon(Icons.add, color: theme.textPrimary),
                      onPressed: () => controller.incrementStock(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Low Stock Alert Limit stepper row element
              _buildFieldLabel('Low Stock Alert Limit *', theme),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: theme.textPrimary),
                      onPressed: () => controller.decrementLowStock(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${controller.lowStockLimit.value} PCS LIMIT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    IconButton(
                      icon: Icon(Icons.add, color: theme.textPrimary),
                      onPressed: () => controller.incrementLowStock(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Track Stock Switch Toggle Row
              _buildSwitchRow(
                'Track Stock Quantity',
                'Deduct automatically with each sale',
                controller.trackStock,
                theme,
              ),
              const Divider(height: 24),

              // Active & Available Switch Toggle Row
              _buildSwitchRow(
                'Active & Available for Sale',
                'Visible in catalog and POS checkout',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Back',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save & Review →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                  child: const Icon(Icons.check, size: 36, color: Color(0xFF16A34A)),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Product Added Successfully',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
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
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: theme.textSecondary, height: 1.4),
                      children: [
                        TextSpan(
                          text: controller.nameController.text,
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const TextSpan(text: ' has been listed and is now live in store inventory.'),
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
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: theme.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🥤', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Live',
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
                                  _buildBadge(controller.selectedCategory.value, theme),
                                  const SizedBox(width: 6),
                                  _buildBadge(controller.selectedUnit.value, theme, isGreen: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Barcode', controller.skuController.text, theme),
                    _buildSummaryRow('Purchase Price', 'Rs. ${controller.purchasePriceController.text}', theme),
                    _buildSummaryRow('Sale Price', 'Rs. ${controller.salePriceController.text}', theme, isBoldValue: true),
                    _buildSummaryRow('Current Stock', '${controller.initialStock.value} pcs', theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ready for Shelf mini row bar item info box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.print_outlined, color: theme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready for Shelf',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            ),
                          ),
                          Text(
                            'Barcode synced to POS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'PRINT LABEL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'View in Inventory →',
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
                  '+ Add Another Product',
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
  Widget _buildFieldLabel(String text, AppThemeHelper theme) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: theme.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    AppThemeHelper theme, {
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.textHint),
        prefixText: prefixText,
        prefixStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.textPrimary, fontWeight: FontWeight.w500),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildSwitchRow(String title, String subtitle, RxBool value, AppThemeHelper theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: theme.textSecondary),
              ),
            ],
          ),
        ),
        Obx(() => Switch.adaptive(
              value: value.value,
              activeColor: theme.primary,
              onChanged: (val) => value.value = val,
            )),
      ],
    );
  }

  Widget _buildBadge(String text, AppThemeHelper theme, {bool isGreen = false}) {
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

  Widget _buildSummaryRow(String label, String value, AppThemeHelper theme, {bool isBoldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: theme.textSecondary),
        ),
        Text(
          value,
          style: isBoldValue
              ? GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: theme.textPrimary)
              : GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary),
        ),
      ],
    );
  }
}
