import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/productItemModel.dart';
import '../models/category_model.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProductItemModel?> getProductByBarcode({
    required String barcode,
    required int shopId,
  }) async
  {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .eq('barcode', barcode.trim().toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProductItemModel.fromJson(response);
    } catch (e) {
      debugPrint('getProductByBarcode error: $e');
      rethrow;
    }
  }


  // =========================
  // GET ALL PRODUCTS
  // =========================

  Future<List<ProductItemModel>> getProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          categories (
            name
          )
        ''')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => ProductItemModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<List<ProductItemModel>> getStaffProducts() async {
    final response = await _supabase.rpc('get_staff_products');

    return (response as List)
        .map(
          (item) => ProductItemModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }


  // =========================
  // ADDING + FETCH PRODUCT CATEGORIES
  // =========================

  Future<CategoryModel> addCategory(
      CategoryModel category,
      ) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = {
      ...category.toJson(),
      'created_by': userId,
      'updated_by': userId,
    };

    final response = await _supabase
        .from('categories')
        .insert(data)
        .select('''
          *,
          categories (
            name
          )
        ''')
        .single();

    return CategoryModel.fromJson(response);
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select('id, name, is_active')
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map(
          (item) => CategoryModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // =========================
  // ADD PRODUCT
  // =========================

  Future<ProductItemModel> addProduct(
      ProductItemModel product,
      ) async
  {
    final userId = _supabase.auth.currentUser!.id;
    final rpcShopId = await _supabase.rpc('my_shop_id');
    final finalShopId = product.shopId ?? 
        (rpcShopId is num ? rpcShopId.toInt() : int.tryParse(rpcShopId?.toString() ?? ''));
    
    if (finalShopId == null) {
      throw Exception('No active shop found');
    }

    final data = {
      ...product.toJson(),
      // Force security-sensitive values here
      'shop_id': finalShopId,
      'created_by': userId,
      'updated_by': userId,
    };

    final response = await _supabase
        .from('products')
        .insert(data)
        .select('''
          *,
          categories (
            name
          )
        ''')
        .single();

    return ProductItemModel.fromJson(response);
  }

  // =========================
  // UPDATE PRODUCT
  // =========================

  Future<void> updateProduct(
      String productId,
      Map<String, dynamic> data,
      ) async
  {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase
        .from('products')
        .update({
      ...data,
      'updated_by': userId,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', productId);
  }

  // =========================
  // IMAGE UPLOAD
  // =========================

  Future<String> uploadProductImage(
      String fileName,
      List<int> bytes,
      ) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final path = '${user.id}/products/$fileName';

    await _supabase.storage
        .from('shop-images')
        .uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: const FileOptions(
        upsert: true,
      ),
    );

    return _supabase.storage
        .from('shop-images')
        .getPublicUrl(path);
  }

  // =========================
  // DELETE PRODUCT
  // =========================

  Future<void> deleteProduct(String productId) async {
    await _supabase
        .from('products').delete().eq('id', productId);
  }
}