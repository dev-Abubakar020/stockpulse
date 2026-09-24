import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/controllers/expense_controller.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/appbar.dart';

class AddExpenses extends GetView<ExpenseController> {
  const AddExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isDark = context.isDark;

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: const Text(AppConstants.addExpenses),
        showBackArrow: true,
        actions: [
          CustomTextButton(
            text: AppConstants.reset,
            color: AppColors.expense,
            onPressed: controller.resetForm,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Category & Amount Section ─────────────────────────────
                  _SectionCard(
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.expense,
                    title: AppConstants.expenseDetails,
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        // Category Dropdown
                        Obx(() {
                          final currentMeta = controller.currentCategoryMeta;
                          return _CategoryDropdownField(
                            selectedCategory: controller.selectedCategory.value,
                            items: ExpenseController.categoryMeta,
                            currentMeta: currentMeta,
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedCategory.value = val;
                              }
                            },
                          );
                        }),

                        const SizedBox(height: 16),

                        // Amount Field
                        _buildFieldLabel(AppConstants.expenseAmountLabel, theme, isRequired: true),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: controller.amountController,
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Obx(
                            () => Center(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Text(
                                controller.currencySymbol.value,
                                style: GoogleFonts.sora(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Date & Description Section ───────────────────────────
                  _SectionCard(
                    icon: Icons.calendar_today_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    title: AppConstants.dateNotes,
                    child: Column(
                      children: [
                        // Expense Date Picker
                        Obx(() {
                          final date = controller.selectedDate.value;
                          final dateStr =
                              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

                          return CustomTextField(
                            controller: TextEditingController(text: dateStr),
                            hintText: AppConstants.dateFormat,
                            labelText: AppConstants.expenseDateLabel,
                            prefixIcon: const Icon(
                              Icons.today_rounded,
                              size: 18,
                            ),
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: controller.selectedDate.value,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                controller.selectedDate.value = picked;
                              }
                            },
                          );
                        }),

                        const SizedBox(height: 16),

                        // Notes / Description Field
                        CustomTextField(
                          controller: controller.descriptionController,
                          hintText: AppConstants.descExpense,
                          labelText: AppConstants.expenseNotesLabel,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Save Bar ───────────────────────────────────────────────
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D2E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Obx(
                () => AppButton(
                  text: AppConstants.saveExpenseBtn,
                  isLoading: controller.isSaving.value,
                  onPressed: () async {
                   await controller.addExpense();
                  },
                  height: 50,
                  backgroundColor: AppColors.expense,
                  gradient: null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card Wrapper ───────────────────────────────────────────────────

Widget _buildFieldLabel(
  String text,
  AppThemeHelper theme, {
  bool isRequired = false,
}) {
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        if (isRequired)
          TextSpan(
            text: ' *',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
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
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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

// ─── Category Dropdown Field (Displays Icons for UI) ─────────────────────────

class _CategoryDropdownField extends StatelessWidget {
  final String selectedCategory;
  final List<ExpenseCategoryInfo> items;
  final ExpenseCategoryInfo currentMeta;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdownField({
    required this.selectedCategory,
    required this.items,
    required this.currentMeta,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? const Color(0xFF111A2E) : const Color(0xFFF1F5F9);
    final border = isDark ? const Color(0xFF202E44) : const Color(0xFFE2E8F0);
    final theme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppConstants.expenseCategoryLabel, theme, isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF131D2E) : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              ),
              items: items
                  .map(
                    (info) => DropdownMenuItem<String>(
                      value: info.name,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: info.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              info.icon,
                              size: 16,
                              color: info.color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(info.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
