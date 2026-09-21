import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../common/route/app_routes.dart';
import '../controllers/allProductsController.dart';
import '../models/productItemModel.dart';

class ProductDetailView extends GetView<ProductController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final ProductItemModel product = Get.arguments;

    final double profit = product.salePrice - product.purchasePrice;
    final double margin = product.salePrice > 0 ? (profit / product.salePrice) * 100 : 0;
    final double stockProgress = product.minStockThreshold > 0 
        ? (product.currentStock / (product.minStockThreshold * 2)).clamp(0.0, 1.0) 
        : 1.0;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: AppButton(
              text: 'Edit',
              onPressed: () => Get.toNamed(Routes.addProductWizard, arguments: product),
              fullWidth: false,
              height: 36,
              borderRadius: 8,
              prefixIcon: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- Product Overview Card ---
              _buildSectionCard(
                theme,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                        image: product.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(product.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          if (product.imageUrl == null)
                            const Center(child: Text('📦', style: TextStyle(fontSize: 48))),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Active',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
                          Row(
                            children: [
                              _buildSmallBadge(product.categoryName ?? 'Beverages', theme),
                              const SizedBox(width: 8),
                              const CustomStatusChip(textTitle: 'In Stock', type: StatusType.success),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.article,
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1.5 Litre (Family Bottle)', // Placeholder for subtitle/desc
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.qr_code_2, size: 16, color: theme.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                product.barcode ?? '5449000000996',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () async {
                                  final barcodeToCopy = product.barcode ?? '5449000000996';
                                  await Clipboard.setData(ClipboardData(text: barcodeToCopy));

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Barcode copied to clipboard!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.copy_rounded, size: 14, color: theme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Pricing & Margins Section ---
              _buildSectionCard(
                theme,
                title: 'Pricing & Margins',
                subtitle: 'Unit: ${product.unit}',
                icon: Icons.account_balance_wallet_outlined,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceBox(
                            'Retail Sale Price',
                            'Rs. ${product.salePrice.toInt()}',
                            'per unit',
                            theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPriceBox(
                            'Wholesale Purchase',
                            'Rs. ${product.purchasePrice.toInt()}',
                            'cost basis',
                            theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '+Rs. ${profit.toInt()} Net Profit',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF166534),
                                    ),
                                  ),
                                  Text(
                                    'Calculated per piece sold',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF166534).withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${margin.toStringAsFixed(1)}% Margin',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Inventory Health Section ---
              _buildSectionCard(
                theme,
                title: 'Inventory Health',
                icon: Icons.inventory_2_outlined,
                headerAction: const CustomStatusChip(textTitle: 'Healthy Stock', type: StatusType.success),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Available',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: theme.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${product.currentStock.toInt()} ',
                                      style: GoogleFonts.sora(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F766E),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'pcs',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: stockProgress,
                                  minHeight: 8,
                                  backgroundColor: theme.surfaceMuted,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(stockProgress * 100).toInt()}% of capacity',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.end,
                        //     children: [
                        //       Text(
                        //         'Low Stock Alert',textAlign: .end,
                        //         style: GoogleFonts.plusJakartaSans(fontSize: 12, color: theme.textSecondary),
                        //       ),
                        //       const SizedBox(height: 4),
                        //       RichText(
                        //         text: TextSpan(
                        //           children: [
                        //             TextSpan(
                        //               text: '${product.minStockThreshold.toInt()} ',
                        //               style: GoogleFonts.sora(
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: theme.textPrimary,
                        //               ),
                        //             ),
                        //             TextSpan(
                        //               text: 'pcs',
                        //               style: GoogleFonts.plusJakartaSans(
                        //                 fontSize: 13,
                        //                 color: theme.textSecondary,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// --- Action Buttons ---
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () {},
              //         icon: const Icon(Icons.swap_vert_rounded),
              //         label: const Text('Adjust Stock'),
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //           side: BorderSide(color: theme.border),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () {},
              //         icon: const Icon(Icons.print_outlined),
              //         label: const Text('Print Label'),
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //           side: BorderSide(color: theme.border),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 24),

              // --- Danger Zone ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Danger Zone',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Deleting this product will immediately remove it from the active POS register and transaction quick-picks. Past receipts remain archived.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.5,
                        color: const Color(0xFFBE123C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Delete Product',
                      onPressed: () => _confirmDelete(context, product),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE11D48),
                      prefixIcon: const Icon(Icons.delete_outline, color: Color(0xFFE11D48), size: 20),
                      boxShadow: [],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    AppThemeHelper theme, {
    required Widget child,
    String? title,
    String? subtitle,
    IconData? icon,
    Widget? headerAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: theme.primary),
                      const SizedBox(width: 8),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (headerAction != null) headerAction,
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, AppThemeHelper theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPriceBox(String label, String price, String sub, AppThemeHelper theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surfaceMuted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
          ),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductItemModel product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete ${product.article}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteProduct(product);
              Get.back(); // Return to All Products list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
