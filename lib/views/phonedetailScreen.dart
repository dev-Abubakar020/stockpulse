import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/data/countries_data.dart';
import 'package:stockpulse/common/data/phone_hint.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custome_appbar.dart';
import 'package:stockpulse/common/widgets/custome_button.dart';
import 'package:stockpulse/common/widgets/custome_textfield.dart';
import 'package:stockpulse/common/widgets/custome_textbutton.dart';
import 'package:stockpulse/controllers/loginController.dart';
import 'package:stockpulse/models/country_model.dart';
import 'package:stockpulse/utils/app_constants.dart';

class PhoneDetailScreen extends StatefulWidget {
  const PhoneDetailScreen({super.key});

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> {
  CountryModel selectedCountry = countries.firstWhere(
    (country) => country.isoCode == 'PK',
  );
  String get phoneHint => getPhoneHint(selectedCountry.isoCode);

  LoginController get controller => Get.find<LoginController>();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> handleContinue() {
    return controller.sendOtp(dialCode: selectedCountry.dialCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Ambient glow background
          Positioned(
            top: -100,
            right: -80,
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

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar
                    CustomeAppBar(
                      showBackButton: true,
                      title: AppConstants.phoneLoginTitle,
                      actions: const [_ThemeToggleButton()],
                    ),
                    const SizedBox(height: 28),

                    // Phone Emblem
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: theme.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: theme.border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: theme.cardShadow,
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.phone_iphone_rounded,
                          color: theme.primary,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      AppConstants.enterPhoneNumber,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sora(
                        color: theme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We will send a 6-digit one-time password to verify and secure your account.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.textSecondary,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 24,
                      ),
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
                          Text(
                            'MOBILE NUMBER',
                            style: GoogleFonts.plusJakartaSans(
                              color: theme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Phone input with country code picker
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: theme.surfaceMuted,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.border,
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<CountryModel>(
                                    value: selectedCountry,
                                    dropdownColor: theme.card,
                                    isExpanded: true,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),

                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: theme.textSecondary,
                                      size: 18,
                                    ),

                                    items: countries.map((country) {
                                      return DropdownMenuItem<CountryModel>(
                                        value: country,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              country.flagEmoji,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              country.dialCode,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    color: theme.textPrimary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    onChanged: (CountryModel? country) {
                                      if (country != null) {
                                        setState(() {
                                          selectedCountry = country;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.phoneController,
                                  hintText: phoneHint,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          Obx(
                            () => AppButton(
                              text: 'Send Verification Code',
                              onPressed: handleContinue,
                              isLoading: controller.isPhoneLoading.value,
                              suffixIcon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Encryption notice
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF10B981),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your phone number is encrypted & never shared.',
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.textHint,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Prefer email sign in?',
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.textSecondary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        CustomTextButton(
                          text: 'Back to Sign In',
                          fontSize: 14,
                          color: theme.primary,
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Material(
      color: theme.card,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => ThemeController.to.toggleTheme(),
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.border, width: 1),
          ),
          child: Icon(
            theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: theme.primary,
            size: 17,
          ),
        ),
      ),
    );
  }
}
