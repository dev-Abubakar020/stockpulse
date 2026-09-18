import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/custom_appbar.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/custom_MenuTile.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(title: 'More'),
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
                      icon: Icons.people_outline_rounded,
                      title: 'Customers',
                      onTap: () {},
                    ),
                    MoreMenuTile(
                      icon: Icons.group_outlined,
                      title: 'Suppliers',
                      onTap: () {},
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
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 2: App Options
                  CustomAppBar(title: 'App Options'),
                  const SizedBox(height: 20),
                  _buildCardGroup([
                    MoreMenuTile(
                      icon: Icons.store_outlined,
                      title: 'Shop Profile',
                      onTap: () {},
                    ),
                    MoreMenuTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    MoreMenuTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      onTap: () {},
                    ),
                    MoreMenuTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      showDivider: false,
                      onTap: () {
                        Get.toNamed(Routes.settingPage);
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 3: Support
                  CustomAppBar(title: 'Support'),
                  const SizedBox(height: 10),
                  _buildCardGroup([
                    MoreMenuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    MoreMenuTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About StockPulse',
                      showDivider: false,
                      onTap: () {},
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
}
