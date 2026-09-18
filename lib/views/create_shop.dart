import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/data/countries_data.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/common/widgets/custom_TextField.dart';
import 'package:stockpulse/controllers/shopCreateController.dart';
import 'package:stockpulse/models/country_model.dart';

class CreateShop extends GetView<ShopCreateController> {
  const CreateShop({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Create your shop',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ThemeController.to.toggleTheme(),
            icon: Icon(
              theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Set up your workspace before entering the dashboard.',
                    style: GoogleFonts.plusJakartaSans(
                      color: theme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionTitle(
                          icon: Icons.storefront_outlined,
                          title: 'Shop details',
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: controller.ownerController,
                          labelText: 'Owner name',
                          hintText: 'Your name',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: theme.primary,
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: controller.shopController,
                          labelText: 'Shop name',
                          hintText: 'Enter your shop name',
                          prefixIcon: Icon(
                            Icons.store_outlined,
                            color: theme.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: controller.phoneController,
                          labelText: 'Phone (optional)',
                          hintText: 'Enter shop phone number',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: theme.primary,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: controller.addressController,
                          labelText: 'Complete address',
                          hintText: 'Street, area, city, and country',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: theme.primary,
                          ),
                          keyboardType: TextInputType.streetAddress,
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          icon: Icons.payments_outlined,
                          title: 'Currency',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        Obx(() => DropdownButtonFormField<CountryModel>(
                              //  ignore: deprecated_member_use
                              value: controller.selectedCountry.value,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Country',
                                prefixIcon: const Icon(Icons.public),
                                filled: true,
                                fillColor: theme.surfaceMuted,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: theme.border),
                                ),
                              ),
                              items: countries
                                  .map(
                                    (country) => DropdownMenuItem(
                                      value: country,
                                      child: Row(
                                        children: [
                                          Text(
                                            country.flagEmoji,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              country.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (country) {
                                if (country != null) {
                                  controller.selectedCountry.value = country;
                                }
                              },
                            )),
                        const SizedBox(height: 12),
                        Obx(() => Row(
                              children: [
                                Expanded(
                                  child: _ReadOnlyValue(
                                    label: 'Symbol',
                                    value: controller.currency.symbol,
                                    theme: theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ReadOnlyValue(
                                    label: 'Currency code',
                                    value: controller.currency.code,
                                    theme: theme,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 18),
                        Obx(() => _ImagePickerTile(
                              imageBytes: controller.imageBytes.value,
                              onPressed: controller.pickImage,
                              theme: theme,
                            )),
                        const SizedBox(height: 22),
                        Obx(() => AppButton(
                              text: 'Save and continue',
                              onPressed: controller.saveShop,
                              isLoading: controller.isSaving.value,
                              suffixIcon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.sora(
            color: theme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.border),
        ),
      ),
      child: Text(
        value,
        style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.imageBytes,
    required this.onPressed,
    required this.theme,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPressed;
  final dynamic theme;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: imageBytes == null
          ? const Icon(Icons.add_photo_alternate_outlined)
          : ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                imageBytes!,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
      label: Text(
        imageBytes == null ? 'Add shop image (optional)' : 'Change shop image',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.primary,
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: theme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
