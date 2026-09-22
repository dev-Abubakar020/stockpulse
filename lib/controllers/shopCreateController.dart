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
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    ownerController.text =
        (metadata['name'] ??
                metadata['full_name'] ??
                metadata['display_name'] ??
                user?.email?.split('@').first ??
                '')
            .toString();
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
}
