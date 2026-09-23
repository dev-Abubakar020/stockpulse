import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../common/widgets/appbar.dart';
import '../controllers/sale_controller.dart';
import '../models/productItemModel.dart';

class AddSale extends StatefulWidget {
  const AddSale({super.key});

  @override
  State<AddSale> createState() => _AddSaleState();
}

class _AddSaleState extends State<AddSale> {
  final SaleController saleController = Get.find<SaleController>();

  int _currentStep = 0;
  String? _createdSaleId;

  static const Color primaryGreen = AppColors.primary;
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      saleController.clearCart();
    });
  }

  void _handleBack() {
    if (_currentStep > 0 && _currentStep < 3) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _resetSale() {
    saleController.clearCart();
    setState(() {
      _currentStep = 0;
      _createdSaleId = null;
    });
  }

  Future<void> _completeSale() async {
    if (saleController.paymentMethod.value == 'cash') {
      final received = saleController.receivedAmount;
      if (received < saleController.totalAmount) {
        Get.snackbar(
          AppConstants.insufficientAmount,
          AppConstants.receivedAmountError,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final saleId = await saleController.createSale();
    if (saleId == null) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _createdSaleId = saleId;
      _currentStep = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildCurrentStepContent()),
              if (_currentStep != 3)
                Obx(() {
                  final _ = saleController.quantities.length;
                  final _discount = saleController.discount.value;
                  return _buildBottomBar();
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    if (_currentStep == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: textDark),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    if (_currentStep == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CustomAppBar(
          title: const Text('Cart Details'),
          showBackArrow: true,
          leadingOnPressed: _handleBack,
          actions: [CustomTextButton(text: 'Reset', onPressed: _resetSale)],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: CustomAppBar(
        title: Text('New ${AppConstants.saleTitle}'),
        showBackArrow: true,
        leadingOnPressed: _handleBack,
        actions: [CustomTextButton(text: 'Reset', onPressed: _resetSale)],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectProducts();
      case 1:
        return _buildStep2ReviewCart();
      case 2:
        return _buildStep3Payment();
      case 3:
        return _buildStep4Success();
      default:
        return const SizedBox();
    }
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final products = saleController.products
            .where((product) => product.isActive)
            .toList();

        return _SaleProductPickerSheet(
          products: products,
          onSelected: (product) {
            saleController.addProduct(product);
          },
        );
      },
    );
  }

  // ============================================================
  // STEP 1: SELECT PRODUCTS
  // ============================================================

  Widget _buildStep1SelectProducts() {
    final isDark = context.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Obx(() {
        final selectedProducts = saleController.products.where((product) {
          return saleController.isSelected(product.id);
        }).toList();

        return _SectionCard(
          icon: Icons.shopping_cart_rounded,
          iconColor: primaryGreen,
          title: 'Sale Items',
          trailing: GestureDetector(
            onTap: () => _showProductPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    AppConstants.add,
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: selectedProducts.isEmpty
              ? const _EmptyItems(
                  label: 'No items added yet',
                  hint: 'Tap "+ Add" to add products to sale',
                )
              : Column(
                  children: List.generate(selectedProducts.length, (index) {
                    final product = selectedProducts[index];
                    final quantity = saleController.quantityOf(product.id);
                    final salePrice = saleController.salePriceOf(product);

                    return _SaleItemTile(
                      product: product,
                      index: index,
                      isDark: isDark,
                      quantity: quantity,
                      salePrice: salePrice,
                      onIncrement: () {
                        saleController.addProduct(product);
                      },
                      onDecrement: () {
                        saleController.decrementProduct(product);
                      },
                      onRemove: () {
                        saleController.removeProduct(product.id);
                      },
                      onPriceChanged: (value) {
                        saleController.updateSalePrice(product.id, value);
                      },
                    );
                  }),
                ),
        );
      }),
    );
  }

  // ============================================================
  // STEP 2: REVIEW CART / CART DETAIL (MATCHING ADDPURCHASE UI)
  // ============================================================

  Widget _buildStep2ReviewCart() {
    final isDark = context.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final _ = saleController.quantities.length;
        final _discount = saleController.discount.value;
        final selectedProducts = saleController.products.where((product) {
          return saleController.isSelected(product.id);
        }).toList();

        return Column(
          children: [
            const SizedBox(height: 8),

            // 1. Cart Items Section
            _SectionCard(
              icon: Icons.inventory_2_rounded,
              iconColor: primaryGreen,
              title: 'Cart Items',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedProducts.isNotEmpty)
                    CustomTextButton(
                      text: 'Clear',
                      onPressed: saleController.clearCart,
                    ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showProductPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              child: selectedProducts.isEmpty
                  ? const _EmptyItems(
                      label: 'No items in cart',
                      hint: 'Tap "+ Add" to add products to sale',
                    )
                  : Column(
                      children: List.generate(selectedProducts.length, (index) {
                        final product = selectedProducts[index];
                        final quantity = saleController.quantityOf(product.id);
                        final salePrice = saleController.salePriceOf(product);

                        return _SaleItemTile(
                          product: product,
                          index: index,
                          isDark: isDark,
                          quantity: quantity,
                          salePrice: salePrice,
                          onIncrement: () {
                            saleController.addProduct(product);
                          },
                          onDecrement: () {
                            saleController.decrementProduct(product);
                          },
                          onRemove: () {
                            saleController.removeProduct(product.id);
                          },
                          onPriceChanged: (value) {
                            saleController.updateSalePrice(product.id, value);
                          },
                        );
                      }),
                    ),
            ),

            const SizedBox(height: 14),

            // 2. Cost Summary Section
            _SectionCard(
              icon: Icons.calculate_rounded,
              iconColor: const Color(0xFF059669),
              title: 'Cost Summary',
              child: Column(
                children: [
                  CustomTextField(
                    controller: saleController.discountController,
                    hintText: '0',
                    labelText: 'Discount (Rs.)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.local_offer_rounded, size: 18),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: saleController.updateDiscount,
                  ),
                  const SizedBox(height: 18),
                  _OrderSummaryRow(
                    label: 'Subtotal',
                    value: 'Rs. ${saleController.subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 4),
                  _OrderSummaryRow(
                    label: 'Discount',
                    value:
                        '- Rs. ${saleController.discount.value.toStringAsFixed(2)}',
                    valueColor: Colors.red,
                  ),
                  const Divider(height: 24),
                  _OrderSummaryRow(
                    label: 'Total',
                    value:
                        'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: primaryGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Customer & Notes Section
            _SectionCard(
              icon: Icons.person_rounded,
              iconColor: primaryGreen,
              title: 'Customer & Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF111A2E)
                          : const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E2D44)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: primaryGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppConstants.walkInCustomer,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: saleController.noteController,
                    hintText: AppConstants.noteHint,
                    labelText: 'Notes',
                    prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  // ============================================================
  // STEP 3: PAYMENT
  // ============================================================

  Widget _buildStep3Payment() {
    final isDark = context.isDark;
    final paymentMethods = [
      {'id': 'Cash', 'icon': Icons.payments_outlined},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOTAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111A2E) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.totalAmountLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : textDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // PAYMENT METHOD
          Text(
            AppConstants.selectPaymentMethod,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: paymentMethods.map((pm) {
              final method = (pm['id'] as String).toLowerCase();
              final isSelected = saleController.paymentMethod.value == method;

              return GestureDetector(
                onTap: () {
                  saleController.changePaymentMethod(pm['id'] as String);
                  if (method == 'card') {
                    saleController.receivedAmountController.text =
                        saleController.totalAmount.toStringAsFixed(2);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryGreen
                        : (isDark ? const Color(0xFF131D2E) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? primaryGreen
                          : (isDark ? const Color(0xFF1E2D44) : borderColor),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pm['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : textDark),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pm['id'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // RECEIVED AMOUNT
          if (saleController.paymentMethod.value == 'cash') ...[
            Text(
              AppConstants.receivedAmountLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: saleController.receivedAmountController,
              hintText: '0.00',
              prefixIcon: const Icon(Icons.money_rounded, size: 18),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                saleController.paymentMethod.refresh();
              },
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.changeLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs. ${saleController.changeAmount.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STEP 4: SUCCESS
  // ============================================================

  Widget _buildStep4Success() {
    final isDark = context.isDark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.saleCompletedSuccess,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppConstants.stockUpdatedAuto,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 24),

            // RECEIPT SUMMARY
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E2D44) : borderColor,
                ),
              ),
              child: Column(
                children: [
                  _buildReceiptRow(
                    AppConstants.statusLabel,
                    AppConstants.completedLabel,
                  ),
                  const SizedBox(height: 10),
                  _buildReceiptRow(
                    AppConstants.customer,
                    AppConstants.walkInCustomer,
                  ),
                  const SizedBox(height: 10),
                  _buildReceiptRow(
                    AppConstants.paymentMethodLabel,
                    saleController.paymentMethod.value == 'cash'
                        ? AppConstants.cashLabel
                        : AppConstants.cardLabel,
                  ),
                  if (_createdSaleId != null) ...[
                    const SizedBox(height: 10),
                    _buildReceiptRow(
                      AppConstants.saleIdLabel,
                      _shortId(_createdSaleId!),
                    ),
                  ],
                  const Divider(height: 20),
                  _buildReceiptRow(
                    AppConstants.totalAmountLabel,
                    'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            AppButton(
              text: AppConstants.viewSales,
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: primaryGreen,
            ),
            const SizedBox(height: 12),
            AppButton(
              text: AppConstants.addAnotherSale,
              onPressed: _resetSale,
              backgroundColor: isDark
                  ? const Color(0xFF1E2D44)
                  : const Color(0xFFF3F4F6),
              // textColor: isDark ? Colors.white : textDark,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    if (_currentStep == 0) {
      if (saleController.quantities.isEmpty) {
        return const SizedBox();
      }

      return _BottomSaveBar(
        label: 'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
        buttonText: AppConstants.viewCart,
        buttonColor: primaryGreen,
        isLoading: false,
        onSave: () {
          setState(() {
            _currentStep = 1;
          });
        },
      );
    }

    if (_currentStep == 1) {
      return _BottomSaveBar(
        label: 'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
        buttonText: AppConstants.proceedToPayment,
        buttonColor: primaryGreen,
        isLoading: false,
        onSave: saleController.quantities.isEmpty
            ? null
            : () {
                if (saleController.discount.value > saleController.subtotal) {
                  Get.snackbar(
                    'Invalid Discount',
                    'Discount cannot exceed subtotal.',
                  );
                  return;
                }

                saleController.receivedAmountController.text = saleController
                    .totalAmount
                    .toStringAsFixed(2);

                setState(() {
                  _currentStep = 2;
                });
              },
      );
    }

    if (_currentStep == 2) {
      return _BottomSaveBar(
        label: 'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
        buttonText: AppConstants.completeSaleLabel,
        buttonColor: primaryGreen,
        isLoading: saleController.isLoading.value,
        onSave: saleController.isLoading.value ? null : _completeSale,
      );
    }

    return const SizedBox();
  }

  // ============================================================
  // RECEIPT ROW
  // ============================================================

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? null : textMuted,
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return id.substring(0, 8).toUpperCase();
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 18, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SUMMARY ROW
// ================================================================

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _OrderSummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? null : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY ITEMS
// ================================================================

class _EmptyItems extends StatelessWidget {
  final String label;
  final String hint;

  const _EmptyItems({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.add_shopping_cart_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QUANTITY BUTTON
// ================================================================

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentColor;

  const _QtyBtn({
    required this.icon,
    this.onTap,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null
              ? accentColor.withValues(alpha: .1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? accentColor : Colors.grey,
        ),
      ),
    );
  }
}

// ================================================================
// BOTTOM SAVE BAR
// ================================================================

class _BottomSaveBar extends StatelessWidget {
  final String label;
  final String buttonText;
  final bool isLoading;
  final VoidCallback? onSave;
  final Color? buttonColor;

  const _BottomSaveBar({
    required this.label,
    required this.buttonText,
    required this.isLoading,
    required this.onSave,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D2E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: buttonColor ?? AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: AppButton(
              text: buttonText,
              isLoading: isLoading,
              onPressed: onSave,
              height: 48,
              backgroundColor: buttonColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SALE ITEM TILE
// ================================================================

class _SaleItemTile extends StatelessWidget {
  final ProductItemModel product;
  final int index;
  final bool isDark;
  final double quantity;
  final double salePrice;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final ValueChanged<String> onPriceChanged;

  const _SaleItemTile({
    required this.product,
    required this.index,
    required this.isDark,
    required this.quantity,
    required this.salePrice,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    const green = AppColors.primary;
    final lineTotal = quantity * salePrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111A2E) : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Index, Article, Details, Remove button
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: green,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.article,
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _buildProductDetails(product),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Quantity and Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity (${product.unit})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _QtyBtn(
                          icon: Icons.remove,
                          onTap: onDecrement,
                          accentColor: green,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            _formatQuantity(quantity),
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QtyBtn(
                          icon: Icons.add,
                          onTap: onIncrement,
                          accentColor: green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Sale Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale Price (Rs.)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SalePriceField(
                      initialValue: salePrice,
                      onChanged: onPriceChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Line Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Line Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rs. ${lineTotal.toStringAsFixed(2)}',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _buildProductDetails(ProductItemModel product) {
    final details = <String>[];
    if (product.color != null && product.color!.trim().isNotEmpty) {
      details.add(product.color!);
    }
    if (product.size != null && product.size!.trim().isNotEmpty) {
      details.add(product.size!);
    }
    if (product.barcode != null && product.barcode!.trim().isNotEmpty) {
      details.add('Barcode: ${product.barcode}');
    }
    details.add('Stock: ${_formatQuantity(product.currentStock)}');
    return details.join(' • ');
  }

  static String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(2);
  }
}

// ================================================================
// SALE PRICE FIELD
// ================================================================

class _SalePriceField extends StatefulWidget {
  final double initialValue;
  final ValueChanged<String> onChanged;

  const _SalePriceField({required this.initialValue, required this.onChanged});

  @override
  State<_SalePriceField> createState() => _SalePriceFieldState();
}

class _SalePriceFieldState extends State<_SalePriceField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(covariant _SalePriceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final value = widget.initialValue.toStringAsFixed(2);
      if (_controller.text != value) {
        _controller.text = value;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: widget.onChanged,
      style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: '0.00',
        prefixText: 'Rs. ',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ================================================================
// PRODUCT PICKER SHEET
// ================================================================

class _SaleProductPickerSheet extends StatefulWidget {
  final List<ProductItemModel> products;
  final ValueChanged<ProductItemModel> onSelected;

  const _SaleProductPickerSheet({
    required this.products,
    required this.onSelected,
  });

  @override
  State<_SaleProductPickerSheet> createState() =>
      _SaleProductPickerSheetState();
}

class _SaleProductPickerSheetState extends State<_SaleProductPickerSheet> {
  String _query = '';

  List<ProductItemModel> get _filteredProducts {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.products;
    }
    return widget.products.where((product) {
      final article = product.article.toLowerCase();
      final barcode = (product.barcode ?? '').toLowerCase();
      final color = (product.color ?? '').toLowerCase();
      final size = (product.size ?? '').toLowerCase();
      return article.contains(query) ||
          barcode.contains(query) ||
          color.contains(query) ||
          size.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const green = AppColors.primary;
    final products = _filteredProducts;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Product to Sale',
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search product or barcode...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _query.isEmpty
                                ? AppConstants.noProductsAvailable
                                : AppConstants.noProductsFound,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final product = products[index];
                        final outOfStock = product.currentStock <= 0;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: green.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: green,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            product.article,
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _productSubtitle(product),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: outOfStock
                                    ? Colors.red
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          trailing: outOfStock
                              ? Text(
                                  AppConstants.statusOutOfStock,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_circle_rounded,
                                  color: green,
                                ),
                          onTap: outOfStock
                              ? null
                              : () {
                                  widget.onSelected(product);
                                  Navigator.pop(context);
                                },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  String _productSubtitle(ProductItemModel product) {
    final details = <String>[
      'Rs. ${product.salePrice.toStringAsFixed(2)}',
      'Stock: ${_formatNumber(product.currentStock)}',
      product.unit,
    ];
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      details.add('Barcode: ${product.barcode}');
    }
    return details.join(' • ');
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}
