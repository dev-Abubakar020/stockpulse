import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/models/shop_model.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopRepository {
  final SupabaseClient _supabase;

  ShopRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // ============================================================
  // CHECK CURRENT USER HAS SHOP
  // ============================================================

  Future<bool> currentUserHasShop() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    final response = await _supabase
        .from('shops')
        .select('id')
        .eq('auth_uid', user.id)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  // ============================================================
  // GET CURRENT USER SHOP
  // ============================================================

  Future<ShopModel?> getShop() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('shops')
        .select()
        .eq('auth_uid', user.id)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ShopModel.fromJson(response);
  }

  // ============================================================
  // CREATE SHOP
  // ============================================================

  Future<ShopModel> createShop({
    required String ownerName,
    required String shopName,
    required String phone,
    required String address,
    required String currencySymbol,
    required String currencyCode,
    XFile? image,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError(AppConstants.mustBeSignIn);
    }

    // ----------------------------------------------------------
    // Upload image
    // ----------------------------------------------------------

    String? imageUrl;

    if (image != null) {
      imageUrl = await _uploadShopImage(userId: user.id, image: image);
    }

    // ----------------------------------------------------------
    // Prepare model
    // ----------------------------------------------------------

    final shop = ShopModel.create(
      userId: user.id,
      shopName: shopName,
      ownerName: ownerName,
      phone: phone,
      address: address,
      currencySymbol: currencySymbol,
      currencyCode: currencyCode,
      imageUrl: imageUrl,
    );

    // ----------------------------------------------------------
    // Create shop
    // ----------------------------------------------------------

    final response = await _supabase
        .from('shops')
        .insert(shop.toJson())
        .select()
        .single();

    final createdShop = ShopModel.fromJson(response);

    if (createdShop.id == null) {
      throw StateError('Shop created but shop ID was not returned');
    }

    // ----------------------------------------------------------
    // Create OWNER membership
    // ----------------------------------------------------------

    await _supabase.from('shop_members').insert({
      'shop_id': createdShop.id,
      'user_id': user.id,
      'role': 'owner',
      'is_active': true,
      'created_by': user.id,
    });

    return createdShop;
  }

  // ============================================================
  // UPDATE SHOP
  // ============================================================

  Future<ShopModel> updateShop({
    required String shopName,
    required String ownerName,
    required String address,
    XFile? image,
    String? existingImageUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError(AppConstants.mustBeSignIn);
    }

    // ----------------------------------------------------------
    // Image
    // ----------------------------------------------------------

    String? imageUrl = existingImageUrl;

    if (image != null) {
      imageUrl = await _uploadShopImage(userId: user.id, image: image);
    }

    // ----------------------------------------------------------
    // Get existing shop
    // ----------------------------------------------------------

    final existingShop = await getShop();

    if (existingShop == null) {
      throw StateError('Shop details not found');
    }

    // ----------------------------------------------------------
    // Update model
    // ----------------------------------------------------------

    final updatedModel = existingShop.copyWith(
      shopname: shopName.trim(),
      ownername: ownerName.trim(),
      address: address.trim(),
      shopimg: imageUrl,
      updatedAt: DateTime.now().toUtc(),
    );

    // ----------------------------------------------------------
    // Update database
    // ----------------------------------------------------------

    final response = await _supabase
        .from('shops')
        .update(updatedModel.toJson())
        .eq('auth_uid', user.id)
        .select()
        .single();

    return ShopModel.fromJson(response);
  }

  // ============================================================
  // UPLOAD SHOP IMAGE
  // ============================================================

  Future<String> _uploadShopImage({
    required String userId,
    required XFile image,
  }) async {
    final extension = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : 'jpg';

    final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from('shop-images')
        .uploadBinary(
          path,
          await image.readAsBytes(),
          fileOptions: FileOptions(
            contentType: _getContentType(extension),
            upsert: false,
          ),
        );

    return _supabase.storage.from('shop-images').getPublicUrl(path);
  }

  // ============================================================
  // IMAGE CONTENT TYPE
  // ============================================================

  String _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'gif':
        return 'image/gif';

      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
