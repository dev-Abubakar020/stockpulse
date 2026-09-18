import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/utils/app_colors.dart';

// ─── Mock Data ────────────────────────────────────────────────────────────────

const _expenseCategories = [
  'Rent',
  'Electricity',
  'Gas / Fuel',
  'Staff Salaries',
  'Maintenance & Repairs',
  'Marketing & Advertising',
  'Transport & Logistics',
  'Packaging & Supplies',
  'Internet & Phone',
  'Bank Charges',
  'Insurance',
  'Miscellaneous',
];

const _paymentMethods = [
  'Cash',
  'Bank Transfer',
  'Jazzcash',
  'Easypaisa',
  'Card',
  'Cheque',
];
const _statuses = ['Paid', 'Unpaid', 'Partial'];
const _recurrenceOptions = ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

class _ExpenseCategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  const _ExpenseCategoryInfo(this.name, this.icon, this.color);
}

const _categoryMeta = <_ExpenseCategoryInfo>[
  _ExpenseCategoryInfo('Rent', Icons.home_rounded, Color(0xFF7C3AED)),
  _ExpenseCategoryInfo('Electricity', Icons.bolt_rounded, Color(0xFFD97706)),
  _ExpenseCategoryInfo(
    'Gas / Fuel',
    Icons.local_gas_station_rounded,
    Color(0xFFDC2626),
  ),
  _ExpenseCategoryInfo(
    'Staff Salaries',
    Icons.group_rounded,
    Color(0xFF2563EB),
  ),
  _ExpenseCategoryInfo(
    'Maintenance & Repairs',
    Icons.build_rounded,
    Color(0xFF059669),
  ),
  _ExpenseCategoryInfo(
    'Marketing & Advertising',
    Icons.campaign_rounded,
    Color(0xFFDB2777),
  ),
  _ExpenseCategoryInfo(
    'Transport & Logistics',
    Icons.local_shipping_rounded,
    Color(0xFF0891B2),
  ),
  _ExpenseCategoryInfo(
    'Packaging & Supplies',
    Icons.inventory_2_rounded,
    Color(0xFF65A30D),
  ),
  _ExpenseCategoryInfo(
    'Internet & Phone',
    Icons.wifi_rounded,
    Color(0xFF6366F1),
  ),
  _ExpenseCategoryInfo(
    'Bank Charges',
    Icons.account_balance_rounded,
    Color(0xFF475569),
  ),
  _ExpenseCategoryInfo('Insurance', Icons.shield_rounded, Color(0xFF0F766E)),
  _ExpenseCategoryInfo(
    'Miscellaneous',
    Icons.more_horiz_rounded,
    Color(0xFF78716C),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddExpenses extends StatefulWidget {
  const AddExpenses({super.key});

  @override
  State<AddExpenses> createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  // Controllers
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(
    text:
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
  );
  final _dueDateCtrl = TextEditingController();
  final _refNoCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _receiptCtrl = TextEditingController();
  final _taxCtrl = TextEditingController(text: '0');

  // State
  String _selectedCategory = 'Rent';
  String _selectedPayment = 'Cash';
  String _selectedStatus = 'Paid';
  String _selectedRecurrence = 'None';
  bool _isBillable = false;
  bool _isSaving = false;

  double get _amount =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  double get _tax => (_amount * (double.tryParse(_taxCtrl.text) ?? 0)) / 100;
  double get _total => _amount + _tax;

  _ExpenseCategoryInfo get _currentCategoryMeta => _categoryMeta.firstWhere(
    (m) => m.name == _selectedCategory,
    orElse: () => _categoryMeta.last,
  );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _dueDateCtrl.dispose();
    _refNoCtrl.dispose();
    _notesCtrl.dispose();
    _vendorCtrl.dispose();
    _receiptCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isDark = context.isDark;
    final meta = _currentCategoryMeta;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomAppBar(
                title: 'Add Expense',
                showBackButton: true,
                actions: [
                  CustomTextButton(
                    text: 'Reset',
                    color: AppColors.expense,
                    onPressed: () => setState(() {
                      _titleCtrl.clear();
                      _amountCtrl.clear();
                      _notesCtrl.clear();
                      _vendorCtrl.clear();
                      _refNoCtrl.clear();
                      _receiptCtrl.clear();
                      _taxCtrl.text = '0';
                      _selectedStatus = 'Paid';
                      _selectedRecurrence = 'None';
                      _isBillable = false;
                    }),
                  ),
                ],
              ),
            ),

            // ── Category Quick Selector ──────────────────────────────
            _CategoryQuickSelector(
              categories: _categoryMeta,
              selected: _selectedCategory,
              onChanged: (c) => setState(() => _selectedCategory = c),
            ),

            // ── Scrollable Content ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Expense Amount Hero Card
                    _AmountHeroCard(
                      meta: meta,
                      amount: _amount,
                      tax: _tax,
                      total: _total,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    // Section 1: Basic Info
                    _SectionCard(
                      icon: Icons.edit_rounded,
                      iconColor: AppColors.expense,
                      title: 'Expense Details',
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _titleCtrl,
                            hintText: 'e.g., Monthly Shop Rent',
                            labelText: 'Expense Title *',
                            prefixIcon: const Icon(
                              Icons.label_rounded,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _amountCtrl,
                                  hintText: '0',
                                  labelText: 'Amount (Rs.) *',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.currency_rupee_rounded,
                                    size: 18,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _taxCtrl,
                                  hintText: '0',
                                  labelText: 'Tax (%)',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.percent_rounded,
                                    size: 18,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _DropdownField(
                            label: 'Category',
                            icon: meta.icon,
                            iconColor: meta.color,
                            value: _selectedCategory,
                            items: _expenseCategories,
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 2: Date & Schedule
                    _SectionCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Date & Schedule',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _dateCtrl,
                                  hintText: 'DD/MM/YYYY',
                                  labelText: 'Expense Date *',
                                  prefixIcon: const Icon(
                                    Icons.today_rounded,
                                    size: 18,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (d != null)
                                      _dateCtrl.text =
                                          '${d.day}/${d.month}/${d.year}';
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _dueDateCtrl,
                                  hintText: 'DD/MM/YYYY',
                                  labelText: 'Due Date (Optional)',
                                  prefixIcon: const Icon(
                                    Icons.event_rounded,
                                    size: 18,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (d != null)
                                      _dueDateCtrl.text =
                                          '${d.day}/${d.month}/${d.year}';
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _DropdownField(
                            label: 'Recurrence',
                            icon: Icons.repeat_rounded,
                            value: _selectedRecurrence,
                            items: _recurrenceOptions,
                            onChanged: (v) =>
                                setState(() => _selectedRecurrence = v!),
                          ),
                          if (_selectedRecurrence != 'None') ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.06,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This expense will auto-repeat $_selectedRecurrence. You can disable it later.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.primary,
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
                    const SizedBox(height: 14),

                    // Section 3: Vendor / Payee
                    _SectionCard(
                      icon: Icons.business_rounded,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Vendor / Payee',
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _vendorCtrl,
                            hintText: 'e.g., LESCO, SNGPL, Landlord Name',
                            labelText: 'Vendor / Payee Name',
                            prefixIcon: const Icon(
                              Icons.store_rounded,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _receiptCtrl,
                            hintText: 'e.g., Bill No. or Invoice No.',
                            labelText: 'Receipt / Invoice No.',
                            prefixIcon: const Icon(
                              Icons.receipt_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 4: Payment
                    _SectionCard(
                      icon: Icons.payments_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Payment',
                      child: Column(
                        children: [
                          _DropdownField(
                            label: 'Payment Method',
                            icon: Icons.account_balance_wallet_rounded,
                            value: _selectedPayment,
                            items: _paymentMethods,
                            onChanged: (v) =>
                                setState(() => _selectedPayment = v!),
                          ),
                          const SizedBox(height: 14),
                          _DropdownField(
                            label: 'Payment Status',
                            icon: Icons.fiber_manual_record,
                            iconColor: _selectedStatus == 'Paid'
                                ? Colors.green
                                : _selectedStatus == 'Unpaid'
                                ? Colors.red
                                : Colors.orange,
                            value: _selectedStatus,
                            items: _statuses,
                            onChanged: (v) =>
                                setState(() => _selectedStatus = v!),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _refNoCtrl,
                            hintText: 'e.g., Cheque No. or Transaction ID',
                            labelText: 'Reference No. (Optional)',
                            prefixIcon: const Icon(
                              Icons.numbers_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 5: Options
                    _SectionCard(
                      icon: Icons.tune_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Options',
                      child: Column(
                        children: [
                          _ToggleRow(
                            icon: Icons.attach_money_rounded,
                            iconColor: const Color(0xFF059669),
                            title: 'Billable to Client',
                            subtitle: 'This expense can be charged back to a customer.',
                            value: _isBillable,
                            onChanged: (v) => setState(() => _isBillable = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 6: Notes
                    _SectionCard(
                      icon: Icons.notes_rounded,
                      iconColor: const Color(0xFF64748B),
                      title: 'Notes',
                      child: CustomTextField(
                        controller: _notesCtrl,
                        hintText: 'Describe the expense, attach any context…',
                        labelText: 'Notes (Optional)',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        prefixIcon: const Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Save Bar ──────────────────────────────────────
            _BottomSaveBar(
              amountLabel: 'Rs. ${_total.toStringAsFixed(0)}',
              status: _selectedStatus,
              buttonText: 'Save Expense',
              isLoading: _isSaving,
              onSave: () async {
                if (_titleCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
                  Get.snackbar(
                    'Required Fields',
                    'Please fill in title and amount.',
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade800,
                  );
                  return;
                }
                setState(() => _isSaving = true);
                await Future.delayed(const Duration(seconds: 1));
                setState(() => _isSaving = false);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Expense recorded!',
                  backgroundColor: Colors.green.shade50,
                  colorText: Colors.green.shade800,
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Quick Selector ──────────────────────────────────────────────────

class _CategoryQuickSelector extends StatelessWidget {
  final List<_ExpenseCategoryInfo> categories;
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryQuickSelector({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = cat.name == selected;
          return GestureDetector(
            onTap: () => onChanged(cat.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color
                    : cat.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? null
                    : Border.all(color: cat.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat.icon,
                    color: isSelected ? Colors.white : cat.color,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.name.split(' ')[0],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Amount Hero Card ─────────────────────────────────────────────────────────

class _AmountHeroCard extends StatelessWidget {
  final _ExpenseCategoryInfo meta;
  final double amount, tax, total;
  final bool isDark;

  const _AmountHeroCard({
    required this.meta,
    required this.amount,
    required this.tax,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [meta.color, meta.color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: meta.color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(meta.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.name,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${total.toStringAsFixed(0)}',
                  style: GoogleFonts.sora(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (tax > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Base',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Rs. ${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tax',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '+ Rs. ${tax.toStringAsFixed(0)}',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Toggle Row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF059669),
            activeColor: Colors.white,
            thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF059669),
                );
              }
              return null;
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Helper Widgets ────────────────────────────────────────────────────

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
                    color: iconColor.withValues(alpha: 0.1),
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
                if (trailing != null) trailing!,
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

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? const Color(0xFF111A2E) : const Color(0xFFF1F5F9);
    final border = isDark ? const Color(0xFF202E44) : const Color(0xFFE2E8F0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
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
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF131D2E) : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF0F172A),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 17,
                            color: iconColor ?? AppColors.expense,
                          ),
                          const SizedBox(width: 8),
                          Text(e),
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

class _BottomSaveBar extends StatelessWidget {
  final String amountLabel, buttonText, status;
  final bool isLoading;
  final VoidCallback onSave;

  const _BottomSaveBar({
    required this.amountLabel,
    required this.buttonText,
    required this.isLoading,
    required this.onSave,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final statusColor = status == 'Paid'
        ? Colors.green
        : status == 'Unpaid'
        ? Colors.red
        : Colors.orange;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                amountLabel,
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: buttonText,
              isLoading: isLoading,
              onPressed: onSave,
              height: 48,
              backgroundColor: AppColors.expense,
              gradient: null,
            ),
          ),
        ],
      ),
    );
  }
}
