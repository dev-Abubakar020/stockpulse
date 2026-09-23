import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/widgets/appbar.dart';

import '../../common/data/countries_data.dart';
import '../../common/theme/theme_helper.dart';
import '../../common/widgets/custom_TextField.dart';
import '../../common/widgets/custom_button.dart';
import '../../controllers/shopCreateController.dart';
import '../../models/country_model.dart';
import '../../utils/app_constants.dart';

class EditShopDetails extends GetView<ShopCreateController> {
  const EditShopDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text(AppConstants.businessInfo),
        showBackArrow: true,
        actions: [
          Obx(() => TextButton.icon(
                onPressed: controller.toggleEditable,
                icon: Icon(
                  controller.isEditable.value ? Icons.close : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(
                  controller.isEditable.value ? AppConstants.cancelTitle : AppConstants.edit,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              )),
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
                    AppConstants.workspaceSubtitle,
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
                          title: AppConstants.shopDetails,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        Obx(() => CustomTextField(
                              controller: controller.ownerController,
                              labelText: AppConstants.ownerName,
                              hintText: AppConstants.nameHint,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: theme.primary,
                              ),
                              readOnly: !controller.isEditable.value,
                            )),
                        const SizedBox(height: 14),
                        Obx(() => CustomTextField(
                              controller: controller.shopController,
                              labelText: AppConstants.shopName,
                              hintText: AppConstants.enterShopName,
                              prefixIcon: Icon(
                                Icons.store_outlined,
                                color: theme.primary,
                              ),
                              readOnly: !controller.isEditable.value,
                            )),
                        const SizedBox(height: 14),
                        Obx(() => CustomTextField(
                              controller: controller.addressController,
                              labelText: AppConstants.completeAddress,
                              hintText: AppConstants.addressHint,
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: theme.primary,
                              ),
                              keyboardType: TextInputType.streetAddress,
                              readOnly: !controller.isEditable.value,
                            )),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          icon: Icons.payments_outlined,
                          title: AppConstants.currency,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        Obx(() => DropdownButtonFormField<CountryModel>(
                              value: controller.selectedCountry.value,
                              isExpanded: true,
                              disabledHint: Text(controller.selectedCountry.value.name),
                              decoration: InputDecoration(
                                labelText: AppConstants.country,
                                prefixIcon: const Icon(Icons.public),
                                filled: true,
                                fillColor: theme.surfaceMuted,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: theme.border),
                                ),
                              ),
                              items: controller.isEditable.value
                                  ? countries
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
                                      .toList()
                                  : [],
                              onChanged: controller.isEditable.value
                                  ? (country) {
                                      if (country != null) {
                                        controller.selectedCountry.value = country;
                                      }
                                    }
                                  : null,
                            )),
                        const SizedBox(height: 12),
                        Obx(() => Row(
                              children: [
                                Expanded(
                                  child: _ReadOnlyValue(
                                    label: AppConstants.symbol,
                                    value: controller.currency.symbol,
                                    theme: theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ReadOnlyValue(
                                    label: AppConstants.currencyCode,
                                    value: controller.currency.code,
                                    theme: theme,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 18),
                        Obx(() {
                          if (!controller.isEditable.value &&
                              controller.shopImageUrl.value.isEmpty &&
                              controller.imageBytes.value == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (controller.isEditable.value)
                                _ImagePickerTile(
                                  imageBytes: controller.imageBytes.value,
                                  onPressed: controller.pickImage,
                                  theme: theme,
                                )
                              else if (controller.shopImageUrl.value.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    controller.shopImageUrl.value,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 22),
                            ],
                          );
                        }),
                        Obx(() {
                          if (!controller.isEditable.value) {
                            return const SizedBox.shrink();
                          }
                          return AppButton(
                            text: AppConstants.updateBusiness,
                            onPressed: controller.updateShop,
                            isLoading: controller.isUpdating.value,
                            suffixIcon: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          );
                        }),
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
        imageBytes == null ? AppConstants.addShopImage : AppConstants.changeShopImage,
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
