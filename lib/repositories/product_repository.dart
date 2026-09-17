import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/productItemModel.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // =========================
  // ADD PRODUCT
  // =========================

  Future<ProductItemModel> addProduct(
      ProductItemModel product,
      ) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = {
      ...product.toJson(),
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
      ) async {
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
  // DEACTIVATE PRODUCT
  // =========================

  Future<void> deactivateProduct(String productId) async {
    await _supabase
        .from('products')
        .update({
      'is_active': false,
      'updated_by': _supabase.auth.currentUser!.id,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', productId);
  }
}