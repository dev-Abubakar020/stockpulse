import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/CustomSearchField.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/controllers/category_controller.dart';
import 'package:stockpulse/models/category_model.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../../common/widgets/Custom_filter.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/product_shimmer.dart';

class AllCategories extends StatelessWidget {
  const AllCategories({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the injected CategoryController
    final CategoryController controller = Get.find<CategoryController>();

    return CustomScreen(
      appBar: const CustomAppBar(title: Text(AppConstants.allCat), showBackArrow: true),
      body: Column(
        mainAxisAlignment: .start,
        children: [
          CustomSearchField(
            hintText: AppConstants.searchCat,
            showScanner: false,
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
          ),
          const SizedBox(height: 12),
          Obx(
            () => CustomFilterTabs(
              items: const [AppConstants.all, AppConstants.statusActive, AppConstants.statusInActive],
              selectedIndex: controller.selectedFilterIndex.value,
              onChanged: controller.changeFilter,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.only(top:12),
                  child: const ProductListShimmer(),
                );
              }

              final categories = controller.filteredCategories;

              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    AppConstants.noCatFound,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchCategories(),
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category,
                      onStatusChanged: (isActive) {
                        controller.changeCategoryStatus(category, isActive);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      /// Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(Routes.addCategories);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text(
        AppConstants.addCat,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final ValueChanged<bool> onStatusChanged;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Rounded Icon Container with fixed category icon as per user instruction
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: category.isActive ? const Color(0xFFE8F8F0) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '🏷️',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text and Status Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Active / Inactive Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? const Color(0xFFA3EAC0)
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.isActive ? AppConstants.statusActive : AppConstants.statusInActive ,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: category.isActive
                                ? const Color(0xFF0F5B36)
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Linked items: ${Get.find<CategoryController>().categoryCounts[category.id] ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Three Dots Popup Menu
            PopupMenuButton<bool>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: onStatusChanged,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                PopupMenuItem<bool>(
                  value: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: category.isActive ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(AppConstants.markActive),
                    ],
                  ),
                ),
                PopupMenuItem<bool>(
                  value: false,
                  child: Row(
                    children: [
                      Icon(
                        Icons.highlight_off,
                        color: !category.isActive ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(AppConstants.markInActive),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
