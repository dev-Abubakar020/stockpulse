import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSale extends StatefulWidget {
  const AddSale({super.key});

  @override
  State<AddSale> createState() => _AddSaleState();
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _Product {
  final String id;
  final String name;
  final double price;
  final String imageType; // For placeholder icon/color
  final Color badgeColor;

  const _Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageType,
    required this.badgeColor,
  });
}

class _CartItem {
  final _Product product;
  int quantity;

  _CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class _AddSaleState extends State<AddSale> {
  // Current step: 0 = Select Products, 1 = Review Cart, 2 = Payment, 3 = Success
  int _currentStep = 0;

  // Colors matching the design
  static const Color primaryGreen = Color(0xFF0D5E3A);
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color surfaceColor = Color(0xFFF9FAFB);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  // Mock Products list matching the image
  final List<_Product> _products = const [
    _Product(
      id: '1',
      name: 'Coca Cola 1.5L',
      price: 180,
      imageType: 'drink',
      badgeColor: Color(0xFFEF4444),
    ),
    _Product(
      id: '2',
      name: 'Surf Excel 1kg',
      price: 520,
      imageType: 'detergent',
      badgeColor: Color(0xFF2563EB),
    ),
    _Product(
      id: '3',
      name: 'Lays Masala',
      price: 80,
      imageType: 'snack',
      badgeColor: Color(0xFFF59E0B),
    ),
    _Product(
      id: '4',
      name: 'Dalda Cooking Oil 1L',
      price: 450,
      imageType: 'oil',
      badgeColor: Color(0xFF10B981),
    ),
    _Product(
      id: '5',
      name: 'Nestle Milk Pack',
      price: 220,
      imageType: 'dairy',
      badgeColor: Color(0xFF0284C7),
    ),
    _Product(
      id: '6',
      name: 'Tapal Danedar Tea 450g',
      price: 650,
      imageType: 'tea',
      badgeColor: Color(0xFFB45309),
    ),
    _Product(
      id: '7',
      name: 'National Salt 800g',
      price: 60,
      imageType: 'grocery',
      badgeColor: Color(0xFF64748B),
    ),
  ];

  // Cart state: Pre-populate with initial items from mockup
  final Map<String, int> _cart = {
    '1': 2, // Coca Cola: 2
    '2': 1, // Surf Excel: 1
  };

  // Customers mock list
  final List<String> _customers = [
    'Walk-in Customer',
    'Ali Ahmed',
    'Sara Khan',
    'Muhammad Usman',
    'Bilal Raza',
  ];
  String _selectedCustomer = 'Walk-in Customer';

  // Note Controller
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _receivedAmountController = TextEditingController();

  String _searchQuery = '';
  String _selectedPaymentMethod = 'Cash';
  bool _printInvoice = true;
  bool _shareWhatsApp = false;

  // Computed properties
  int get _totalItemsCount => _cart.values.fold(0, (sum, count) => sum + count);

  double get _subtotal {
    double total = 0;
    _cart.forEach((productId, qty) {
      final p = _products.firstWhere((item) => item.id == productId);
      total += p.price * qty;
    });
    return total;
  }

  double get _discount => 0.0;
  double get _grandTotal => _subtotal - _discount;

  double get _receivedAmount {
    if (_receivedAmountController.text.isEmpty) return _grandTotal;
    return double.tryParse(_receivedAmountController.text) ?? _grandTotal;
  }

  double get _changeAmount {
    final diff = _receivedAmount - _grandTotal;
    return diff > 0 ? diff : 0.0;
  }

  @override
  void initState() {
    super.initState();
    _receivedAmountController.text = _grandTotal.toInt().toString();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    _receivedAmountController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
      _receivedAmountController.text = _grandTotal.toInt().toString();
    });
  }

  void _decrementCart(String productId) {
    setState(() {
      if ((_cart[productId] ?? 0) > 1) {
        _cart[productId] = _cart[productId]! - 1;
      } else {
        _cart.remove(productId);
      }
      _receivedAmountController.text = _grandTotal.toInt().toString();
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      _cart.remove(productId);
      _receivedAmountController.text = _grandTotal.toInt().toString();
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _receivedAmountController.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Step Content
              Expanded(
                child: _buildCurrentStepContent(),
              ),

              // Bottom Bar (if not on success screen)
              if (_currentStep != 3) _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    if (_currentStep == 3) {
      // Success screen top bar
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textDark),
            onPressed: _handleBack,
          ),
          Text(
            'New Sale',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          if (_currentStep == 0)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 22, color: primaryGreen),
              onPressed: () {
                Get.snackbar('Barcode Scanner', 'Ready to scan barcode',
                    backgroundColor: Colors.white, colorText: primaryGreen);
              },
            )
          else
            const SizedBox(width: 48), // Balancing spacer
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectProducts();
      case 1:
        return _buildStep2ReviewCart();
      case 2:
        return _buildStep3Payment();
      case 3:
        return _buildStep4Success();
      default:
        return const SizedBox();
    }
  }

  // ─── Step 1: Select / Add Products ──────────────────────────────────────────
  Widget _buildStep1SelectProducts() {
    final filtered = _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search product, barcode...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: textMuted,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Products List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 16, color: borderColor),
            itemBuilder: (context, index) {
              final product = filtered[index];
              final qty = _cart[product.id] ?? 0;
              final isInCart = qty > 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Product Thumbnail Badge
                    _buildProductIcon(product),
                    const SizedBox(width: 14),

                    // Title & Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${product.price.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action: Stepper or Plus Button
                    if (isInCart)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _decrementCart(product.id),
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Icon(Icons.remove, size: 16, color: textDark),
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _addToCart(product.id),
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Icon(Icons.add, size: 16, color: textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${(product.price * qty).toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: () => _addToCart(product.id),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Review Cart & Customer ─────────────────────────────────────────
  Widget _buildStep2ReviewCart() {
    final cartItems = _cart.entries.map((entry) {
      final p = _products.firstWhere((prod) => prod.id == entry.key);
      return _CartItem(product: p, quantity: entry.value);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Section
          Text(
            'Customer',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showCustomerPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: lightGreenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCustomer,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Cart Items Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cart Items',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              GestureDetector(
                onTap: _clearCart,
                child: Text(
                  'Clear All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cart Items List
          if (cartItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'Your cart is empty',
                style: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 14),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const Divider(height: 18, color: borderColor),
              itemBuilder: (context, i) {
                final item = cartItems[i];
                return Row(
                  children: [
                    _buildProductIcon(item.product),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Rs. ${item.product.price.toInt()} x ${item.quantity}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${item.subtotal.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _removeFromCart(item.product.id),
                      child: const Icon(Icons.delete_outline_rounded, color: textMuted, size: 20),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 22),

          // Add Note
          Text(
            'Add Note (Optional)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Write a note...',
                hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Pricing Summary
          _buildSummaryLine('Subtotal', 'Rs. ${_subtotal.toInt()}'),
          const SizedBox(height: 8),
          _buildSummaryLine('Discount', 'Rs. ${_discount.toInt()}'),
          const Divider(height: 24, color: borderColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Text(
                'Rs. ${_grandTotal.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Step 3: Payment & Complete ─────────────────────────────────────────────
  Widget _buildStep3Payment() {
    final paymentMethods = [
      {'id': 'Cash', 'icon': Icons.payments_outlined},
      {'id': 'Card', 'icon': Icons.credit_card_rounded},
      {'id': 'JazzCash', 'icon': Icons.phone_android_rounded},
      {'id': 'Bank Transfer', 'icon': Icons.account_balance_rounded},
      {'id': 'Other', 'icon': Icons.more_horiz_rounded},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Amount Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${_grandTotal.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Payment Methods
          Text(
            'Select Payment Method',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: paymentMethods.map((pm) {
              final isSelected = _selectedPaymentMethod == pm['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = pm['id'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? primaryGreen : borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pm['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : textDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pm['id'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // Received Amount
          Text(
            'Received Amount',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _receivedAmountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Change
          Text(
            'Change',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${_changeAmount.toInt()}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 24),

          // Invoice Options
          Text(
            'Invoice Options',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildInvoiceOptionRow(
            icon: Icons.print_outlined,
            title: 'Print Invoice',
            value: _printInvoice,
            onChanged: (val) => setState(() => _printInvoice = val),
          ),
          const SizedBox(height: 10),
          _buildInvoiceOptionRow(
            icon: Icons.chat_outlined,
            title: 'Share via WhatsApp',
            value: _shareWhatsApp,
            onChanged: (val) => setState(() => _shareWhatsApp = val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Step 4: Success View ───────────────────────────────────────────────────
  Widget _buildStep4Success() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Green Checkmark Circle
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Sale Completed\nSuccessfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 24),

            // Summary Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Invoice No.', 'INV-${DateTime.now().millisecondsSinceEpoch % 10000}'),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Customer', _selectedCustomer),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Payment Method', _selectedPaymentMethod),
                  const Divider(height: 20, color: borderColor),
                  _buildReceiptRow('Total Amount', 'Rs. ${_grandTotal.toInt()}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'View Sale',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _cart.clear();
                    _currentStep = 0;
                    _noteController.clear();
                    _receivedAmountController.text = '0';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Add Another Sale',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Action Bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    if (_currentStep == 0) {
      if (_cart.isEmpty) return const SizedBox();

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: textDark, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$_totalItemsCount items',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs. ${_grandTotal.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Cart',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentStep == 1) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _cart.isEmpty
                ? null
                : () => setState(() {
                      _receivedAmountController.text = _grandTotal.toInt().toString();
                      _currentStep = 2;
                    }),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Proceed to Payment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else if (_currentStep == 2) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _currentStep = 3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Complete Sale',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  // ─── Helper UI Components ───────────────────────────────────────────────────

  Widget _buildProductIcon(_Product product) {
    IconData icon;
    switch (product.imageType) {
      case 'drink':
        icon = Icons.local_drink_rounded;
        break;
      case 'detergent':
        icon = Icons.cleaning_services_rounded;
        break;
      case 'snack':
        icon = Icons.fastfood_rounded;
        break;
      case 'oil':
        icon = Icons.water_drop_rounded;
        break;
      case 'dairy':
        icon = Icons.icecream_rounded;
        break;
      case 'tea':
        icon = Icons.coffee_rounded;
        break;
      default:
        icon = Icons.inventory_2_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: product.badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: product.badgeColor, size: 22),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceOptionRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryGreen,
            activeTrackColor: lightGreenBg,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? textDark : textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: textDark,
          ),
        ),
      ],
    );
  }

  void _showCustomerPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Customer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              ..._customers.map((c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.person_outline_rounded,
                      color: c == _selectedCustomer ? primaryGreen : textMuted,
                    ),
                    title: Text(
                      c,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: c == _selectedCustomer ? FontWeight.w700 : FontWeight.w500,
                        color: c == _selectedCustomer ? primaryGreen : textDark,
                      ),
                    ),
                    trailing: c == _selectedCustomer
                        ? const Icon(Icons.check_circle_rounded, color: primaryGreen)
                        : null,
                    onTap: () {
                      setState(() => _selectedCustomer = c);
                      Navigator.of(context).pop();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}