import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/controllers/category_controller.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/custome_textbutton.dart';

class AddCategories extends StatelessWidget {
  const AddCategories({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the injected CategoryController
    final CategoryController controller = Get.find<CategoryController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(AppConstants.addCat),
        showBackArrow: true,
        actions: [
          CustomTextButton(
            text: AppConstants.reset,
            onPressed: () {
              controller.clearForm();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCardGroup([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Header Row (Title + Required Indicator)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: AppConstants.categoryName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: AppConstants.requiredAsterisk,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    AppConstants.required,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // 2. Light Grey Input Field
                              TextFormField(
                                controller: controller.nameController,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F9),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none, // Removes standard underline border
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: Color(0xFF475569),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppConstants.categoryNameHint,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF475569),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Obx(() {
                        final isActive = controller.isCategoryActive.value;
                        return _buildCardGroup([
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Title, Subtitle & Custom Toggle Switch
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          AppConstants.categoryStatus,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        RichText(
                                          text: const TextSpan(
                                            text: AppConstants.databaseKeyPrefix,
                                            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                                            children: [
                                              TextSpan(
                                                text: AppConstants.databaseKey,
                                                style: TextStyle(
                                                  fontFamily: AppConstants.fontMonospace,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F766E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Custom Green Check Switch
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Switch(
                                        value: isActive,
                                        onChanged: (val) {
                                          controller.isCategoryActive.value = val;
                                        },
                                        //  ignore: deprecated_member_use
                                        activeColor: Colors.white,
                                        activeTrackColor: const Color(0xFF064E3B), // Dark green background
                                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return const Icon(Icons.check, color: Color(0xFF064E3B), size: 16);
                                          }
                                          return null;
                                        }),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // 2. Status Information Banner (Changes state dynamically)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Status Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isActive ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isActive ? Icons.check_circle_outline : Icons.highlight_off,
                                              size: 16,
                                              color: isActive ? const Color(0xFF14532D) : const Color(0xFF475569),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isActive ? AppConstants.statusActive : AppConstants.statusInActive,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isActive ? const Color(0xFF14532D) : const Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Banner Dynamic Text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isActive ? AppConstants.visibleChannels : AppConstants.hiddenChannels,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 3. Bottom Question-Mark Hint
                                const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.help_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AppConstants.categoryStatusHint,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            await controller.saveCategory();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      AppConstants.saveCategory,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
