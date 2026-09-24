import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/controllers/forgotPasswordController.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/StandardScreen.dart';
import '../../common/widgets/appbar.dart';
class ResetPasswordScreen extends GetView<ForgotPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return CustomScreen(
      glowColor: theme.glow,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXXL),

                Text(
                  AppConstants.createNewPassword,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    color: theme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                Text(
                  AppConstants.resetPasswordDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: theme.textSecondary,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      Obx(
                        () => CustomTextField(
                          controller: controller.newPasswordController,
                          labelText: AppConstants.newPasswordLabel,
                          hintText: '••••••••',
                          obscureText: controller.obscurePassword.value,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: theme.primary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: controller.togglePassword,
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.textHint,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => CustomTextField(
                          controller: controller.confirmPasswordController,
                          labelText: AppConstants.confirmPasswordLabel,
                          hintText: '••••••••',
                          obscureText: controller.obscureConfirmPassword.value,
                          prefixIcon: Icon(
                            Icons.lock_reset,
                            color: theme.primary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: controller.toggleConfirmPassword,
                            icon: Icon(
                              controller.obscureConfirmPassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.textHint,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Obx(
                        () => AppButton(
                          text: AppConstants.updatePasswordBtn,
                          onPressed: controller.updatePassword,
                          isLoading: controller.isLoading.value,
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
