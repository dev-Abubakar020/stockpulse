import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custome_appbar.dart';
import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../models/productItemModel.dart';



class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  int selectedFilterIndex = 0;

  final List<ProductItemModel> products = const [
    ProductItemModel(
      name: 'Coca Cola 1.5L',
      category: 'Beverages',
      price: 180,
      quantity: 24,
      iconEmoji: '🥤',
    ),
    ProductItemModel(
      name: 'Surf Excel 1kg',
      category: 'Grocery',
      price: 520,
      quantity: 2,
      iconEmoji: '🧼',
      stockStatus: 'Low Stock',
    ),
    ProductItemModel(
      name: 'Lays Masala',
      category: 'Snacks',
      price: 80,
      quantity: 45,
      iconEmoji: '🥔',
    ),
    ProductItemModel(
      name: 'Dalda Cooking Oil 1L',
      category: 'Grocery',
      price: 450,
      quantity: 12,
      iconEmoji: '🌻',
    ),
    ProductItemModel(
      name: 'Nestle Milk Pack',
      category: 'Dairy',
      price: 220,
      quantity: 0,
      iconEmoji: '🥛',
      stockStatus: 'Restock needed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomeAppBar(
                    title: 'All Products',
                    actions: [
                      TextButton.icon(
                        onPressed: () => Get.toNamed('/addProductWizard'),
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: Text(
                          'Add',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomSearchField(
                    hintText: 'Search product, barcode...',
                    showScanner: true,
                  ),
                  const SizedBox(height: 14),
                  CustomFilterTabs(
                    items: const [
                      'All',
                      'Low Stock',
                      'Out of Stock',
                    ],
                    selectedIndex: selectedFilterIndex,
                    onChanged: (index) {
                      setState(() {
                        selectedFilterIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                      final product = products[index];

                      Color cardBorderColor = theme.border;
                      Color qtyBgColor = const Color(0xFFF1F5F9);
                      Color qtyTextColor = const Color(0xFF475569);
                      Color imgBgColor = const Color(0xFFF8FAFC);

                      if (product.stockStatus == 'Low Stock') {
                        cardBorderColor = const Color(0xFFFDE68A);
                        qtyBgColor = const Color(0xFFFEF3C7);
                        qtyTextColor = const Color(0xFFD97706);
                        imgBgColor = const Color(0xFFFFFBEB);
                      } else if (product.stockStatus == 'Restock needed' || product.quantity == 0) {
                        cardBorderColor = const Color(0xFFFECACA); // Soft Red
                        qtyBgColor = const Color(0xFFFEE2E2);
                        qtyTextColor = const Color(0xFFDC2626);
                        imgBgColor = const Color(0xFFFFF5F5);
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cardBorderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image Container box
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: imgBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                product.iconEmoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details central column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.category,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: theme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Rs. ',
                                          style: GoogleFonts.sora(
                                            fontSize: 13,
                                            color: theme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${product.price.toInt()}',
                                          style: GoogleFonts.sora(
                                            fontSize: 15,
                                            color: theme.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' /unit',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: theme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status / actions column right side
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: qtyBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${product.quantity} pcs',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: qtyTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (product.stockStatus != null) ...[
                                  Text(
                                    product.stockStatus!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: qtyTextColor,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: theme.textSecondary,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
