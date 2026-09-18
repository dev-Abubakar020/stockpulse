import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/controllers/signupController.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../common/widgets/themetogglebtn.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  bool agreeToTerms = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>();
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Ambient background orbs
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [theme.glow, theme.glow.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.glow.withValues(alpha: 0.6),
                    theme.glow.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                      Align(
                        alignment: Alignment.topRight,
                        child: const ThemeToggleButton(),
                      ),
                      const SizedBox(height: 8),
                      const _BrandHeader(),
                      const SizedBox(height: 24),
                      _SignupCard(
                        controller: controller,
                        agreeToTerms: agreeToTerms,
                        onTermsChanged: (val) {
                          setState(() => agreeToTerms = val ?? false);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.signupSignIn,
                            style: GoogleFonts.plusJakartaSans(
                              color: theme.textSecondary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          CustomTextButton(
                            text: 'Sign In',
                            fontSize: 14,
                            color: theme.primary,
                            onPressed: () => Get.toNamed(Routes.login),
                          ),
                        ],
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: theme.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(AppConstants.splashImage, fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF10B981),
                    blurRadius: 8,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NEW VENDOR REGISTRATION',
              style: GoogleFonts.sora(
                color: theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.signupTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            color: theme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your secure account to manage inventory & sales',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: theme.textSecondary,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SignupCard extends StatelessWidget {
  const _SignupCard({
    required this.controller,
    required this.agreeToTerms,
    required this.onTermsChanged,
  });

  final SignupController controller;
  final bool agreeToTerms;
  final ValueChanged<bool?> onTermsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadow,
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: controller.nameController,
            labelText: AppConstants.nameLabel,
            hintText: AppConstants.nameHint,
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: theme.primary,
              size: 20,
            ),
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.emailController,
            labelText: AppConstants.loginEmailLabel,
            hintText: AppConstants.loginEmailHint,
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              color: theme.primary,
              size: 20,
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Obx(
            () => CustomTextField(
              controller: controller.passwordController,
              labelText: AppConstants.loginPasswordLabel,
              hintText: 'At least 8 characters',
              obscureText: controller.obscurePassword.value,
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: theme.primary,
                size: 20,
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
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: agreeToTerms,
                  onChanged: onTermsChanged,
                  activeColor: theme.primary,
                  checkColor: Colors.white,
                  side: BorderSide(color: theme.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy.',
                  style: GoogleFonts.plusJakartaSans(
                    color: theme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Obx(
            () => AppButton(
              text: 'Create Account',
              onPressed: agreeToTerms ? controller.signup : null,
              isLoading: controller.isLoading.value,
              suffixIcon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _OrDivider(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SocialTile(
                  tooltip: 'Google',
                  onTap: controller.signInWithGoogle,
                  child: Obx(
                    () => controller.isGoogleLoading.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primary,
                            ),
                          )
                        : Image.asset(
                            AppConstants.googleLogo,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
              if (Platform.isIOS) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialTile(
                    tooltip: 'Apple',
                    onTap: () {},
                    child: Image.asset(
                      AppConstants.appleLogo,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),

              ///Will be used in future for mobile OTP login
              // Expanded(
              //   child: _SocialTile(
              //     tooltip: 'Mobile OTP',
              //     onTap: () => Get.toNamed(Routes.phoneDetails),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           Icons.phone_iphone_rounded,
              //           color: theme.primary,
              //           size: 20,
              //         ),
              //         const SizedBox(width: 6),
              //         Text(
              //           'OTP',
              //           style: TextStyle(
              //             color: theme.textPrimary,
              //             fontSize: 13,
              //             fontWeight: FontWeight.w700,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Row(
      children: [
        Expanded(child: Divider(color: theme.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: GoogleFonts.sora(
              color: theme.textHint,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.divider, thickness: 1)),
      ],
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.primary.withValues(alpha: 0.2),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border, width: 1),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

