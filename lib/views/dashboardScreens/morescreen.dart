import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/custom_MenuTile.dart';

class MoreScreen extends StatelessWidget {
  MoreScreen({super.key});
  final Uri _url = Uri.parse('https://flutter.dev');
  final Uri _url2 = Uri.parse('https://flutter.dev');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left:24),
              child: CustomAppBar(title: 'More'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  CustomAppBar(title: AppConstants.businessTitle),
                  const SizedBox(height: 10),
                  _buildCardGroup([
                    MoreMenuTile(
                      icon: Icons.category_outlined,
                      title: 'Categories',
                      onTap: () {
                        Get.toNamed(Routes.allCategories);
                      },
                    ),
                    MoreMenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Expenses',
                      onTap: () {
                        Get.toNamed(Routes.addExpense);
                      },
                    ),
                    MoreMenuTile(
                      icon: Icons.bar_chart_outlined,
                      title: 'Reports',
                      onTap: () {},
                    ),
                    MoreMenuTile(
                      icon: Icons.badge_outlined,
                      title: 'Staff',
                      showDivider: false,
                      onTap: () {
                        Get.snackbar(
                          'Feature Unavailable',
                          'This feature is coming Soon',
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 2
                  CustomAppBar(title: 'Others Options'),
                  const SizedBox(height: 10),
                  _buildCardGroup([
                    MoreMenuTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      showDivider: false,
                      onTap: () {
                        Get.toNamed(Routes.settingPage);
                      },
                    ),
                    MoreMenuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {
                        _launchUrl();
                      },
                    ),
                    MoreMenuTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About StockPulse',
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
