import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/alertDialog.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/custom_MenuTile.dart';
import '../../controllers/loginController.dart';

class MoreScreen extends StatelessWidget {
  MoreScreen({super.key});
  final Uri _url = Uri.parse('https://flutter.dev');
  final Uri _url2 = Uri.parse('https://flutter.dev');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
          title: Text(AppConstants.moreTitle),
        actions: [
          IconButton(
              onPressed: (){
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
              icon: Icon(Icons.logout,color: Colors.red,)
          )
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: _buildInfoGroup(
                 [
                  /// GLOW AVATAR
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F766E),
                          Color(0xFF14B8A6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0F766E).withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child:
                    // Obx(() {
                      // if (controller.isProfileLoading.value) {
                      //   return shimmerCircle();
                      // }

                       CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                          backgroundImage : NetworkImage(AppConstants.defaultUserIcon)
                        // backgroundImage: controller.pic.value.isNotEmpty
                        //     ? NetworkImage(controller.pic.value)
                        //     : const NetworkImage(
                        //   'https://i.pravatar.cc/150?img=3',
                        // ),
                      )

                  ),

                  const SizedBox(width: 20),

                  /// NAME + ROLE
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Obx(() {
                          // if (controller.isProfileLoading.value) {
                          //   return shimmerLine(
                          //     width: 140,
                          //     height: 18,
                          //   );
                          // }

                           Text(
                            'name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),


                        const SizedBox(height: 8),

                        // Obx(() {
                          // if (controller.isProfileLoading.value) {
                          //   return shimmerLine(
                          //     width: 90,
                          //     height: 12,
                          //   );
                          // }

                           Text(
                            'Shop Name :',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade300,
                            ),
                          )
                        // }),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// EDIT PROFILE
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Color(0xFF0F766E).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF0F766E).withValues(alpha: 0.20),
                          ),
                        ),
                        child:  Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Color(0xFF0F766E).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  CustomAppBar(title: Text(AppConstants.businessTitle)),
                  const SizedBox(height: 10),
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

                  const SizedBox(height: 20),

                  // Section 2
                  CustomAppBar(title: Text(AppConstants.othersOptionsTitle)),
                  const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
