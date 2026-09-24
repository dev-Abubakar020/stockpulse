import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../../common/route/app_routes.dart';
import '../../../common/widgets/alertDialog.dart';
import '../../../common/widgets/appbar.dart';
import '../../../controllers/allProductsController.dart';
import '../../../models/productItemModel.dart';

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

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: Text(AppConstants.detailPTitle),
        showBackArrow: true,
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                    () => Get.toNamed(Routes.addProductWizard,arguments: product),

              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 77,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0F766E)
                        .withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: const Color(0xFF0F766E).withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppConstants.edit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          //       begin: Alignment.centerLeft,
          //       end: Alignment.centerRight,
          //     ),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: TextButton.icon(
          //     onPressed: () => Get.toNamed(Routes.addProductWizard,arguments: product),
          //     style: TextButton.styleFrom(
          //       backgroundColor: Colors.transparent,
          //       shadowColor: Colors.transparent,
          //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          //       minimumSize: Size.zero,
          //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //     ),
          //     icon: const Icon(
          //       Icons.edit,
          //       color: Colors.white,
          //       size: 20,
          //     ),
          //     label: Text(
          //       AppConstants.edit,
          //       style: GoogleFonts.plusJakartaSans(
          //         fontWeight: FontWeight.w700,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Product Overview Card ---
            _buildSectionCard(
              theme,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: theme.isDark
                                  ? const Color(0xFF131D2E)
                                  : const Color(0xFFE2E8F0),
                              highlightColor: theme.isDark
                                  ? const Color(0xFF1E2D44)
                                  : const Color(0xFFF8FAFC),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.surfaceMuted,
                              alignment: Alignment.center,
                              child: const Text(
                                '📦',
                                style: TextStyle(fontSize: 48),
                              ),
                            ),
                          )
                              : Container(
                            color: theme.surfaceMuted,
                            child: const Center(
                              child: Text(
                                '📦',
                                style: TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppConstants.statusActive,
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
                            _buildSmallBadge(product.categoryName ?? AppConstants.defaultCat, theme),
                            const SizedBox(width: 8),
                            const CustomStatusChip(textTitle: AppConstants.statusInStock, type: StatusType.success),
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
                        // Text(
                        //   AppConstants.defaultTitle,
                        //   style: GoogleFonts.plusJakartaSans(
                        //     fontSize: 13,
                        //     color: theme.textSecondary,
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                        // Row(
                        //   children: [
                        //     Icon(Icons.qr_code_2, size: 16, color: theme.textSecondary),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       product.barcode ?? AppConstants.defaultBarCode,
                        //       style: GoogleFonts.plusJakartaSans(
                        //         fontSize: 13,
                        //         fontWeight: FontWeight.w600,
                        //         color: theme.textPrimary,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 4),
                        //     IconButton(
                        //       onPressed: () async {
                        //         final barcodeToCopy = product.barcode ?? AppConstants.defaultBarCode;
                        //         await Clipboard.setData(ClipboardData(text: barcodeToCopy));
                        //
                        //         if (context.mounted) {
                        //           ScaffoldMessenger.of(context).showSnackBar(
                        //             const SnackBar(
                        //               content: Text(AppConstants.barcodeCopied),
                        //               duration: Duration(seconds: 2),
                        //             ),
                        //           );
                        //         }
                        //       },
                        //       icon: Icon(Icons.copy_rounded, size: 14, color: theme.textSecondary),
                        //     ),
                        //   ],
                        // ),
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
              title: AppConstants.priceMargin,
              subtitle: 'Unit: ${product.unit}',
              icon: Icons.account_balance_wallet_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceBox(
                          AppConstants.retailPrice,
                          'Rs. ${product.salePrice.toInt()}',
                          'per ${AppConstants.unit}',
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPriceBox(
                          AppConstants.wholeSaleP,
                          'Rs. ${product.purchasePrice.toInt()}',
                          AppConstants.costBasis,
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
                                  AppConstants.calPerPiece,
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
              title: AppConstants.invHealth,
              icon: Icons.inventory_2_outlined,
              headerAction: const CustomStatusChip(textTitle: AppConstants.healthyStock, type: StatusType.success),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.currAvailability,
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                        AppConstants.dangerZone,
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
                    AppConstants.dangerZineSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.5,
                      color: const Color(0xFFBE123C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: AppConstants.delProduct,
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
      CustomConfirmDialog(
        title: '${AppConstants.delProduct}?',
        subtitle: 'Are you sure you want to delete ${product.article}? This action cannot be undone.',
        confirmText: 'Logout',
        onConfirm: () async {
          Get.back();
          await controller.deleteProduct(product);
          Get.back(); // Return to All Products list
        },
      ),
      // AlertDialog(
      //   title: const Text('${AppConstants.delProduct}?'),
      //   content: Text('Are you sure you want to delete ${product.article}? This action cannot be undone.'),
      //   actions: [
      //     TextButton(
      //       onPressed: () => Get.back(),
      //       child: const Text(AppConstants.cancelTitle),
      //     ),
      //     TextButton(
      //       onPressed: () async {
      //         Get.back();
      //         await controller.deleteProduct(product);
      //         Get.back(); // Return to All Products list
      //       },
      //       style: TextButton.styleFrom(foregroundColor: Colors.red),
      //       child: const Text(AppConstants.delTitle),
      //     ),
      //   ],
      // ),
    );
  }
}
