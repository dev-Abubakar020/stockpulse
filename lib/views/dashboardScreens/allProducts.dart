import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../common/widgets/CustomSearchField.dart';
import '../../common/widgets/Custom_filter.dart';
import '../../common/widgets/alertDialog.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/emptyfilter.dart';
import '../../common/widgets/product_shimmer.dart';
import '../../controllers/allProductsController.dart';
import '../../controllers/loginController.dart';



class AllProducts extends GetView<ProductController>  {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: Text(AppConstants.productTitle),
        actions: [
          IconButton(onPressed: (){
            Get.dialog(
              CustomConfirmDialog(
                title: AppConstants.logout,
                subtitle: AppConstants.logoutAlertSubTitle,
                confirmText: AppConstants.logout,
                onConfirm: () {
                  Get.back();
                  Get.find<LoginController>().logout();
                },
              ),
            );
          }, icon: Icon(Icons.logout,color: Colors.red,))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        AppConstants.all,
                        AppConstants.lowStockTitle,
                        AppConstants.statusOutOfStock,
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
                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 6),
                    child: EmptyStateWidget(
                      isSearching: isSearching,
                      title: isSearching ? AppConstants.queryNotFoundTitle : AppConstants.noProductsFoundTitle,
                      subtitle: isSearching
                          ? AppConstants.noProductsFoundSubtitle
                          : AppConstants.noProductsYetSubtitle,
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: product.imageUrl?.isNotEmpty == true
                                    ? CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                  fadeInDuration: const Duration(milliseconds: 300),

                                  placeholder: (_, __) => Shimmer.fromColors(
                                    baseColor: theme.isDark
                                        ? const Color(0xFF131D2E)
                                        : const Color(0xFFE2E8F0),
                                    highlightColor: theme.isDark
                                        ? const Color(0xFF1E2D44)
                                        : const Color(0xFFF8FAFC),
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),

                                  errorWidget: (_, __, ___) => Container(
                                    color: imgBgColor,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '📦',
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ),
                                )
                                    : Container(
                                  color: imgBgColor,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '📦',
                                    style: TextStyle(fontSize: 28),
                                  ),
                                ),
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
                                    product.categoryName ?? AppConstants.uncatProduct,
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
                                  product.stockStatus ?? AppConstants.statusInStock,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: qtyTextColor,
                                  ),
                                ),
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

      /// Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 12,right: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F766E),
              Color(0xFF14B8A6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.addProductWizard),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add),
          label: const Text(
            AppConstants.addPurchase,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


