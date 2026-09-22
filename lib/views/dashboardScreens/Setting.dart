import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/common/widgets/custom_header.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/theme/theme_helper.dart';
import '../../common/widgets/custom_MenuTile.dart';
import '../../controllers/loginController.dart';

class SettingPage extends StatelessWidget {
   SettingPage({super.key});
   final controller = Get.find<LoginController>();
  final Uri _url = Uri.parse('https://flutter.dev');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomAppBar(title: AppConstants.settingTitle,showBackButton: true,),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [

                    CustomHeading(title: AppConstants.aboutTitle),
                    const SizedBox(height: 10),
                    _buildCardGroup([
                      MoreMenuTile(
                        icon: Icons.store_outlined,
                        title: AppConstants.shoppTitle,
                        onTap: () {},
                      ),
                      MoreMenuTile(
                        icon: Icons.notifications_none_rounded,
                        title: AppConstants.notificationTitle,
                        onTap: () {
                          Get.snackbar(AppConstants.notificationSnackTitle, "Coming Soon",snackPosition:SnackPosition.BOTTOM ,
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xE61E293B),
                            colorText: Colors.white,
                          );
                        },
                      ),
                      // MoreMenuTile(
                      //   icon: Icons.palette_outlined,
                      //   title: 'Appearance',
                      //   onTap: () {
                      //     ThemeController.to.toggleTheme();
                      //   },
                      // ),
                    ]),

                    const SizedBox(height: 20),

                    // Section 3: Support
                    CustomHeading(title: AppConstants.supportTitle),
                    const SizedBox(height: 10),
                    _buildCardGroup([
                      MoreMenuTile(
                        icon: Icons.help_outline_rounded,
                        title: AppConstants.securityTitle,
                        onTap: () {
                          _launchUrl();
                        },
                      ),
                      MoreMenuTile(
                        icon: Icons.logout,
                        title: AppConstants.logout,
                        color: Colors.red,
                        showDivider: false,
                        onTap: controller.logout,
                      ),
                    ]),

                    const SizedBox(height: 24),
                    Center(child: Text('${AppConstants.appName}   v ${AppConstants.appVersion}'))
                  ],
                ),
              ),
            ],
          ),
        )
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

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}