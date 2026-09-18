import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../controllers/allProductsController.dart';



class AllProducts extends GetView<ProductController>  {
  const AllProducts({super.key});

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
                  CustomAppBar(
                    title: AppConstants.productTitle,
                    actions: [
                      TextButton.icon(
                        onPressed: () => Get.toNamed(Routes.addProductWizard),
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: Text(
                          AppConstants.add,
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
                    hintText: AppConstants.searchHint,
                    showScanner: true,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                        () => CustomFilterTabs(
                      items: const [
                        'All',
                        'Low Stock',
                        'Out of Stock',
                      ],
                      selectedIndex:
                      controller.selectedFilterIndex.value,
                      onChanged: controller.changeFilter,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final products = controller.filteredProducts;

                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchProducts,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      24,
                    ),
                    itemCount: products.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(height: 12),
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
                      } else if (product.stockStatus == 'Restock needed' || product.stockStatus == 0) {
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
                                '📦',
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
                                    product.article,
                                    style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.categoryName ?? "Uncategorized",
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
                                          text: AppConstants.defaultCurrency,
                                          style: GoogleFonts.sora(
                                            fontSize: 13,
                                            color: theme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${product.salePrice.toInt()}',
                                          style: GoogleFonts.sora(
                                            fontSize: 15,
                                            color: theme.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: AppConstants.unit,
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
                                    '${product.currentStock} pcs',
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}


