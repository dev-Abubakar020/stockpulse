import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
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
  String _searchQuery = '';
  bool _printInvoice = true;
  bool _shareWhatsApp = false;
  String? _createdSaleId;
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryGreen = Color(0xFF0D5E3A);

  static const Color lightGreenBg = Color(0xFFE8F5E9);

  static const Color surfaceColor = Color(0xFFF9FAFB);

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    _searchController.clear();

    setState(() {
      _currentStep = 0;
      _searchQuery = '';
      _printInvoice = true;
      _shareWhatsApp = false;
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
    return PopScope(
      canPop: _currentStep == 0,

      onPopInvoked: (didPop) {
        if (didPop) return;

        _handleBack();
      },

      child: Scaffold(
        backgroundColor: surfaceColor,

        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: Obx(() => _buildCurrentStepContent())),
              if (_currentStep != 3) Obx(() => _buildBottomBar()),
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
      return CustomAppBar(
        title: const Text(AppConstants.cartDetail),
        showBackArrow: true,
        leadingOnPressed: _handleBack,
      );
    }

    return CustomAppBar(
      title: Text('New ${AppConstants.saleTitle}'),
      showBackArrow: true,
      leadingOnPressed: _handleBack,
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

  Widget _buildStep1SelectProducts() {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = saleController.products.where((product) {
      if (!product.isActive) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return product.article.toLowerCase().contains(query) ||
          (product.barcode ?? '').toLowerCase().contains(query) ||
          (product.color ?? '').toLowerCase().contains(query) ||
          (product.size ?? '').toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: AppConstants.searchHint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: textMuted,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? _buildNoProducts()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),

                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 16, color: borderColor),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final qty = saleController.quantityOf(product.id);
                    final isInCart = saleController.isSelected(product.id);
                    final outOfStock = product.currentStock <= 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),

                      child: Row(
                        children: [
                          const Text('📦', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.article,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs. ${product.salePrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${AppConstants.stockLabel}${_formatQuantity(product.currentStock)} ${product.unit}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: outOfStock ? Colors.red : textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // if (product.barcode != null &&
                                //     product.barcode!.isNotEmpty) ...[
                                //   const SizedBox(height: 2),
                                //   Text(
                                //     '${AppConstants.barcodeLabel}${product.barcode}',
                                //
                                //     style: GoogleFonts.plusJakartaSans(
                                //       fontSize: 10,
                                //       color: textMuted,
                                //     ),
                                //   ),
                                // ],
                              ],
                            ),
                          ),

                          Obx(() {
                            final isInCart = saleController.isSelected(
                              product.id,
                            );
                            final qty = saleController.quantityOf(product.id);

                            if (isInCart) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildQuantityControls(product, qty),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rs. ${saleController.lineTotal(product).toStringAsFixed(2)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              );
                            } else if (outOfStock) {
                              return Text(
                                AppConstants.statusOutOfStock,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  saleController.addProduct(product);
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            }
                          }),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(ProductItemModel product, double qty) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => saleController.decrementProduct(product),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.remove, size: 24, color: textDark),
            ),
          ),
          SizedBox(width: 8,),
          Text(
            _formatQuantity(qty),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          SizedBox(width: 8,),
          InkWell(
            onTap: () => saleController.addProduct(product),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.add, size: 24, color: textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ReviewCart() {
    final cartItems = saleController.products
        .where((product) => saleController.isSelected(product.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            AppConstants.customer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(12),

              border: Border.all(color: borderColor),
            ),

            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,

                  decoration: BoxDecoration(
                    color: lightGreenBg,

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    AppConstants.walkInCustomer,

                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,

                      fontWeight: FontWeight.w600,

                      color: textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                AppConstants.cartItem,

                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),

              Obx(() {
                final isEmpty = saleController.quantities.isEmpty;

                return GestureDetector(
                  onTap: isEmpty ? null : saleController.clearCart,
                  child: Text(
                    AppConstants.clrAll,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isEmpty ? Colors.grey : primaryGreen,
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          if (cartItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),

              alignment: Alignment.center,

              child: Text(
                AppConstants.cartEmpty,
                style: GoogleFonts.plusJakartaSans(
                  color: textMuted,
                  fontSize: 14,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 18, color: borderColor),
              itemBuilder: (context, index) {
                final product = cartItems[index];

                return Obx(() {
                  // Re-fetch reactive values inside Obx
                  final quantity = saleController.quantityOf(product.id);
                  final salePrice = saleController.salePriceOf(product);
                  final lineTotal = saleController.lineTotal(product);

                  // If item was removed (quantity 0), show nothing or a removed state.
                  // Since we are inside a ListView and cartItems is calculated outside,
                  // we might see a frame with qty 0 before list rebuilds.
                  if (quantity <= 0) return const SizedBox.shrink();

                  return Row(
                    children: [
                      const Text('📦', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.article,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Rs. ${salePrice.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Interactive Quantity Controls
                      _buildQuantityControls(product, quantity),
                      const SizedBox(width: 12),

                      SizedBox(
                        width: 80,
                        child: Text(
                          'Rs. ${lineTotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () {
                          saleController.removeProduct(product.id);
                        },
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  );
                });
              },
            ),

          const SizedBox(height: 22),

          // ====================================================
          // NOTE
          // ====================================================
          Text(
            AppConstants.addNote,

            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,

              fontWeight: FontWeight.w600,

              color: textDark,
            ),
          ),

          const SizedBox(height: 8),

          CustomTextField(
            controller: saleController.noteController,

            hintText: AppConstants.noteHint,
          ),

          const SizedBox(height: 18),

          // ====================================================
          // DISCOUNT
          // ====================================================
          Text(
            AppConstants.disTitle,

            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,

              fontWeight: FontWeight.w600,

              color: textDark,
            ),
          ),

          const SizedBox(height: 8),

          CustomTextField(
            controller: saleController.discountController,

            hintText: '0',

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            onChanged: saleController.updateDiscount,
          ),

          const SizedBox(height: 22),

          // ====================================================
          // SUMMARY
          // ====================================================
          _buildSummaryLine(
            AppConstants.subtotal,
            'Rs. ${saleController.subtotal.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 8),

          _buildSummaryLine(
            AppConstants.discountLabel,
            '- Rs. ${saleController.discount.value.toStringAsFixed(2)}',
          ),

          const Divider(height: 24, color: borderColor),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                AppConstants.total,

                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,

                  fontWeight: FontWeight.w800,

                  color: textDark,
                ),
              ),

              Text(
                'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',

                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,

                  fontWeight: FontWeight.w800,

                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3
  // PAYMENT
  // ============================================================

  Widget _buildStep3Payment() {
    final paymentMethods = [
      {'id': 'Cash', 'icon': Icons.payments_outlined},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // TOTAL
          // ====================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),

            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),

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

                    color: textDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ====================================================
          // PAYMENT METHOD
          // ====================================================
          Text(
            AppConstants.selectPaymentMethod,

            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,

              fontWeight: FontWeight.w700,

              color: textDark,
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

                  // For Card, received/change
                  // are not required.
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
                    color: isSelected ? primaryGreen : Colors.white,

                    borderRadius: BorderRadius.circular(10),

                    border: Border.all(
                      color: isSelected ? primaryGreen : borderColor,
                    ),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(
                        pm['icon'] as IconData,

                        size: 18,

                        color: isSelected ? Colors.white : textDark,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        pm['id'] as String,

                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,

                          fontWeight: FontWeight.w600,

                          color: isSelected ? Colors.white : textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // ====================================================
          // RECEIVED AMOUNT
          // ====================================================
          if (saleController.paymentMethod.value == 'cash') ...[
            Text(
              AppConstants.receivedAmountLabel,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,

                fontWeight: FontWeight.w600,

                color: textDark,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: borderColor),
              ),

              child: TextField(
                controller: saleController.receivedAmountController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                onChanged: (_) {
                  // Needed to refresh change.
                  saleController.paymentMethod.refresh();
                },

                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,

                  fontWeight: FontWeight.w600,

                  color: textDark,
                ),

                decoration: const InputDecoration(
                  border: InputBorder.none,

                  prefixText: 'Rs. ',

                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
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

                color: textDark,
              ),
            ),

            const SizedBox(height: 24),
          ],

          // // ====================================================
          // // INVOICE OPTIONS
          // // ====================================================
          // Text(
          //   AppConstants.invoiceOptions,
          //
          //   style: GoogleFonts.plusJakartaSans(
          //     fontSize: 14,
          //
          //     fontWeight: FontWeight.w700,
          //
          //     color: textDark,
          //   ),
          // ),
          //
          // const SizedBox(height: 12),
          //
          // _buildInvoiceOptionRow(
          //   icon: Icons.print_outlined,
          //
          //   title: AppConstants.printInvoice,
          //
          //   value: _printInvoice,
          //
          //   onChanged: (value) {
          //     setState(() {
          //       _printInvoice = value;
          //     });
          //   },
          // ),
          //
          // const SizedBox(height: 10),
          //
          // _buildInvoiceOptionRow(
          //   icon: Icons.chat_outlined,
          //
          //   title: AppConstants.shareWhatsApp,
          //
          //   value: _shareWhatsApp,
          //
          //   onChanged: (value) {
          //     setState(() {
          //       _shareWhatsApp = value;
          //     });
          //   },
          // ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 4
  // SUCCESS
  // ============================================================

  Widget _buildStep4Success() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // ==================================================
            // SUCCESS ICON
            // ==================================================

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

                color: textDark,

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

            // ==================================================
            // RECEIPT SUMMARY
            // ==================================================
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: borderColor),
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

                  const Divider(height: 20, color: borderColor),

                  _buildReceiptRow(
                    AppConstants.totalAmountLabel,
                    'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==================================================
            // VIEW SALE
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  // Sale Details route can be
                  // connected next.
                  Navigator.of(context).pop();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  elevation: 0,
                ),

                child: Text(
                  AppConstants.viewSales,

                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,

                    fontWeight: FontWeight.w700,

                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // ADD ANOTHER
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: _resetSale,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  elevation: 0,
                ),

                child: Text(
                  AppConstants.addAnotherSale,

                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,

                    fontWeight: FontWeight.w700,

                    color: textDark,
                  ),
                ),
              ),
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
    // ==========================================================
    // STEP 1
    // ==========================================================

    if (_currentStep == 0) {
      if (saleController.quantities.isEmpty) {
        return const SizedBox();
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),

        decoration: const BoxDecoration(
          color: Colors.white,

          border: Border(top: BorderSide(color: borderColor)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: textDark,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '${saleController.totalItemsCount} ${AppConstants.itemsLabel}',

                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,

                        fontWeight: FontWeight.w600,

                        color: textDark,
                      ),
                    ),
                  ],
                ),

                Text(
                  'Rs. ${saleController.totalAmount.toStringAsFixed(2)}',

                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,

                    fontWeight: FontWeight.w800,

                    color: textDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  elevation: 0,
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      AppConstants.viewCart,

                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,

                        fontWeight: FontWeight.w700,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 6),

                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // STEP 2
    // ==========================================================

    if (_currentStep == 1) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),

        decoration: const BoxDecoration(
          color: Colors.white,

          border: Border(top: BorderSide(color: borderColor)),
        ),

        child: SizedBox(
          width: double.infinity,
          height: 48,

          child: ElevatedButton(
            onPressed: saleController.quantities.isEmpty
                ? null
                : () {
                    if (saleController.discount.value >
                        saleController.subtotal) {
                      Get.snackbar(
                        'Invalid Discount',
                        'Discount cannot exceed subtotal.',
                      );

                      return;
                    }

                    saleController.receivedAmountController.text =
                        saleController.totalAmount.toStringAsFixed(2);

                    setState(() {
                      _currentStep = 2;
                    });
                  },

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,

              disabledBackgroundColor: Colors.grey.shade300,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              elevation: 0,
            ),

            child: Text(
              AppConstants.proceedToPayment,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,

                fontWeight: FontWeight.w700,

                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // ==========================================================
    // STEP 3
    // ==========================================================

    if (_currentStep == 2) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),

        decoration: const BoxDecoration(
          color: Colors.white,

          border: Border(top: BorderSide(color: borderColor)),
        ),

        child: SizedBox(
          width: double.infinity,
          height: 48,

          child: ElevatedButton(
            onPressed: saleController.isLoading.value ? null : _completeSale,

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,

              disabledBackgroundColor: primaryGreen.withValues(alpha: 0.6),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              elevation: 0,
            ),

            child: saleController.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,

                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,

                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    AppConstants.completeSaleLabel,

                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,

                      fontWeight: FontWeight.w700,

                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  // ============================================================
  // NO PRODUCTS
  // ============================================================

  Widget _buildNoProducts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 52,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 12),

            Text(
              _searchQuery.isEmpty
                  ? AppConstants.noProductsAvailable
                  : AppConstants.noProductsFound,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,

                fontWeight: FontWeight.w600,

                color: textDark,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _searchQuery.isEmpty
                  ? AppConstants.addProductsBeforeSale
                  : AppConstants.tryAnotherProductName,

              textAlign: TextAlign.center,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,

          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textMuted),
        ),

        Text(
          value,

          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,

            fontWeight: FontWeight.w600,

            color: textDark,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INVOICE OPTION
  // ============================================================

  Widget _buildInvoiceOptionRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: borderColor),
      ),

      child: Row(
        children: [
          Icon(icon, size: 20, color: textDark),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,

                fontWeight: FontWeight.w600,

                color: textDark,
              ),
            ),
          ),

          Switch(
            value: value,

            onChanged: onChanged,

            activeColor: primaryGreen,

            activeTrackColor: lightGreenBg,
          ),
        ],
      ),
    );
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

            color: isBold ? textDark : textMuted,
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

              color: textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUANTITY FORMAT
  // ============================================================

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  // ============================================================
  // SHORT ID
  // ============================================================

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }

    return id.substring(0, 8).toUpperCase();
  }
}
