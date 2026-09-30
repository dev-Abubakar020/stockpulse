import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchasemodel.dart';

class PurchaseRepository {
  final SupabaseClient _supabase;

  PurchaseRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ============================================================
  // CREATE PURCHASE
  // ============================================================

  Future<String> createPurchase({
    required List<PurchaseItemModel> items,
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw Exception('Purchase must contain at least one product.');
    }

    try {
      final response = await _supabase.rpc(
        'create_purchase',
        params: {
          'p_items': items.map((item) => item.toRpcJson()).toList(),
          'p_notes': _cleanNotes(notes),
        },
      );

      if (response == null) {
        throw Exception('Purchase could not be created.');
      }

      return response.toString();
    } on PostgrestException catch (e) {
      debugPrint('Message: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrint('========================================');
      throw Exception(e.message);
    }
  }

  // ============================================================
  // GET PURCHASES
  // ============================================================

  Future<List<PurchaseModel>> getPurchases() async {
    try {
      final response = await _supabase
          .from('purchases')
          .select()
          .order('purchase_date', ascending: false);

      return (response as List)
          .map(
            (json) => PurchaseModel.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  // ============================================================
  // GET PURCHASE ITEMS
  // ============================================================

  Future<List<PurchaseItemModel>> getPurchaseItems(String purchaseId) async {
    try {
      final response = await _supabase
          .from('purchase_items')
          .select('''
            *,
            products (
              article,
              color,
              size,
              unit
            )
          ''')
          .eq('purchase_id', purchaseId);

      return (response as List)
          .map(
            (json) => PurchaseItemModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  // ============================================================
  // GET USER NAME
  // ============================================================

  Future<String> getUserName(String userId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        final metaName = currentUser.userMetadata?['name'] as String? ??
            currentUser.userMetadata?['full_name'] as String?;
        if (metaName != null && metaName.trim().isNotEmpty) {
          return metaName.trim();
        }
        if (currentUser.email != null && currentUser.email!.isNotEmpty) {
          return currentUser.email!.split('@').first;
        }
      }

      final response = await _supabase
          .from('profiles')
          .select('name, full_name, email')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final name = response['name'] as String? ??
            response['full_name'] as String? ??
            response['email'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          return name.trim().contains('@')
              ? name.trim().split('@').first
              : name.trim();
        }
      }
    } catch (e) {
      debugPrint('Purchase getUserName error: $e');
    }

    return 'Staff Member';
  }

  String? _cleanNotes(String? notes) {
    final value = notes?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }
}