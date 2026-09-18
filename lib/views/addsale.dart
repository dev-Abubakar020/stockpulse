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

final _mockCustomers = [
  'Walk-in Customer',
  'Ahmad Raza',
  'Sara Khan',
  'Muhammad Ali',
  'Fatima Malik',
  'Bilal Hussain',
];

final _mockProducts = [
  _SaleProduct(
    name: 'Basmati Rice 5kg',
    sku: 'BRS-005',
    price: 1250,
    stock: 48,
    unit: 'Bag',
  ),
  _SaleProduct(
    name: 'Cooking Oil 1L',
    sku: 'COL-001',
    price: 380,
    stock: 120,
    unit: 'Bottle',
  ),
  _SaleProduct(
    name: 'Sugar 1kg',
    sku: 'SGR-001',
    price: 130,
    stock: 200,
    unit: 'Kg',
  ),
  _SaleProduct(
    name: 'Flour 10kg',
    sku: 'FLR-010',
    price: 800,
    stock: 75,
    unit: 'Bag',
  ),
];

final _paymentMethods = ['Cash', 'Bank Transfer', 'Jazzcash', 'Easypaisa', 'Card'];
final _saleStatuses = ['Completed', 'Pending', 'Processing'];

// ─── Model ────────────────────────────────────────────────────────────────────

class _SaleProduct {
  final String name, sku, unit;
  final double price;
  final int stock;
  const _SaleProduct({
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.unit,
  });
}

class _CartItem {
  final _SaleProduct product;
  int qty;
  double discount;
  _CartItem({required this.product, this.qty = 1, this.discount = 0});
  double get subtotal => (product.price * qty) - discount;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddSale extends StatefulWidget {
  const AddSale({super.key});

  @override
  State<AddSale> createState() => _AddSaleState();
}

class _AddSaleState extends State<AddSale> {
  // Controllers
  final _invoiceCtrl = TextEditingController(text: 'INV-${DateTime.now().millisecondsSinceEpoch % 10000}');
  final _dateCtrl = TextEditingController(
    text: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
  );
  final _notesCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  final _taxCtrl = TextEditingController(text: '0');
  final _shippingCtrl = TextEditingController(text: '0');

  // State
  String _selectedCustomer = 'Walk-in Customer';
  String _selectedPayment = 'Cash';
  String _selectedStatus = 'Completed';
  final List<_CartItem> _cart = [];
  bool _isSaving = false;

  // Computed
  double get _subtotal => _cart.fold(0, (s, i) => s + i.subtotal);
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0;
  double get _tax => (_subtotal * (double.tryParse(_taxCtrl.text) ?? 0)) / 100;
  double get _shipping => double.tryParse(_shippingCtrl.text) ?? 0;
  double get _total => _subtotal - _discount + _tax + _shipping;

  @override
  void dispose() {
    _invoiceCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    _discountCtrl.dispose();
    _taxCtrl.dispose();
    _shippingCtrl.dispose();
    super.dispose();
  }

  void _addProduct(_SaleProduct p) {
    final existing = _cart.where((c) => c.product.sku == p.sku);
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.qty++;
      } else {
        _cart.add(_CartItem(product: p));
      }
    });
  }

  void _removeItem(int index) => setState(() => _cart.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomAppBar(
                title: 'New Sale',
                showBackButton: true,
                actions: [
                  CustomTextButton(
                    text: 'Reset',
                    onPressed: () => setState(() {
                      _cart.clear();
                      _discountCtrl.text = '0';
                      _taxCtrl.text = '0';
                      _shippingCtrl.text = '0';
                      _notesCtrl.clear();
                    }),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Section 1: Invoice Info
                    _SectionCard(
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.primary,
                      title: 'Invoice Details',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _invoiceCtrl,
                                  hintText: 'INV-0001',
                                  labelText: 'Invoice No.',
                                  prefixIcon: const Icon(Icons.tag, size: 18),
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _dateCtrl,
                                  hintText: 'DD/MM/YYYY',
                                  labelText: 'Sale Date',
                                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                                  readOnly: true,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      _dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _DropdownField(
                            label: 'Status',
                            icon: Icons.circle_rounded,
                            iconColor: _selectedStatus == 'Completed'
                                ? Colors.green
                                : _selectedStatus == 'Pending'
                                    ? Colors.orange
                                    : AppColors.primary,
                            value: _selectedStatus,
                            items: _saleStatuses,
                            onChanged: (v) => setState(() => _selectedStatus = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 2: Customer
                    _SectionCard(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Customer',
                      child: _DropdownField(
                        label: 'Select Customer',
                        icon: Icons.person_outline_rounded,
                        value: _selectedCustomer,
                        items: _mockCustomers,
                        onChanged: (v) => setState(() => _selectedCustomer = v!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 3: Products
                    _SectionCard(
                      icon: Icons.inventory_2_rounded,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Items',
                      trailing: GestureDetector(
                        onTap: () => _showProductPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Add',
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: _cart.isEmpty
                          ? _EmptyCart()
                          : Column(
                              children: [
                                ...List.generate(_cart.length, (i) => _CartItemTile(
                                  item: _cart[i],
                                  isDark: isDark,
                                  onRemove: () => _removeItem(i),
                                  onQtyChanged: (q) => setState(() => _cart[i].qty = q),
                                  onDiscountChanged: (d) => setState(() => _cart[i].discount = d),
                                  index: i,
                                )),
                              ],
                            ),
                    ),
                    const SizedBox(height: 14),

                    // Section 4: Pricing
                    _SectionCard(
                      icon: Icons.calculate_rounded,
                      iconColor: const Color(0xFF059669),
                      title: 'Pricing Summary',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _discountCtrl,
                                  hintText: '0',
                                  labelText: 'Discount (Rs.)',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Icons.local_offer_rounded, size: 18),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                                  prefixIcon: const Icon(Icons.percent_rounded, size: 18),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _shippingCtrl,
                            hintText: '0',
                            labelText: 'Shipping Charges (Rs.)',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.local_shipping_rounded, size: 18),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          _OrderSummaryRow(label: 'Subtotal', value: 'Rs. ${_subtotal.toStringAsFixed(0)}'),
                          _OrderSummaryRow(label: 'Discount', value: '- Rs. ${_discount.toStringAsFixed(0)}', valueColor: Colors.red),
                          _OrderSummaryRow(label: 'Tax', value: '+ Rs. ${_tax.toStringAsFixed(0)}'),
                          _OrderSummaryRow(label: 'Shipping', value: '+ Rs. ${_shipping.toStringAsFixed(0)}'),
                          const Divider(height: 20),
                          _OrderSummaryRow(
                            label: 'Grand Total',
                            value: 'Rs. ${_total.toStringAsFixed(0)}',
                            isBold: true,
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 5: Payment
                    _SectionCard(
                      icon: Icons.payments_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Payment',
                      child: _DropdownField(
                        label: 'Payment Method',
                        icon: Icons.account_balance_wallet_rounded,
                        value: _selectedPayment,
                        items: _paymentMethods,
                        onChanged: (v) => setState(() => _selectedPayment = v!),
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
                        hintText: 'Add remarks, special instructions…',
                        labelText: 'Notes (Optional)',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        prefixIcon: const Icon(Icons.edit_note_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Save Bar ──────────────────────────────────────
            _BottomSaveBar(
              label: 'Total: Rs. ${_total.toStringAsFixed(0)}',
              buttonText: 'Save Sale',
              isLoading: _isSaving,
              onSave: () async {
                setState(() => _isSaving = true);
                await Future.delayed(const Duration(seconds: 1));
                setState(() => _isSaving = false);
                Get.back();
                Get.snackbar('Success', 'Sale saved successfully!',
                    backgroundColor: Colors.green.shade50,
                    colorText: Colors.green.shade800,
                    icon: const Icon(Icons.check_circle, color: Colors.green));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProductPickerSheet(
        products: _mockProducts,
        onSelected: _addProduct,
      ),
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final _CartItem item;
  final bool isDark;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChanged;
  final ValueChanged<double> onDiscountChanged;

  const _CartItemTile({
    required this.item,
    required this.isDark,
    required this.index,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111A2E) : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'SKU: ${item.product.sku} · Rs. ${item.product.price.toStringAsFixed(0)}/${item.product.unit}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFDC2626)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QtyControl(
                  qty: item.qty,
                  onChanged: onQtyChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item Disc. (Rs.)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    _InlineNumberField(
                      value: item.discount,
                      onChanged: onDiscountChanged,
                      hint: '0',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Subtotal', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${item.subtotal.toStringAsFixed(0)}',
                    style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;

  const _QtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quantity', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            _QtyBtn(icon: Icons.remove, onTap: qty > 1 ? () => onChanged(qty - 1) : null),
            const SizedBox(width: 8),
            Text('$qty', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            _QtyBtn(icon: Icons.add, onTap: () => onChanged(qty + 1)),
          ],
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: onTap != null ? AppColors.primary : Colors.grey),
      ),
    );
  }
}

class _InlineNumberField extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String hint;
  const _InlineNumberField({required this.value, required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value == 0 ? '' : value.toStringAsFixed(0),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'No items added yet',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "+ Add" to add products to this sale',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  final List<_SaleProduct> products;
  final ValueChanged<_SaleProduct> onSelected;

  const _ProductPickerSheet({required this.products, required this.onSelected});

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _query = '';

  List<_SaleProduct> get _filtered =>
      widget.products.where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Select Product', style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Search products…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = _filtered[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 20),
                  ),
                  title: Text(p.name, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Rs. ${p.price.toStringAsFixed(0)} · Stock: ${p.stock} ${p.unit}s',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  onTap: () {
                    widget.onSelected(p);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
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
        border: Border.all(color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0)),
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
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              ),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Icon(icon, size: 17, color: iconColor ?? AppColors.primary),
                            const SizedBox(width: 8),
                            Text(e),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _OrderSummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? null : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSaveBar extends StatelessWidget {
  final String label;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onSave;

  const _BottomSaveBar({
    required this.label,
    required this.buttonText,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D2E) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Grand Total', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                label.replaceFirst('Total: ', ''),
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
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
            ),
          ),
        ],
      ),
    );
  }
}