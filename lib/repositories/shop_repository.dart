import 'package:image_picker/image_picker.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopRepository {
  final SupabaseClient _supabase;

  ShopRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<bool> currentUserHasShop() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final shop = await _supabase
        .from('shops')
        .select('auth_uid')
        .eq('auth_uid', user.id)
        .limit(1)
        .maybeSingle();
    return shop != null;
  }

  Future<Map<String, dynamic>?> getShop() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final shop = await _supabase
        .from('shops')
        .select()
        .eq('auth_uid', user.id)
        .limit(1)
        .maybeSingle();
    return shop;
  }

  Future<void> createShop({
    required String ownerName,
    required String shopName,
    required String phone,
    required String address,
    required String currencySymbol,
    required String currencyCode,
    XFile? image,
  }) async
  {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError(AppConstants.mustBeSignIn);
    }

    String? imageUrl;
    if (image != null) {
      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';
      final path =
          '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';

      await _supabase.storage
          .from('shop-images')
          .uploadBinary(
            path,
            await image.readAsBytes(),
            fileOptions: FileOptions(
              contentType: 'image/$extension',
              upsert: false,
            ),
          );
      imageUrl = _supabase.storage.from('shop-images').getPublicUrl(path);
    }

    final now = DateTime.now().toUtc().toIso8601String();
    await _supabase.from('shops').insert({
      'auth_uid': user.id,
      'shopename': shopName,
      'ownerame': ownerName,
      'phone': phone.isEmpty ? null : phone,
      'address': address,
      'selectedsymbole': currencySymbol,
      'selectedcurrency': currencyCode,
      'shopimg': imageUrl,
      'createdat': now,
      'updatedat': now,
    });
  }

  Future<Map<String, dynamic>> updateShop({
    required String shopName,
    required String ownerName,
    required String address,
    XFile? image,
    String? existingImageUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    String? imageUrl = existingImageUrl;
    if (image != null) {
      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';
      final path =
          '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';

      await _supabase.storage
          .from('shop-images')
          .uploadBinary(
            path,
            await image.readAsBytes(),
            fileOptions: FileOptions(
              contentType: 'image/$extension',
              upsert: false,
            ),
          );
      imageUrl = _supabase.storage.from('shop-images').getPublicUrl(path);
    }

    final response = await _supabase
        .from('shops')
        .update({
      'shopename': shopName.trim(),
      'ownerame': ownerName.trim(),
      'address': address.trim(),
      'shopimg': imageUrl,
      'updatedat': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('auth_uid', user.id)
        .select()
        .single();

    return response;
  }
}
