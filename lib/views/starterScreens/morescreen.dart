import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/custome_appbar.dart';

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
            CustomeAppBar(title: 'More'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Section 1: Business Management
                  _buildSectionHeader('Business Management'),
                  _buildCardGroup([
                    MoreMenuTile(
                      icon: Icons.category_outlined,
                      title: 'Categories',
                      onTap: () {},
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
                      onTap: () {},
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
                  _buildSectionHeader('App Options'),
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
                  _buildSectionHeader('Support'),
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
      )
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
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