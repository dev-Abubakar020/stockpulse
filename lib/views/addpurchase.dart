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

final _mockSuppliers = [
  'Select Supplier',
  'Al-Kareem Traders',
  'National Foods Ltd.',
  'Packages Limited',
  'Rafhan Maize Products',
  'Murree Brewery Co.',
  'Punjab Beverages',
];

final _mockPurchaseProducts = [
  _PurchaseProduct(
    name: 'Basmati Rice 50kg',
    sku: 'BRS-050',
    cost: 4800,
    unit: 'Bag',
    category: 'Grains',
  ),
  _PurchaseProduct(
    name: 'Cooking Oil 16L',
    sku: 'COL-016',
    cost: 5200,
    unit: 'Can',
    category: 'Oils',
  ),
  _PurchaseProduct(
    name: 'Sugar 50kg',
    sku: 'SGR-050',
    cost: 6800,
    unit: 'Bag',
    category: 'Grocery',
  ),
  _PurchaseProduct(
    name: 'Wheat Flour 50kg',
    sku: 'WFL-050',
    cost: 3900,
    unit: 'Bag',
    category: 'Grains',
  ),
  _PurchaseProduct(
    name: 'Salt 25kg',
    sku: 'SLT-025',
    cost: 950,
    unit: 'Bag',
    category: 'Spices',
  ),
];

final _purchasePaymentMethods = [
  'Cash',
  'Bank Transfer',
  'Cheque',
  'Credit',
  'Online',
];
final _purchaseStatuses = ['Received', 'Ordered', 'Partial', 'Cancelled'];
final _warehouses = [
  'Main Store',
  'Warehouse A',
  'Warehouse B',
  'Cold Storage',
];

// ─── Model ────────────────────────────────────────────────────────────────────

class _PurchaseProduct {
  final String name, sku, unit, category;
  final double cost;
  const _PurchaseProduct({
    required this.name,
    required this.sku,
    required this.cost,
    required this.unit,
    required this.category,
  });
}

class _PurchaseItem {
  final _PurchaseProduct product;
  int qty;
  double costOverride;
  double bonus;
  _PurchaseItem({required this.product, this.qty = 1, this.bonus = 0})
    : costOverride = product.cost;
  double get lineTotal => costOverride * qty;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddPurchase extends StatefulWidget {
  const AddPurchase({super.key});

  @override
  State<AddPurchase> createState() => _AddPurchaseState();
}

class _AddPurchaseState extends State<AddPurchase> {
  // Controllers
  final _poCtrl = TextEditingController(
    text: 'PO-${DateTime.now().millisecondsSinceEpoch % 10000}',
  );
  final _invoiceCtrl = TextEditingController();
  final _orderDateCtrl = TextEditingController(
    text:
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
  );
  final _receiveDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  final _taxCtrl = TextEditingController(text: '0');
  final _shippingCtrl = TextEditingController(text: '0');
  final _refNoCtrl = TextEditingController();

  // State
  String _selectedSupplier = 'Select Supplier';
  String _selectedPayment = 'Cash';
  String _selectedStatus = 'Received';
  String _selectedWarehouse = 'Main Store';
  final List<_PurchaseItem> _items = [];
  bool _isSaving = false;

  // Computed
  double get _subtotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0;
  double get _tax => (_subtotal * (double.tryParse(_taxCtrl.text) ?? 0)) / 100;
  double get _shipping => double.tryParse(_shippingCtrl.text) ?? 0;
  double get _grandTotal => _subtotal - _discount + _tax + _shipping;

  @override
  void dispose() {
    _poCtrl.dispose();
    _invoiceCtrl.dispose();
    _orderDateCtrl.dispose();
    _receiveDateCtrl.dispose();
    _notesCtrl.dispose();
    _discountCtrl.dispose();
    _taxCtrl.dispose();
    _shippingCtrl.dispose();
    _refNoCtrl.dispose();
    super.dispose();
  }

  void _addProduct(_PurchaseProduct p) {
    final existing = _items.where((i) => i.product.sku == p.sku);
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.qty++;
      } else {
        _items.add(_PurchaseItem(product: p));
      }
    });
  }

  void _removeItem(int i) => setState(() => _items.removeAt(i));

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
                title: 'New Purchase',
                showBackButton: true,
                actions: [
                  CustomTextButton(
                    text: 'Reset',
                    onPressed: () => setState(() {
                      _items.clear();
                      _discountCtrl.text = '0';
                      _taxCtrl.text = '0';
                      _shippingCtrl.text = '0';
                      _notesCtrl.clear();
                      _invoiceCtrl.clear();
                      _refNoCtrl.clear();
                    }),
                  ),
                ],
              ),
            ),

            // ── Status Banner ────────────────────────────────────────
            _StatusBanner(status: _selectedStatus),

            // ── Scrollable Content ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Section 1: Purchase Order Info
                    _SectionCard(
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Purchase Order Details',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _poCtrl,
                                  hintText: 'PO-0001',
                                  labelText: 'PO Number',
                                  prefixIcon: const Icon(Icons.tag, size: 18),
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _invoiceCtrl,
                                  hintText: 'Supplier invoice #',
                                  labelText: 'Supplier Invoice No.',
                                  prefixIcon: const Icon(
                                    Icons.receipt_rounded,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _orderDateCtrl,
                                  hintText: 'DD/MM/YYYY',
                                  labelText: 'Order Date',
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_rounded,
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
                                      _orderDateCtrl.text =
                                          '${d.day}/${d.month}/${d.year}';
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _receiveDateCtrl,
                                  hintText: 'DD/MM/YYYY',
                                  labelText: 'Receive Date',
                                  prefixIcon: const Icon(
                                    Icons.calendar_month_rounded,
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
                                      _receiveDateCtrl.text =
                                          '${d.day}/${d.month}/${d.year}';
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _DropdownField(
                            label: 'Status',
                            icon: Icons.fiber_manual_record,
                            iconColor: _statusColor(_selectedStatus),
                            value: _selectedStatus,
                            items: _purchaseStatuses,
                            onChanged: (v) =>
                                setState(() => _selectedStatus = v!),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _refNoCtrl,
                            hintText: 'e.g. Cheque No. or Transfer ID',
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

                    // Section 2: Supplier
                    _SectionCard(
                      icon: Icons.store_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Supplier',
                      child: _DropdownField(
                        label: 'Select Supplier',
                        icon: Icons.store_mall_directory_rounded,
                        value: _selectedSupplier,
                        items: _mockSuppliers,
                        onChanged: (v) =>
                            setState(() => _selectedSupplier = v!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 3: Warehouse
                    _SectionCard(
                      icon: Icons.warehouse_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Receiving Location',
                      child: _DropdownField(
                        label: 'Deliver To',
                        icon: Icons.place_rounded,
                        value: _selectedWarehouse,
                        items: _warehouses,
                        onChanged: (v) =>
                            setState(() => _selectedWarehouse = v!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 4: Products
                    _SectionCard(
                      icon: Icons.inventory_2_rounded,
                      iconColor: AppColors.primary,
                      title: 'Purchase Items',
                      trailing: GestureDetector(
                        onTap: () => _showProductPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
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
                      child: _items.isEmpty
                          ? _EmptyItems(
                              label: 'No items added yet',
                              hint: 'Tap "+ Add" to add products to purchase',
                            )
                          : Column(
                              children: List.generate(
                                _items.length,
                                (i) => _PurchaseItemTile(
                                  item: _items[i],
                                  isDark: isDark,
                                  index: i,
                                  onRemove: () => _removeItem(i),
                                  onQtyChanged: (q) =>
                                      setState(() => _items[i].qty = q),
                                  onCostChanged: (c) => setState(
                                    () => _items[i].costOverride = c,
                                  ),
                                  onBonusChanged: (b) =>
                                      setState(() => _items[i].bonus = b),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),

                    // Section 5: Pricing
                    _SectionCard(
                      icon: Icons.calculate_rounded,
                      iconColor: const Color(0xFF059669),
                      title: 'Cost Summary',
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
                                  prefixIcon: const Icon(
                                    Icons.local_offer_rounded,
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
                                  labelText: 'GST / Tax (%)',
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
                          CustomTextField(
                            controller: _shippingCtrl,
                            hintText: '0',
                            labelText: 'Freight / Shipping (Rs.)',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(
                              Icons.local_shipping_rounded,
                              size: 18,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          _OrderSummaryRow(
                            label: 'Subtotal',
                            value: 'Rs. ${_subtotal.toStringAsFixed(0)}',
                          ),
                          _OrderSummaryRow(
                            label: 'Discount',
                            value: '- Rs. ${_discount.toStringAsFixed(0)}',
                            valueColor: Colors.red,
                          ),
                          _OrderSummaryRow(
                            label: 'GST/Tax',
                            value: '+ Rs. ${_tax.toStringAsFixed(0)}',
                          ),
                          _OrderSummaryRow(
                            label: 'Freight',
                            value: '+ Rs. ${_shipping.toStringAsFixed(0)}',
                          ),
                          const Divider(height: 20),
                          _OrderSummaryRow(
                            label: 'Grand Total',
                            value: 'Rs. ${_grandTotal.toStringAsFixed(0)}',
                            isBold: true,
                            valueColor: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 6: Payment
                    _SectionCard(
                      icon: Icons.payments_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Payment Info',
                      child: _DropdownField(
                        label: 'Payment Method',
                        icon: Icons.account_balance_wallet_rounded,
                        value: _selectedPayment,
                        items: _purchasePaymentMethods,
                        onChanged: (v) => setState(() => _selectedPayment = v!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 7: Notes
                    _SectionCard(
                      icon: Icons.notes_rounded,
                      iconColor: const Color(0xFF64748B),
                      title: 'Notes & Terms',
                      child: CustomTextField(
                        controller: _notesCtrl,
                        hintText: 'Internal remarks, purchase terms, or delivery notes…',
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
              label: 'Total: Rs. ${_grandTotal.toStringAsFixed(0)}',
              buttonText: 'Save Purchase',
              buttonColor: const Color(0xFF2563EB),
              isLoading: _isSaving,
              onSave: () async {
                setState(() => _isSaving = true);
                await Future.delayed(const Duration(seconds: 1));
                setState(() => _isSaving = false);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Purchase order saved!',
                  backgroundColor: Colors.blue.shade50,
                  colorText: Colors.blue.shade800,
                  icon: const Icon(Icons.check_circle, color: Colors.blue),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Received':
        return Colors.green;
      case 'Ordered':
        return AppColors.primary;
      case 'Partial':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PurchaseProductPickerSheet(
        products: _mockPurchaseProducts,
        onSelected: _addProduct,
      ),
    );
  }
}

// ─── Purchase Item Tile ───────────────────────────────────────────────────────

class _PurchaseItemTile extends StatelessWidget {
  final _PurchaseItem item;
  final bool isDark;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChanged;
  final ValueChanged<double> onCostChanged;
  final ValueChanged<double> onBonusChanged;

  const _PurchaseItemTile({
    required this.item,
    required this.isDark,
    required this.index,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onCostChanged,
    required this.onBonusChanged,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111A2E) : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0),
        ),
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
                  color: blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: blue,
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
                      'SKU: ${item.product.sku} · ${item.product.category}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qty (${item.product.unit}s)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _QtyControl(
                      qty: item.qty,
                      onChanged: onQtyChanged,
                      accentColor: blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit Cost (Rs.)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InlineNumberField(
                      value: item.costOverride,
                      onChanged: onCostChanged,
                      hint: '0',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonus Qty',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InlineNumberField(
                      value: item.bonus,
                      onChanged: onBonusChanged,
                      hint: '0',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Line Total: Rs. ${item.lineTotal.toStringAsFixed(0)}',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseProductPickerSheet extends StatefulWidget {
  final List<_PurchaseProduct> products;
  final ValueChanged<_PurchaseProduct> onSelected;

  const _PurchaseProductPickerSheet({
    required this.products,
    required this.onSelected,
  });

  @override
  State<_PurchaseProductPickerSheet> createState() =>
      _PurchaseProductPickerSheetState();
}

class _PurchaseProductPickerSheetState
    extends State<_PurchaseProductPickerSheet> {
  String _query = '';
  List<_PurchaseProduct> get _filtered => widget.products
      .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Add Product to Purchase',
              style: GoogleFonts.sora(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
                      color: blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: blue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Rs. ${p.cost.toStringAsFixed(0)}/${p.unit} · ${p.category}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.add_circle_rounded, color: blue),
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

// ─── Status Banner ─────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final IconData icon;

    switch (status) {
      case 'Received':
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF14532D);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'Ordered':
        bg = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.shopping_bag_outlined;
        break;
      case 'Partial':
        bg = const Color(0xFFFFF7ED);
        textColor = const Color(0xFF92400E);
        icon = Icons.hourglass_bottom_rounded;
        break;
      case 'Cancelled':
        bg = const Color(0xFFFEF2F2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        icon = Icons.info_outline_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            'Status: $status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
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
                            color: iconColor ?? AppColors.primary,
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

class _OrderSummaryRow extends StatelessWidget {
  final String label, value;
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

class _EmptyItems extends StatelessWidget {
  final String label, hint;
  const _EmptyItems({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.add_shopping_cart_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
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

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  final Color accentColor;

  const _QtyControl({
    required this.qty,
    required this.onChanged,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyBtn(
          icon: Icons.remove,
          onTap: qty > 1 ? () => onChanged(qty - 1) : null,
          accentColor: accentColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$qty',
          style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        _QtyBtn(
          icon: Icons.add,
          onTap: () => onChanged(qty + 1),
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentColor;

  const _QtyBtn({
    required this.icon,
    this.onTap,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? accentColor.withValues(alpha: 0.1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? accentColor : Colors.grey,
        ),
      ),
    );
  }
}

class _InlineNumberField extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String hint;
  const _InlineNumberField({
    required this.value,
    required this.onChanged,
    required this.hint,
  });

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
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}

class _BottomSaveBar extends StatelessWidget {
  final String label, buttonText;
  final bool isLoading;
  final VoidCallback onSave;
  final Color? buttonColor;

  const _BottomSaveBar({
    required this.label,
    required this.buttonText,
    required this.isLoading,
    required this.onSave,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
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
                'Grand Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                label.replaceFirst('Total: ', ''),
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: buttonColor ?? AppColors.primary,
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
              backgroundColor: buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}
