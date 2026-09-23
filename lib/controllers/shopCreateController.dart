import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/common/data/countries_data.dart';
import 'package:stockpulse/common/data/country_currency.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:stockpulse/services/networkManager.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/exceptional/platform_exceptions.dart';
import '../common/exceptional/validator.dart';
import '../common/widgets/custom_snackbar.dart';

class ShopCreateController extends GetxController {
  final ShopRepository shopRepository;

  ShopCreateController(this.shopRepository);

  final ownerController = TextEditingController();
  final shopController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final imagePicker = ImagePicker();
  final isUpdating = false.obs;
  final isEditable = false.obs;
  final isProfileLoading = false.obs;
  final shopImageUrl = ''.obs;
  final userProfileImageUrl = ''.obs;
  final userName = ''.obs;

  final selectedCountry = countries
      .firstWhere((country) => country.isoCode == 'PK')
      .obs;
  final selectedImage = Rxn<XFile>();
  final imageBytes = Rxn<Uint8List>();
  final isSaving = false.obs;

  CurrencyInfo get currency => getCurrency(selectedCountry.value.isoCode);

  @override
  void onInit() {
    super.onInit();
    fetchShopDetails();
  }

  void toggleEditable() {
    isEditable.toggle();
  }

  Future<void> fetchShopDetails() async {
    try {
      isProfileLoading.value = true;
      final user = Supabase.instance.client.auth.currentUser;
      final metadata = user?.userMetadata ?? <String, dynamic>{};
      userName.value =
          (metadata['name'] ??
                  metadata['full_name'] ??
                  metadata['display_name'] ??
                  user?.email?.split('@').first ??
                  '')
              .toString();
      userProfileImageUrl.value =
          (metadata['profile_img'] ??
                  metadata['avatar_url'] ??
                  metadata['picture'] ??
                  '')
              .toString();

      if (user != null) {
        try {
          final profile = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
          if (profile != null) {
            if (profile['name'] != null && profile['name'].toString().isNotEmpty) {
              userName.value = profile['name'].toString();
            } else if (profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) {
              userName.value = profile['full_name'].toString();
            }
            if (profile['profile_img'] != null && profile['profile_img'].toString().isNotEmpty) {
              userProfileImageUrl.value = profile['profile_img'].toString();
            } else if (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty) {
              userProfileImageUrl.value = profile['avatar_url'].toString();
            }
          }
        } catch (_) {}
      }

      final shop = await shopRepository.getShop();
      if (shop != null) {
        ownerController.text = shop['ownerame'] ?? userName.value;
        shopController.text = shop['shopename'] ?? '';
        addressController.text = shop['address'] ?? '';
        shopImageUrl.value = shop['shopimg'] ?? '';
        final currencyCode = shop['selectedcurrency'];
        if (currencyCode != null) {
          final country = countries.firstWhereOrNull(
            (c) => getCurrency(c.isoCode).code == currencyCode,
          );
          if (country != null) {
            selectedCountry.value = country;
          }
        }
      } else {
        ownerController.text = userName.value;
      }
    } catch (_) {
      final user = Supabase.instance.client.auth.currentUser;
      final metadata = user?.userMetadata ?? <String, dynamic>{};
      userName.value =
          (metadata['name'] ??
                  metadata['full_name'] ??
                  metadata['display_name'] ??
                  user?.email?.split('@').first ??
                  '')
              .toString();
      userProfileImageUrl.value =
          (metadata['profile_img'] ??
                  metadata['avatar_url'] ??
                  metadata['picture'] ??
                  '')
              .toString();
      ownerController.text = userName.value;
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image == null) return;

    selectedImage.value = image;
    final bytes = await image.readAsBytes();
    imageBytes.value = bytes;
  }

  Future<void> saveShop() async {
    final ownerName = ownerController.text.trim();
    final shopName = shopController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    final ownerError = CustomValidator.validateEmptyText(
      AppConstants.ownerName,
      ownerName,
    );
    if (ownerError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: ownerError,
      );
      return;
    }

    final shopError = CustomValidator.validateEmptyText(
      AppConstants.shopName,
      shopName,
    );
    if (shopError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: shopError,
      );
      return;
    }

    if (phone.isNotEmpty) {
      final phoneError = CustomValidator.validatePhone(phone);
      if (phoneError != null) {
        CustomSnackBar.warningSnackBar(
          title: AppConstants.warningTitle,
          message: phoneError,
        );
        return;
      }
    }

    final addressError = CustomValidator.validateEmptyText(
      AppConstants.completeAddress,
      address,
    );
    if (addressError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: addressError,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isSaving.value = true;
      await shopRepository.createShop(
        ownerName: ownerName,
        shopName: shopName,
        phone: phone,
        address: address,
        currencySymbol: currency.symbol,
        currencyCode: currency.code,
        image: selectedImage.value,
      );
      CustomSnackBar.successSnackBar(
        title: AppConstants.successTitle,
        message: AppConstants.shopCreatedSuccessMsg,
      );
      Get.offAllNamed(Routes.dashboard);
    } catch (error) {
      final exception = AppException.fromException(error);
      CustomSnackBar.errorSnackBar(
        title: AppConstants.couldNotCreateShopTitle,
        message: exception.message,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateShop() async {
    final ownerName = ownerController.text.trim();
    final shopName = shopController.text.trim();
    final address = addressController.text.trim();

    final ownerError = CustomValidator.validateEmptyText(
      AppConstants.ownerName,
      ownerName,
    );
    if (ownerError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: ownerError,
      );
      return;
    }

    final shopError = CustomValidator.validateEmptyText(
      AppConstants.shopName,
      shopName,
    );
    if (shopError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: shopError,
      );
      return;
    }

    final addressError = CustomValidator.validateEmptyText(
      AppConstants.completeAddress,
      address,
    );
    if (addressError != null) {
      CustomSnackBar.warningSnackBar(
        title: AppConstants.warningTitle,
        message: addressError,
      );
      return;
    }

    if (!await NetworkManager.instance.checkInternet()) return;

    try {
      isUpdating.value = true;

      final updatedShop = await shopRepository.updateShop(
        shopName: shopName,
        ownerName: ownerName,
        address: address,
        image: selectedImage.value,
        existingImageUrl: shopImageUrl.value.isEmpty
            ? null
            : shopImageUrl.value,
      );

      shopController.text = updatedShop['shopename'] ?? '';
      ownerController.text = updatedShop['ownerame'] ?? '';
      addressController.text = updatedShop['address'] ?? '';
      shopImageUrl.value = updatedShop['shopimg'] ?? '';
      isEditable.value = false;

      CustomSnackBar.successSnackBar(
        title: 'Profile Updated',
        message: 'Your business profile has been updated successfully.',
      );
    } catch (e) {
      final exception = AppException.fromException(e);

      CustomSnackBar.errorSnackBar(
        title: AppConstants.errorTitle,
        message: exception.message,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
