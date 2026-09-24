import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/custom_header.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/alertDialog.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/custom_MenuTile.dart';
import '../../../common/widgets/custom_shimmer.dart';
import '../../../controllers/allProductsController.dart';
import '../../../controllers/loginController.dart';
import '../../../controllers/shopCreateController.dart';

class MoreScreen extends StatelessWidget {
  MoreScreen({super.key});
  final Uri _url = Uri.parse('https://flutter.dev');
  final Uri _url2 = Uri.parse('https://flutter.dev');

  @override
  Widget build(BuildContext context) {
    final ShopCreateController controller = Get.find<ShopCreateController>();

    return CustomScreen(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: Text(AppConstants.moreTitle),
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
          },
            icon: Material(
              color: Colors.transparent,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red
                        .withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.logout,
                  size: 20,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
              ),
            ),),
        ],
      ),
      body: Column(
        children: [
          _buildInfoGroup([
            /// PROFILE IMAGE
            Obx(() {
              if (controller.isProfileLoading.value) {
                return CustomShimmer.circle(size: 64);
              }

              final profileImg =
                  controller.userProfileImageUrl.value.isNotEmpty
                  ? controller.userProfileImageUrl.value
                  : (controller.shopImageUrl.value.isNotEmpty
                        ? controller.shopImageUrl.value
                        : AppConstants.defaultUserIcon);

              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(profileImg),
                ),
              );
            }),

            const SizedBox(width: 16),

            /// OWNER + SHOP
            Expanded(
              child: Obx(() {
                if (controller.isProfileLoading.value) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer.line(width: 140, height: 18),
                      const SizedBox(height: 8),
                      CustomShimmer.line(width: 90, height: 12),
                    ],
                  );
                }

                final displayName = controller.userName.value.isNotEmpty
                    ? controller.userName.value
                    : (controller.ownerController.text.isNotEmpty
                          ? controller.ownerController.text
                          : 'User');

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// OWNER / USER NAME
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    /// SHOP NAME
                    Text(
                      controller.shopController.text.isNotEmpty
                          ? controller.shopController.text
                          : 'Shop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(width: 8),

            /// EDIT
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.toNamed(Routes.editProfile);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0F766E)
                          .withValues(alpha: 0.20),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: const Color(0xFF0F766E).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ]),
          Expanded(
            child: ListView(
              children: [
                CustomHeading(title: AppConstants.businessTitle),

                _buildCardGroup([
                  MoreMenuTile(
                    icon: Icons.info,
                    title: 'Business Info',
                    onTap: () {
                      Get.toNamed(Routes.editBDetails);
                    },
                  ),
                ]),
                const SizedBox(height: 10),
                _buildCardGroup([
                  MoreMenuTile(
                    icon: Icons.category_outlined,
                    title: AppConstants.categoriesTitle,
                    onTap: () {
                      Get.toNamed(Routes.allCategories);
                    },
                  ),
                  MoreMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: AppConstants.expensesTitle,
                    onTap: () {
                      Get.toNamed(Routes.addExpense);
                    },
                  ),
                  MoreMenuTile(
                    icon: Icons.bar_chart_outlined,
                    title: AppConstants.reportsTitle,
                    onTap: () {},
                  ),
                  MoreMenuTile(
                    icon: Icons.badge_outlined,
                    title: AppConstants.staffTitle,
                    showDivider: false,
                    onTap: () {
                      Get.snackbar(
                        AppConstants.featureUnavailableTitle,
                        AppConstants.featureComingSoonMsg,
                      );
                    },
                  ),
                ]),

                // Section 2
                CustomHeading(title: AppConstants.othersOptionsTitle),
                _buildCardGroup([
                  MoreMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: AppConstants.helpAndSupportTitle,
                    onTap: () {
                      _launchUrl();
                    },
                  ),
                  MoreMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: AppConstants.aboutStockPulseTitle,
                    showDivider: false,
                    onTap: () {
                      _launchUrl2();
                    },
                  ),
                ]),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
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
      child: Column(children: children),
    );
  }

  Widget _buildInfoGroup(List<Widget> children) {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchUrl2() async {
    if (!await launchUrl(_url2)) {
      throw Exception('Could not launch $_url2');
    }
  }
}
