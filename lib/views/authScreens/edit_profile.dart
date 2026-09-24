import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/common/widgets/appbar.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/controllers/edit_profile_controller.dart';
import 'package:stockpulse/utils/app_constants.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return CustomScreen(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: Text(AppConstants.editProfileTitle),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppConstants.editProfileSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: theme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.border),
                    boxShadow: [
                      BoxShadow(
                        color: theme.cardShadow,
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar Section
                      Center(
                        child: _ProfileAvatarSection(controller: controller),
                      ),
                      const SizedBox(height: 24),

                      // Section Title
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            color: theme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppConstants.personalInfo,
                            style: GoogleFonts.sora(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      CustomTextField(
                        controller: controller.nameController,
                        labelText: AppConstants.nameLabel,
                        hintText: AppConstants.nameHint,
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: theme.primary,
                        ),
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),

                      // Email Field (Read Only)
                      CustomTextField(
                        controller: controller.emailController,
                        labelText: AppConstants.loginEmailLabel,
                        hintText: AppConstants.loginEmailHint,
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: theme.primary,
                        ),
                        suffixIcon: Tooltip(
                          message: AppConstants.emailCannotBeChanged,
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: theme.textHint,
                            size: 18,
                          ),
                        ),
                        enabled: false,
                        readOnly: true,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: theme.textHint,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              AppConstants.emailCannotBeChanged,
                              style: GoogleFonts.plusJakartaSans(
                                color: theme.textHint,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Update Button
                      Obx(
                        () => AppButton(
                          text: AppConstants.updateProfileBtn,
                          onPressed: controller.updateProfile,
                          isLoading: controller.isSaving.value,
                          suffixIcon: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatarSection extends StatelessWidget {
  const _ProfileAvatarSection({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Obx(() {
      final bytes = controller.imageBytes.value;
      final networkUrl = controller.profileImageUrl.value;

      ImageProvider? imageProvider;
      if (bytes != null) {
        imageProvider = MemoryImage(bytes);
      } else if (networkUrl.isNotEmpty) {
        imageProvider = NetworkImage(networkUrl);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.surfaceMuted,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 52,
                          color: theme.primary.withValues(alpha: 0.7),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primary,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            imageProvider != null
                ? AppConstants.changeProfilePhoto
                : AppConstants.addProfilePhoto,
            style: GoogleFonts.plusJakartaSans(
              color: theme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    });
  }
}
