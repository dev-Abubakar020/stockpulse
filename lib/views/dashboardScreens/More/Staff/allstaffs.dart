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

class AllStaffView extends GetView<StaffController> {
  const AllStaffView({super.key});

  @override
  Widget build(BuildContext context) {

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
        heroTag: 'allStaffFab',
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

class StaffCard extends StatefulWidget {
  final StaffModel staff;

  const StaffCard({
    super.key,
    required this.staff,
  });

  @override
  State<StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<StaffCard> {
  bool isExpanded = false;

  StaffModel get staff => widget.staff;

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
        child: Column(
          children: [
            // =========================================================
            // MAIN STAFF ROW
            // =========================================================
            Row(
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
                      staff.profileImg!.trim().isNotEmpty
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

                // Name + Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              staff.isPending ||
                                  staff.name.trim().isEmpty
                                  ? AppConstants.staffMemberRole
                                  : staff.name,
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
                          Icon(
                            staff.isPending
                                ? Icons.schedule_rounded
                                : Icons.badge_outlined,
                            size: 15,
                            color: Colors.grey.shade500,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              staff.isPending
                                  ? AppConstants.invitationPending
                                  : _roleName(staff.role),
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

                const SizedBox(width: 4),

                // Expand / Collapse
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 23,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),

                // Actions
                _buildActionsMenu(),
              ],
            ),

            // =========================================================
            // EXPANDED STAFF DETAILS
            // =========================================================
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E)
                        .withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF0F766E)
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            AppConstants.staffDetailsHeader,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF0F766E)
                                    .withValues(alpha: 0.20),
                              ),
                            ),
                            child: Text(
                              staff.isPending
                                  ? AppConstants.invitation
                                  : AppConstants.account,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Email
                      _buildDetailRow(
                        icon: Icons.email_outlined,
                        label: AppConstants.loginEmailLabel,
                        value:
                        staff.email?.trim().isNotEmpty ==
                            true
                            ? staff.email!
                            : AppConstants.notAvailable,
                      ),

                      // Phone
                      if (!staff.isPending) ...[
                        const SizedBox(height: 11),

                        _buildDetailRow(
                          icon: Icons.phone_outlined,
                          label: AppConstants.phoneLabel,
                          value:
                          staff.phone
                              ?.trim()
                              .isNotEmpty ==
                              true
                              ? staff.phone!
                              : AppConstants.notAvailable,
                        ),
                      ],

                      // Joined Date
                      if (!staff.isPending &&
                          staff.joinedAt != null) ...[
                        const SizedBox(height: 11),

                        _buildDetailRow(
                          icon:
                          Icons.calendar_today_outlined,
                          label: AppConstants.joined,
                          value: _formatDate(
                            staff.joinedAt!,
                          ),
                        ),
                      ],

                      // Pending invitation expiry
                      if (staff.isPending &&
                          staff.expiresAt != null) ...[
                        const SizedBox(height: 11),

                        _buildDetailRow(
                          icon: Icons.timer_outlined,
                          label: AppConstants.invitationExpires,
                          value: _formatDate(
                            staff.expiresAt!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
            const Color(0xFF0F766E).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF0F766E),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: Color(0xFF94A3B8),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STATUS BADGE
  // =========================================================

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

  // =========================================================
  // AVATAR COLOR
  // =========================================================

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

  // =========================================================
  // AVATAR FALLBACK
  // =========================================================

  Widget _buildAvatarFallback() {
    final value = staff.isPending
        ? staff.email
        : staff.name;

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

  // =========================================================
  // ROLE NAME
  // =========================================================

  String _roleName(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return AppConstants.ownerRole;

      case 'staff':
        return AppConstants.staffMemberRole;

      default:
        return role;
    }
  }

  // =========================================================
  // DATE
  // =========================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // =========================================================
  // ACTION MENU
  // =========================================================

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
            controller.changeStaffStatus(
              staff,
              true,
            );
            break;

          case 'deactivate':
            controller.changeStaffStatus(
              staff,
              false,
            );
            break;
        }
      },
      itemBuilder: (context) {
        // Pending invitation
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
                    Text(AppConstants.resendInvitation),
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
                  Text(AppConstants.cancelInvitation),
                ],
              ),
            ),
          ];
        }

        // Active staff
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
                  Text(AppConstants.markInActive),
                ],
              ),
            ),
          ];
        }

        // Inactive staff
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
                Text(AppConstants.markActive),
              ],
            ),
          ),
        ];
      },
    );
  }
}