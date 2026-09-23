import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/appbar.dart';
import 'package:stockpulse/common/widgets/custom_statuschip.dart';
import 'package:stockpulse/controllers/purchase_controller.dart';
import 'package:stockpulse/models/purchasemodel.dart';

class PurchaseDetailView extends StatefulWidget {
  const PurchaseDetailView({super.key});

  @override
  State<PurchaseDetailView> createState() => _PurchaseDetailViewState();
}

class _PurchaseDetailViewState extends State<PurchaseDetailView> {
  late final PurchaseModel purchase;
  final PurchaseController controller = Get.find<PurchaseController>();

  @override
  void initState() {
    super.initState();
    purchase = Get.arguments as PurchaseModel;
    controller.fetchPurchaseItems(purchase.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    StatusType statusType = StatusType.neutral;
    if (purchase.status.toLowerCase() == 'completed') {
      statusType = StatusType.success;
    } else if (purchase.status.toLowerCase() == 'void' ||
        purchase.status.toLowerCase() == 'cancelled') {
      statusType = StatusType.error;
    }

    final dateStr =
        "${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year} ${_formatTime(purchase.purchaseDate)}";

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: const Text('Purchase Details'),
        showBackArrow: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                          purchase.purchaseNo,
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        CustomStatusChip(
                          textTitle: purchase.status.capitalizeFirst ??
                              purchase.status,
                          type: statusType,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: theme.border),
                    const SizedBox(height: 12),
                    _buildInfoRow('Date & Time', dateStr, theme),
                    const SizedBox(height: 8),
                    _buildInfoRow('Created By', purchase.createdBy, theme),
                    if (purchase.notes != null &&
                        purchase.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Notes', purchase.notes!, theme),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Items Section ---
              Text(
                'Purchased Items',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isPurchaseItemsLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final items = controller.currentPurchaseItems;
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
                      'No items found for this purchase.',
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
                                  'Qty: ${_formatQty(item.quantity)} ${item.unit} × Rs. ${item.purchasePrice.toInt()}',
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
                      'Rs. ${purchase.subtotal.toInt()}',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Discount',
                      '- Rs. ${purchase.discount.toInt()}',
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
                          'Rs. ${purchase.totalAmount.toInt()}',
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
