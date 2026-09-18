import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all categories ordered by name
  Future<List<CategoryModel>> getAllCategories() async {
    final response = await _supabase
        .from('categories')
        .select('*')
        .order('name', ascending: true);

    return (response as List)
        .map(
          (item) => CategoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // Add a new category
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final data = category.toJson();
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        data['created_by'] = user.id;
      }
    } catch (_) {
    }

    final response = await _supabase
        .from('categories')
        .insert(data)
        .select('*')
        .single();

    return CategoryModel.fromJson(response);
  }

  // Update category status (is_active)
  Future<void> updateCategoryStatus(String id, bool isActive) async {
    final updateData = {
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        updateData['created_by'] = user.id;
      }
    } catch (_) {}

    await _supabase
        .from('categories')
        .update(updateData)
        .eq('id', id);
  }
}
