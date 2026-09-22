import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/emptyfilter.dart';
import '../../common/widgets/product_shimmer.dart';
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
                  //AppBar
                  CustomAppBar(
                    title: AppConstants.productTitle,
                    actions: [
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.addProductWizard),
                        style: TextButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppConstants.add,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  //Search field
                  CustomSearchField(
                    hintText: AppConstants.searchHint,
                    showScanner: false,
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                  const SizedBox(height: 14),

                  //filters
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
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: const ProductListShimmer(),
                  );
                }

                final products = controller.filteredProducts;

                if (products.isEmpty) {
                  final bool isSearching = controller.searchQuery.value.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8,bottom: 100),
                    child: EmptyStateWidget(
                      isSearching: isSearching,
                      title: isSearching ? 'Query Not found' : 'No products found',
                      subtitle: isSearching
                          ? 'Try changing your search or filter.'
                          : 'Your added products will appear here.',
                    ),
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
                      Color qtyBgColor = AppColors.surfaceMuted;
                      Color qtyTextColor = AppColors.defaultQtyTextColor;
                      Color imgBgColor = AppColors.darkTextPrimary;

                      if (product.stockStatus == 'Low Stock') {
                        cardBorderColor = AppColors.lowStockCardBorderColor;
                        qtyBgColor = AppColors.lowStockQtyBgColor;
                        qtyTextColor = AppColors.warning;
                        imgBgColor = AppColors.lowStockImgBgColor;
                      } else if (product.stockStatus == 'Out of Stock') {
                        cardBorderColor = AppColors.outOfStockCardBorderColor;
                        qtyBgColor = AppColors.outOfStockQtyBgColor;
                        qtyTextColor = AppColors.expense;
                        imgBgColor = AppColors.outOfStockImgBgColor;
                      }
                      return InkWell(
                        onTap: () => Get.toNamed(Routes.productDetail, arguments: product),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
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
                                image: product.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(product.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: product.imageUrl == null
                                  ? const Text(
                                      '📦',
                                      style: TextStyle(fontSize: 28),
                                    )
                                  : null,
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
                                Text(
                                  product.stockStatus ?? 'In Stock',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: qtyTextColor,
                                  ),
                                ),

                                // if (product.stockStatus != null) ...[
                                //   Text(
                                //     product.stockStatus!,
                                //     style: GoogleFonts.plusJakartaSans(
                                //       fontSize: 11,
                                //       fontWeight: FontWeight.w700,
                                //       color: qtyTextColor,
                                //     ),
                                //   ),
                                // ] else ...[
                                //   Icon(
                                //     Icons.more_vert_rounded,
                                //     size: 18,
                                //     color: theme.textSecondary,
                                //   ),
                                // ],
                              ],
                            ),
                          ],
                        ),
                      ));
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


