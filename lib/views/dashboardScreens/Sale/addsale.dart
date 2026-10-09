import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/services/role_service.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../../common/route/app_routes.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../controllers/sale_controller.dart';
import '../../../models/productItemModel.dart';
import '../../../models/sale_model.dart';
import '../../../services/initialpdfview.dart';
import '../../../services/sale_pdf_service.dart';
import '../../receipts/thermal_sale_receipt.dart';
import 'barcodescanner.dart';

class AddSale extends GetView<SaleController> {
  final ProductItemModel? initialProduct;

  AddSale({
    super.key,
    this.initialProduct,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearCart();
      if (initialProduct != null) {
        controller.addProduct(initialProduct!);
      }
    });
  }

  static const Color primaryGreen = AppColors.primary;
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Obx(() {
      final step = controller.currentStep.value;

      return PopScope(
        canPop: step == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.handleBack(context);
        },
        child: CustomScreen(
          backgroundColor: theme.background,
          appBar: _buildTopBar(context, step),
          body: _buildCurrentStepContent(context, step),
          bottomNavigationBar: step != 2
              ? Obx(() {
                  final _ = controller.quantities.length;
                  return _buildBottomBar(context, step);
                })
              : null,
        ),
      );
    });
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, int step) {
    if (step == 2) {
      return CustomAppBar(
        leadingIcon: Icons.close_rounded,
        leadingOnPressed: () => controller.viewSale(),
      );
    }

    if (step == 1) {
      return CustomAppBar(
        title: Text(AppConstants.cartDetailsTitle),
        showBackArrow: true,
        leadingOnPressed: () => controller.handleBack(context),
        actions: [
          CustomTextButton(
            text: AppConstants.reset,
            onPressed: controller.resetSale,
          ),
        ],
      );
    }

    return CustomAppBar(
      title: Text('New ${AppConstants.saleTitle}'),
      showBackArrow: true,
      leadingOnPressed: () => controller.handleBack(context),
      actions: [
        CustomTextButton(
          text: AppConstants.reset,
          onPressed: controller.resetSale,
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent(BuildContext context, int step) {
    switch (step) {
      case 0:
        return _buildStep1SelectProducts(context);
      case 1:
        return _buildStep2ReviewCart(context);
      case 2:
        return _buildStep4Success(context);
      default:
        return const SizedBox();
    }
  }

  Future<void> _scanProduct(BuildContext context) async {
    final String? barcode = await Get.to<String>(
      () => const BarcodeScannerView(),
    );

    if (barcode == null || barcode.trim().isEmpty) {
      return;
    }

    final product = await controller.productController
        .findProductByBarcode(barcode);

    if (product == null) {
      CustomSnackBar.warningSnackBar(
        title: 'Product Not Found',
        message: 'No product found with barcode $barcode.',
      );
      return;
    }

    controller.addProduct(product);
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
        final products = controller.products
            .where((product) => product.isActive)
            .toList();

        return _SaleProductPickerSheet(
          products: products,
          onSelected: (product) {
            controller.addProduct(product);
          },
        );
      },
    );
  }

  Widget _buildStep1SelectProducts(BuildContext context) {
    final isDark = context.isDark;

    return SingleChildScrollView(
      child: Obx(() {
        final selectedProducts = controller.products.where((product) {
          return controller.isSelected(product.id);
        }).toList();

        return _SectionCard(
          icon: Icons.shopping_cart_rounded,
          iconColor: primaryGreen,
          title: AppConstants.saleItemsHeader,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _scanProduct(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryGreen.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: primaryGreen,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
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
            ],
          ),
          child: selectedProducts.isEmpty
              ? const _EmptyItems(
                  label: AppConstants.noItemsAddedYet,
                  hint: AppConstants.tapAddProductsSale,
                )
              : Column(
                  children: List.generate(selectedProducts.length, (index) {
                    final product = selectedProducts[index];
                    final quantity = controller.quantityOf(product.id);
                    final lineTotal = controller.lineTotal(product);

                    return _SaleItemTile(
                      product: product,
                      index: index,
                      isDark: isDark,
                      quantity: quantity,
                      lineTotal: lineTotal,
                      onIncrement: () {
                        controller.addProduct(product);
                      },
                      onDecrement: () {
                        controller.decrementProduct(product);
                      },
                      onRemove: () {
                        controller.removeProduct(product.id);
                      },
                      onQuantityChanged: (value) {
                        controller.updateQuantity(product, value);
                      },
                      onLineTotalChanged: (value) {
                        controller.updateLineTotal(product.id, value);
                      },
                    );
                  }),
                ),
        );
      }),
    );
  }

  Widget _buildStep2ReviewCart(BuildContext context) {
    final isDark = context.isDark;

    return SingleChildScrollView(
      child: Obx(() {
        final _ = controller.quantities.length;
        final selectedProducts = controller.products.where((product) {
          return controller.isSelected(product.id);
        }).toList();

        return Column(
          children: [
            _SectionCard(
              icon: Icons.inventory_2_rounded,
              iconColor: primaryGreen,
              title: AppConstants.cartItemsHeader,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _scanProduct(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryGreen.withValues(alpha: 0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: primaryGreen,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
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
                ],
              ),
              child: selectedProducts.isEmpty
                  ? const _EmptyItems(
                      label: AppConstants.noItemsInCart,
                      hint: AppConstants.tapAddProductsSale,
                    )
                  : Column(
                      children: List.generate(selectedProducts.length, (index) {
                        final product = selectedProducts[index];
                        final quantity = controller.quantityOf(product.id);
                        final lineTotal = controller.lineTotal(product);

                        return _SaleItemTile(
                          product: product,
                          index: index,
                          isDark: isDark,
                          quantity: quantity,
                          lineTotal: lineTotal,
                          onIncrement: () {
                            controller.addProduct(product);
                          },
                          onDecrement: () {
                            controller.decrementProduct(product);
                          },
                          onRemove: () {
                            controller.removeProduct(product.id);
                          },
                          onQuantityChanged: (value) {
                            controller.updateQuantity(product, value);
                          },
                          onLineTotalChanged: (value) {
                            controller.updateLineTotal(product.id, value);
                          },
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              icon: Icons.calculate_rounded,
              iconColor: const Color(0xFF059669),
              title: AppConstants.costSummaryHeader,
              child: Column(
                children: [
                  if (Get.find<RoleService>().canApplyDiscount) ...[
                    CustomTextField(
                      controller: controller.discountController,
                      hintText: '0',
                      labelText: AppConstants.disTitle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: const Icon(Icons.local_offer_rounded, size: 18),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: controller.updateDiscount,
                    ),
                    const SizedBox(height: 18),
                  ],
                  _OrderSummaryRow(
                    label: AppConstants.subtotal,
                    value:
                        '${AppConstants.defaultCurrency}${controller.subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 4),
                  _OrderSummaryRow(
                    label: AppConstants.discountLabel,
                    value:
                        '- ${AppConstants.defaultCurrency}${controller.discount.value.toStringAsFixed(2)}',
                    valueColor: Colors.red,
                  ),
                  const Divider(height: 24),
                  _OrderSummaryRow(
                    label: AppConstants.total,
                    value:
                        '${AppConstants.defaultCurrency}${controller.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              icon: Icons.person_rounded,
              iconColor: primaryGreen,
              title: AppConstants.customerAndNotesHeader,
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
                    controller: controller.noteController,
                    hintText: AppConstants.noteHint,
                    labelText: AppConstants.notesLabel,
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

  Widget _buildStep4Success(BuildContext context) {
    final isDark = context.isDark;
    final theme = context.appTheme;
    final createdId = controller.createdSaleId.value;
    final SaleModel? sale = controller.createdSale.value ??
        (Get.arguments is SaleModel ? Get.arguments as SaleModel : null);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
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
                    controller.paymentMethod.value == 'cash'
                        ? AppConstants.cashLabel
                        : AppConstants.cardLabel,
                  ),
                  if (createdId != null) ...[
                    const SizedBox(height: 10),
                    _buildReceiptRow(
                      AppConstants.saleIdLabel,
                      _shortId(createdId),
                    ),
                  ],
                  const Divider(height: 20),
                  _buildReceiptRow(
                    AppConstants.totalAmountLabel,
                    'Rs. ${controller.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: AppConstants.viewSales,
              onPressed: controller.viewSale,
              backgroundColor: primaryGreen,
            ),
            const SizedBox(height: 12),
            AppButton(
              text: AppConstants.addAnotherSale,
              onPressed: controller.resetSale,
              backgroundColor: isDark
                  ? const Color(0xFF1E2D44)
                  : const Color(0xFFF3F4F6),
              foregroundColor: isDark ? Colors.white : textDark,
            ),
            if (sale != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.to(
                        () => PrintPreviewScreen(
                          documentName: sale.saleNo,
                          buildPdf: (format) {
                            return SalePdfService.generateSale(
                              format: format,
                              sale: sale,
                              items: controller.currentSaleItems,
                              creatorName: controller.creatorName.value,
                            );
                          },
                          thermalWidget: ThermalSaleReceipt(
                            sale: sale,
                            items: controller.currentSaleItems,
                            creatorName: controller.creatorName.value,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primary.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 20,
                            color: theme.primary.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppConstants.viewAsPdf,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int step) {
    if (step == 0) {
      if (controller.quantities.isEmpty) {
        return const SizedBox();
      }

      return _BottomSaveBar(
        label: 'Rs. ${controller.totalAmount.toStringAsFixed(2)}',
        buttonText: AppConstants.viewCart,
        buttonColor: primaryGreen,
        isLoading: false,
        onSave: () {
          controller.currentStep.value = 1;
        },
      );
    }

    if (step == 1) {
      return _BottomSaveBar(
        label: 'Rs. ${controller.totalAmount.toStringAsFixed(2)}',
        buttonText: AppConstants.completeSaleLabel,
        buttonColor: primaryGreen,
        isLoading: controller.isLoading.value,
        onSave: controller.isLoading.value
            ? null
            : () async {
                if (controller.discount.value > controller.subtotal) {
                  CustomSnackBar.warningSnackBar(
                    title: AppConstants.invalidDiscount,
                    message: AppConstants.discountExceedSubtotal,
                  );
                  return;
                }

                controller.receivedAmountController.text =
                    controller.totalAmount.toStringAsFixed(2);

                await controller.completeSale(context);
              },
      );
    }

    return const SizedBox();
  }

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
                trailing ?? const SizedBox.shrink(),
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
        width: 34,
        height: 38,
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
                  AppConstants.total,
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
              backgroundColor: buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleItemTile extends StatelessWidget {
  final ProductItemModel product;
  final int index;
  final bool isDark;
  final double quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final double lineTotal;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onLineTotalChanged;

  const _SaleItemTile({
    required this.product,
    required this.index,
    required this.isDark,
    required this.quantity,
    required this.lineTotal,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onLineTotalChanged,
  });

  @override
  Widget build(BuildContext context) {
    const green = AppColors.primary;
    final saleController = Get.find<SaleController>();
    final isDecimal = saleController.isDecimalUnit(product);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    isDecimal
                        ? _QuantityField(
                            value: quantity,
                            isDecimal: true,
                            onChanged: onQuantityChanged,
                          )
                        : Row(
                            children: [
                              _QtyBtn(
                                icon: Icons.remove,
                                onTap: onDecrement,
                                accentColor: green,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _QuantityField(
                                  value: quantity,
                                  isDecimal: false,
                                  onChanged: onQuantityChanged,
                                ),
                              ),
                              const SizedBox(width: 4),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.salePriceRs,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E2D44)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        '${AppConstants.defaultCurrency}${product.salePrice.toStringAsFixed(0)}',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppConstants.lineTotalHeader,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 140,
                child: _LineTotalField(
                  value: lineTotal,
                  onChanged: onLineTotalChanged,
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

class _LineTotalField extends StatefulWidget {
  final double value;
  final ValueChanged<String> onChanged;

  const _LineTotalField({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_LineTotalField> createState() => _LineTotalFieldState();
}

class _LineTotalFieldState extends State<_LineTotalField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatAmount(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
      if (!_hasFocus) {
        final value = _formatAmount(widget.value);
        if (_controller.text != value) {
          _controller.text = value;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant _LineTotalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasFocus && oldWidget.value != widget.value) {
      final value = _formatAmount(widget.value);
      if (_controller.text != value) {
        _controller.text = value;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleService = Get.find<RoleService>();
    final canEdit = roleService.canChangeSalePrice;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: !canEdit,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
      ],
      onChanged: canEdit ? widget.onChanged : null,
      textAlign: TextAlign.center,
      style: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _QuantityField extends StatefulWidget {
  final double value;
  final bool isDecimal;
  final ValueChanged<String> onChanged;

  const _QuantityField({
    required this.value,
    required this.isDecimal,
    required this.onChanged,
  });

  @override
  State<_QuantityField> createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<_QuantityField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  String _formatValue(double value) {
    if (!widget.isDecimal) {
      return value.toInt().toString();
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
      if (!_hasFocus) {
        _controller.text = _formatValue(widget.value);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _QuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (!_hasFocus) {
        final newText = _formatValue(widget.value);
        if (_controller.text != newText) {
          _controller.text = newText;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        if (widget.isDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}$'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: widget.onChanged,
      textAlign: TextAlign.center,
      style: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 9,
        ),
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
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _SaleProductPickerSheet extends StatelessWidget {
  final List<ProductItemModel> products;
  final ValueChanged<ProductItemModel> onSelected;
  final RxString _query = ''.obs;

  _SaleProductPickerSheet({
    required this.products,
    required this.onSelected,
  });

  List<ProductItemModel> get _filteredProducts {
    final query = _query.value.trim().toLowerCase();
    if (query.isEmpty) {
      return products;
    }
    return products.where((product) {
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
                      AppConstants.addProductToSale,
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.addProductWizard),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
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
                onChanged: (value) => _query.value = value,
                decoration: InputDecoration(
                  hintText: AppConstants.searchProductOrBarcode,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final filtered = _filteredProducts;
                if (filtered.isEmpty) {
                  return Center(
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
                          _query.value.isEmpty
                              ? AppConstants.noInverntriesAvailable
                              : AppConstants.noProductsFound,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final product = filtered[index];
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
                              onSelected(product);
                              Navigator.pop(context);
                            },
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }

  String _productSubtitle(ProductItemModel product) {
    final details = <String>[
      'Rs. ${product.salePrice}',
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
    return value.toStringAsFixed(0);
  }
}
