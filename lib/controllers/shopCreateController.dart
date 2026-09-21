import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/common/data/countries_data.dart';
import 'package:stockpulse/common/data/country_currency.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/repositories/shop_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopCreateController extends GetxController {
  final ShopRepository shopRepository;

  ShopCreateController(this.shopRepository);

  final ownerController = TextEditingController();
  final shopController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final imagePicker = ImagePicker();

  final selectedCountry = countries.firstWhere((country) => country.isoCode == 'PK').obs;
  final selectedImage = Rxn<XFile>();
  final imageBytes = Rxn<Uint8List>();
  final isSaving = false.obs;

  CurrencyInfo get currency => getCurrency(selectedCountry.value.isoCode);

  @override
  void onInit() {
    super.onInit();
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    ownerController.text = (metadata['name'] ??
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
    final address = addressController.text.trim();

    if (ownerName.isEmpty || shopName.isEmpty || address.isEmpty) {
      Get.snackbar(
        'Required fields',
        'Please complete the owner, shop, and address fields.',
      );
      return;
    }

    try {
      isSaving.value = true;
      await shopRepository.createShop(
        ownerName: ownerName,
        shopName: shopName,
        phone: phoneController.text.trim(),
        address: address,
        currencySymbol: currency.symbol,
        currencyCode: currency.code,
        image: selectedImage.value,
      );
      Get.offAllNamed(Routes.dashboard);
    } catch (error) {
      Get.snackbar('Could not create shop', error.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
