import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/controllers/forgotPasswordController.dart';
import 'package:stockpulse/utils/app_constants.dart';
import '../../common/widgets/StandardScreen.dart';
import '../../common/widgets/appbar.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return CustomScreen(
      glowColor: theme.glow,

      appBar: CustomAppBar(
        title: Text(AppConstants.loginForgotPassword),
        showBackArrow: true,
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spaceXXL),

                // Shield Emblem
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.cardShadow,
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: theme.primary,
                      size: 34,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                Text(
                  AppConstants.loginForgotPassword,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    color: theme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceSM),

                Text(
                  AppConstants.recoveryEmailSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: theme.textSecondary,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXXL),

                // Recovery Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceXL,
                    vertical: AppConstants.spaceXXL,
                  ),
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: theme.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.cardShadow,
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Obx(
                        () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: controller.emailOrPhoneController,
                          labelText:
                          controller.selectedRecoveryMethod.value == 0
                              ? AppConstants.regEmailAddress
                              : 'Registered Phone Number',
                          hintText:
                          controller.selectedRecoveryMethod.value == 0
                              ? AppConstants.emailHint
                              : '+1 (555) 000-0000',
                          prefixIcon: Icon(
                            controller.selectedRecoveryMethod.value == 0
                                ? Icons.mail_outline_rounded
                                : Icons.phone_outlined,
                            color: theme.primary,
                            size: 20,
                          ),
                          keyboardType:
                          controller.selectedRecoveryMethod.value == 0
                              ? TextInputType.emailAddress
                              : TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: AppConstants.spaceXL),

                        AppButton(
                          text: AppConstants.sendVerificationCode,
                          onPressed: controller.sendRecoveryCode,
                          isLoading: controller.isLoading.value,
                          suffixIcon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.rememberPassword,
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CustomTextButton(
                      text: AppConstants.loginButton,
                      fontSize: 14,
                      color: theme.primary,
                      onPressed: Get.back,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryTab extends StatelessWidget {
  const _RecoveryTab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? theme.card : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected
              ? Border.all(
                  color: theme.primary.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? theme.primary : theme.textHint,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? theme.textPrimary : theme.textHint,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
