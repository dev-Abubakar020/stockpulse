import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/appbar.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/controllers/sale_controller.dart';
import 'package:stockpulse/models/sale_model.dart';

class SaleDetailView extends StatefulWidget {
  const SaleDetailView({super.key});

  @override
  State<SaleDetailView> createState() => _SaleDetailViewState();
}

class _SaleDetailViewState extends State<SaleDetailView> {
  late final SaleModel sale;
  final SaleController controller = Get.find<SaleController>();

  @override
  void initState() {
    super.initState();
    sale = Get.arguments as SaleModel;
    controller.fetchSaleItems(sale.id);
    controller.fetchCreatorName(sale.createdBy);
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Sale Details'),
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
                  _buildInfoRow('Date & Time', dateStr, theme),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Payment Method',
                    sale.paymentMethod.toUpperCase(),
                    theme,
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => _buildInfoRow(
                      'Created By',
                      controller.creatorName.value,
                      theme,
                    ),
                  ),
                  if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Notes', sale.notes!, theme),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Items Section ---
            Text(
              'Sold Items',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isSaleItemsLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
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
                    'No items found for this sale.',
                    style: GoogleFonts.plusJakartaSans(
                      color: theme.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
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
            const SizedBox(height: 20),

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
                    'Subtotal',
                    'Rs. ${sale.subtotal.toInt()}',
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Discount',
                    '- Rs. ${sale.discount.toInt()}',
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
                        'Total Amount',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        'Rs. ${sale.totalAmount.toInt()}',
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
