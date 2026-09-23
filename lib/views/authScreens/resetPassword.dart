import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/controllers/forgotPasswordController.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../common/widgets/appbar.dart';

class ResetPasswordScreen extends GetView<ForgotPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomAppBar(
                        title: Text(AppConstants.createNewPassword),
                      ),
                      const SizedBox(height: 28),

                      Text(
                        AppConstants.createNewPassword,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          color: theme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            CustomTextField(
                              controller: controller.newPasswordController,
                              labelText: AppConstants.newPasswordLabel,
                              hintText: '••••••••',
                              obscureText: true,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: controller.confirmPasswordController,
                              labelText: AppConstants.confirmPasswordLabel,
                              hintText: '••••••••',
                              obscureText: true,
                              prefixIcon: Icon(
                                Icons.lock_reset,
                                color: theme.primary,
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
          ),
        ],
      ),
    );
  }
}
