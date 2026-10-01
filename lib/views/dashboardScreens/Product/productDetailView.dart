import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/services/role_service.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../../common/route/app_routes.dart';
import '../../../common/widgets/alertDialog.dart';
import '../../../common/widgets/appbar.dart';
import '../../../controllers/allProductsController.dart';
import '../../../models/productItemModel.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

class ProductDetailView extends GetView<ProductController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final ProductItemModel product = Get.arguments;
    final roleService = Get.isRegistered<RoleService>()
        ? Get.find<RoleService>()
        : Get.put(RoleService(), permanent: true);

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
          if (roleService.canManageProducts)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.addProductWizard, arguments: product),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 77,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.20),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Pricing Section ---
            _buildSectionCard(
              theme,
              title: AppConstants.priceMargin,
              subtitle: '${AppConstants.unitLabel}: ${product.unit}',
              icon: Icons.account_balance_wallet_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceBox(
                          AppConstants.retailPrice,
                          '${AppConstants.defaultCurrency}${product.salePrice.toInt()}',
                          'per ${AppConstants.unit}',
                          theme,
                        ),
                      ),
                      if (roleService.canViewPurchasePrice) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPriceBox(
                            AppConstants.wholeSaleP,
                            '${AppConstants.defaultCurrency}${product.purchasePrice.toInt()}',
                            AppConstants.costBasis,
                            theme,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (roleService.canViewPurchasePrice) ...[
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
                                    '+${AppConstants.defaultCurrency}${profit.toInt()} ${AppConstants.netProfit}',
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
                              '${margin.toStringAsFixed(1)}${AppConstants.marginSuffix}',
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
                                    text: AppConstants.pcsUnit,
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
                              '${(stockProgress * 100).toInt()}${AppConstants.ofCapacity}',
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

            const SizedBox(height: 16),
            _buildSectionCard(
              theme,
              title: AppConstants.barCode,
              icon: CupertinoIcons.barcode,

              headerAction: product.barcode?.trim().isNotEmpty == true
                  ? const CustomStatusChip(
                textTitle: AppConstants.barCodeSubCheck,
                type: StatusType.success,
              )
                  : null,

              child: product.barcode?.trim().isNotEmpty == true
                  ? _BarcodePreview(
                barcodeValue: product.barcode!,
                theme: theme,
              )
                  : Center(
                child: Text(
                  AppConstants.noBarCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ),
            // _buildSectionCard(
            //   theme,
            //   title: AppConstants.barCode,
            //   icon: CupertinoIcons.barcode,
            //   headerAction: product.barcode?.trim().isNotEmpty == true
            //       ? const CustomStatusChip(
            //     textTitle: AppConstants.barCodeSubCheck,
            //     type: StatusType.success,
            //   )
            //       : null,
            //   child: product.barcode?.trim().isNotEmpty == true
            //       ? _buildBarcode(
            //     product.barcode,
            //     theme,
            //   )
            //       : Center(
            //         child: Text(AppConstants.noBarCode,
            //           style: GoogleFonts.plusJakartaSans(
            //         fontSize: 13,
            //         color: theme.textSecondary,
            //                         ),
            //                       ),
            //       ),
            // ),

            const SizedBox(height: 20),

            if (roleService.canManageProducts) ...[
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
        subtitle: AppConstants.deleteProductConfirmMsg(product.article),
        confirmText: AppConstants.btnDelete,
        onConfirm: () async {
          Get.back();
          await controller.deleteProduct(product);
          Get.back();
        },
      ),
    );
  }
}


class _BarcodePreview extends StatefulWidget {
  final String barcodeValue;
  final AppThemeHelper theme;

  const _BarcodePreview({
    required this.barcodeValue,
    required this.theme,
  });

  @override
  State<_BarcodePreview> createState() => _BarcodePreviewState();
}

class _BarcodePreviewState extends State<_BarcodePreview> {
  final GlobalKey _barcodeKey = GlobalKey();

  Future<void> _saveBarcodeImage() async {
    try {
      final boundary = _barcodeKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(
        pixelRatio: 3.0,
      );

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;

      final Uint8List pngBytes =
      byteData.buffer.asUint8List();

      await Gal.putImageBytes(
        pngBytes,
        name: 'StockPulse_${widget.barcodeValue}',
      );

      Get.snackbar(
        'Saved',
        'Barcode saved to gallery',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Barcode save error: $e');

      Get.snackbar(
        'Error',
        'Unable to save barcode',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.barcodeValue.trim();

    final barcode = Barcode.code128();

    final svg = barcode.toSvg(
      value,
      width: 280,
      height: 90,
      drawText: false,
    );

    return Column(
      children: [
        // ONLY this area will be saved
        RepaintBoundary(
          key: _barcodeKey,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.string(
                  svg,
                  width: 280,
                  height: 90,
                ),

                const SizedBox(height: 10),

                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _saveBarcodeImage,
            icon: const Icon(
              Icons.download_rounded,
              size: 19,
            ),
            label: Text(
              AppConstants.barCodeSubCheck,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}