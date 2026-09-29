import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/route/app_routes.dart';
import '../../../../common/widgets/CustomSearchField.dart';
import '../../../../common/widgets/Custom_filter.dart';
import '../../../../common/widgets/StandardScreen.dart';
import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/product_shimmer.dart';
import '../../../../controllers/staff_controller.dart';
import '../../../../models/staff_model.dart';
import '../../../../utils/app_constants.dart';

class AllStaffView extends StatelessWidget {
  const AllStaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffController controller = Get.find<StaffController>();

    return CustomScreen(
      appBar: const CustomAppBar(
        title: Text(AppConstants.allStaff),
        showBackArrow: true,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          CustomSearchField(
            hintText: AppConstants.searchStaff,
            showScanner: false,
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
          ),

          const SizedBox(height: 12),

          // Filters
          Obx(
                () => CustomFilterTabs(
              items: const [
                AppConstants.all,
                AppConstants.pending,
                AppConstants.statusActive,
                AppConstants.statusInActive,
              ],
              selectedIndex: controller.selectedFilterIndex.value,
              onChanged: controller.changeFilter,
            ),
          ),

          const SizedBox(height: 12),

          // Staff List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: ProductListShimmer(),
                );
              }

              final staffList = controller.filteredStaff;

              if (staffList.isEmpty) {
                return const Center(
                  child: Text(
                    AppConstants.noStaffFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchStaff,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];

                    return StaffCard(
                      staff: staff,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      // Add Staff
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(Routes.addStaff);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(
          Icons.person_add_alt_1_rounded,
        ),
        label: const Text(
          AppConstants.addStaff,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final StaffModel staff;

  const StaffCard({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _avatarBackgroundColor,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: staff.profileImg != null &&
                  staff.profileImg!.isNotEmpty
                  ? Image.network(
                staff.profileImg!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _buildAvatarFallback();
                },
              )
                  : _buildAvatarFallback(),
            ),

            const SizedBox(width: 14),
            // Information

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          staff.isPending
                              ? 'Staff Member'
                              : (staff.name.isNotEmpty ? staff.name : 'Staff Member'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (!staff.isPending) ...[
                        Icon(
                          Icons.badge_outlined,
                          size: 15,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Expanded(
                        child: Text(
                          staff.isPending
                              ? (staff.email?.isNotEmpty ?? false ? staff.email! : 'No Email')
                              : _roleName(staff.email ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildActionsMenu(),
          ],
        ),
      ),
    );
  }

  // STATUS BADGE`

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (staff.status) {
      case StaffStatus.active:
        backgroundColor = const Color(0xFFA3EAC0);
        textColor = const Color(0xFF0F5B36);
        text = AppConstants.statusActive;
        break;

      case StaffStatus.inactive:
        backgroundColor = const Color(0xFFE0E0E0);
        textColor = Colors.black54;
        text = AppConstants.statusInActive;
        break;

      case StaffStatus.pending:
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF9A6700);
        text = AppConstants.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // AVATAR COLOR

  Color get _avatarBackgroundColor {
    switch (staff.status) {
      case StaffStatus.active:
        return const Color(0xFFE8F8F0);

      case StaffStatus.inactive:
        return const Color(0xFFF0F0F0);

      case StaffStatus.pending:
        return const Color(0xFFFFF8E1);
    }
  }

  // FALLBACK AVATAR

  Widget _buildAvatarFallback() {
    final value = staff.isPending ? staff.email : staff.name;

    final initial = value?.trim().isNotEmpty == true
        ? value!.trim()[0].toUpperCase()
        : 'S';

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: staff.isPending
              ? const Color(0xFF9A6700)
              : const Color(0xFF0F766E),
        ),
      ),
    );
  }

  // ROLE NAME

  String _roleName(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Owner';

      case 'staff':
        return 'Staff Member';

      default:
        return role;
    }
  }

  Widget _buildActionsMenu() {
    final controller = Get.find<StaffController>();

    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.black54,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'resend':
            controller.resendInvitation(staff);
            break;

          case 'cancel':
            controller.cancelInvitation(staff);
            break;

          case 'activate':
            controller.changeStaffStatus(staff, true);
            break;

          case 'deactivate':
            controller.changeStaffStatus(staff, false);
            break;
        }
      },
      itemBuilder: (context) {
        // Pending
        if (staff.isPending) {
          return [
            if (staff.isInviteExpired)
              const PopupMenuItem<String>(
                value: 'resend',
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF0F766E),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Resend Invitation'),
                  ],
                ),
              ),

            const PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Cancel Invitation'),
                ],
              ),
            ),
          ];
        }

        // Active
        if (staff.isActive) {
          return const [
            PopupMenuItem<String>(
              value: 'deactivate',
              child: Row(
                children: [
                  Icon(
                    Icons.block_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Mark Inactive'),
                ],
              ),
            ),
          ];
        }

        // Inactive
        return const [
          PopupMenuItem<String>(
            value: 'activate',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Mark Active'),
              ],
            ),
          ),
        ];
      },
    );
  }
}