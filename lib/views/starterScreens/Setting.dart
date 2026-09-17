import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/widgets/custome_appbar.dart';
import 'package:stockpulse/common/widgets/custome_header.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/custom_MenuTile.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomeAppBar(title: 'Setting',showBackButton: true,),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [

                    CustomHeading(title: 'About Profile'),
                    const SizedBox(height: 10),
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
                        icon: Icons.language,
                        title: 'Language',
                        showDivider: false,
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Section 3: Support
                    CustomHeading(title: 'Support'),
                    const SizedBox(height: 10),
                    _buildCardGroup([
                      MoreMenuTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Security',
                        onTap: () {},
                      ),
                      MoreMenuTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        color: Colors.red,
                        showDivider: false,
                        onTap: () {},
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
}