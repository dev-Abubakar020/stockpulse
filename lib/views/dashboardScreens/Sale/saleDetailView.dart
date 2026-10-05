import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/appbar.dart';
import 'package:stockpulse/common/widgets/custom_status_chip.dart';
import 'package:stockpulse/controllers/sale_controller.dart';
import 'package:stockpulse/models/sale_model.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../../services/initialpdfview.dart';
import '../../../services/sale_pdf_service.dart';
import '../../receipts/thermal_sale_receipt.dart';

class SaleDetailView extends GetView<SaleController> {
  SaleDetailView({super.key}) {
    final SaleModel sale = Get.arguments as SaleModel;
    controller.fetchSaleItems(sale.id);
    controller.fetchCreatorName(sale.id, createdByUserId: sale.createdBy);
  }

  @override
  Widget build(BuildContext context) {
    final SaleModel sale = Get.arguments as SaleModel;
    final theme = context.appTheme;

    StatusType statusType = StatusType.neutral;
    if (sale.status.toLowerCase() == 'completed') {
      statusType = StatusType.success;
    } else if (sale.status.toLowerCase() == 'void' ||
        sale.status.toLowerCase() == 'cancelled') {
      statusType = StatusType.error;
    }

    final dateStr =
        "${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year} ${_formatTime(sale.saleDate)}";

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: Text(AppConstants.saleDetailsTitle),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Overview Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sale.saleNo,
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      CustomStatusChip(
                        textTitle: sale.status.capitalizeFirst ?? sale.status,
                        type: statusType,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: theme.border),
                  const SizedBox(height: 12),
                  _buildInfoRow(AppConstants.dateTime, dateStr, theme),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    AppConstants.paymentMethodLabel,
                    sale.paymentMethod.toUpperCase(),
                    theme,
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => _buildInfoRow(
                      AppConstants.createdByLabel,
                      controller.creatorName.value,
                      theme,
                    ),
                  ),
                  if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(AppConstants.notesLabel, sale.notes!, theme),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Items Section ---
            Text(
              AppConstants.soldItemsHeader,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isSaleItemsLoading.value) {
                return _buildDetailItemsShimmer(theme);
              }

              final items = controller.currentSaleItems;
              if (items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Text(
                    AppConstants.noItemsSale,
                    style: GoogleFonts.plusJakartaSans(
                      color: theme.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, i) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.article,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                              ),
                              if ((item.color != null &&
                                      item.color!.isNotEmpty) ||
                                  (item.size != null &&
                                      item.size!.isNotEmpty)) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${item.color ?? ''} ${item.size != null ? '• Size: ${item.size}' : ''}'
                                      .trim(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${_formatQty(item.quantity)} ${item.unit} × Rs. ${item.salePrice.toInt()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs. ${item.lineTotal.toInt()}',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 12),
            // --- Totals Summary Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    AppConstants.subtotal,
                    '${AppConstants.defaultCurrency}${sale.subtotal.toInt()}',
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    AppConstants.discountLabel,
                    '- ${AppConstants.defaultCurrency}${sale.discount.toInt()}',
                    theme,
                    isDiscount: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppConstants.totalAmountLabel,
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        '${AppConstants.defaultCurrency}${sale.totalAmount.toInt()}',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, AppThemeHelper theme) {
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
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    AppThemeHelper theme, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: theme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.red : theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemsShimmer(AppThemeHelper theme) {
    final baseColor = theme.isDark
        ? const Color(0xFF131D2E)
        : Colors.grey.shade300;
    final highlightColor = theme.isDark
        ? const Color(0xFF1E2D44)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour12 = local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }
}
