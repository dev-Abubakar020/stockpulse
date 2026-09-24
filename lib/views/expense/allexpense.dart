import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/CustomSearchField.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/alertDialog.dart';
import 'package:stockpulse/common/widgets/appbar.dart';
import 'package:stockpulse/common/widgets/product_shimmer.dart';
import 'package:stockpulse/controllers/expense_controller.dart';
import 'package:stockpulse/models/expense_model.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';

class AllExpenses extends GetView<ExpenseController> {
  const AllExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      appBar: const CustomAppBar(
        title: Text(AppConstants.expensesTitle),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          CustomSearchField(
            hintText: 'Search expense...',
            showScanner: false,
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
          ),
          const SizedBox(height: 12),

          // Total Expenses Summary Card
          Obx(() {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.expense.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.expense,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expenses',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${controller.currencySymbol.value} ${controller.totalExpenses.toStringAsFixed(0)}',
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.expenses.length} Records',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.expense,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // Expense List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: ProductListShimmer(),
                );
              }

              final items = controller.filteredExpenses;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No expenses found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchExpenses(),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final expense = items[index];
                    return ExpenseCard(expense: expense);
                  },
                ),
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(Routes.addExpense);
        },
        backgroundColor: AppColors.expense,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppConstants.addExpenses,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseCard({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();
    final meta = ExpenseController.getCategoryMeta(expense.category);
    final date = expense.expenseDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onLongPress: () {
        Get.dialog(
          CustomConfirmDialog(
            title: 'Delete Expense',
            subtitle: 'Are you sure you want to delete this expense?',
            confirmText: 'Delete',
            onConfirm: () {
              Get.back();
              controller.deleteExpense(expense);
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Category Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                meta.icon,
                color: meta.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Category & Date / Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (expense.description != null &&
                      expense.description!.isNotEmpty) ...[
                    Text(
                      expense.description!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    dateStr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Obx(
              () => Text(
                '${controller.currencySymbol.value} ${expense.amount.toStringAsFixed(0)}',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.expense,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
