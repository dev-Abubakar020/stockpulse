import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sale_item_model.dart';
import '../models/sale_model.dart';

class SaleRepository {
  final SupabaseClient _supabase;

  SaleRepository({
    SupabaseClient? supabase,
  }) : _supabase =
      supabase ?? Supabase.instance.client;

  // ============================================================
  // CREATE SALE
  // ============================================================

  Future<String> createSale({
    required List<SaleItemModel> items,
    double discount = 0,
    String paymentMethod = 'cash',
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw Exception(
        'Sale must contain at least one product.',
      );
    }

    try {
      final response =
      await _supabase.rpc(
        'create_sale',
        params: {
          'p_items': items
              .map(
                (item) =>
                item.toRpcJson(),
          )
              .toList(),

          'p_discount': discount,

          'p_payment_method':
          paymentMethod.toLowerCase(),

          'p_notes':
          _cleanNotes(notes),
        },
      );

      if (response == null) {
        throw Exception(
          'Sale could not be created.',
        );
      }

      return response.toString();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  // ============================================================
  // GET ALL SALES
  // ============================================================

  Future<List<SaleModel>>
  getSales() async {
    try {
      final response =
      await _supabase
          .from('sales')
          .select()
          .order(
        'sale_date',
        ascending: false,
      );

      return (response as List)
          .map(
            (json) =>
            SaleModel.fromJson(
              Map<String, dynamic>.from(
                json,
              ),
            ),
      )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  // ============================================================
  // GET SINGLE SALE
  // ============================================================

  Future<SaleModel> getSaleById(
      String saleId,
      ) async {
    try {
      final response =
      await _supabase
          .from('sales')
          .select()
          .eq('id', saleId)
          .single();

      return SaleModel.fromJson(
        Map<String, dynamic>.from(
          response,
        ),
      );
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  // ============================================================
  // GET SALE ITEMS
  // ============================================================

  Future<List<SaleItemModel>> getSaleItems(String saleId) async {
    try {
      final response = await _supabase
          .from('sale_items')
          .select('''
            *,
            products (
              article,
              color,
              size,
              unit
            )
          ''')
          .eq('sale_id', saleId);

      return (response as List)
          .map(
            (json) => SaleItemModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  // ============================================================
  // CLEAN NOTES
  // ============================================================

  String? _cleanNotes(
      String? notes,
      ) {
    final value = notes?.trim();

    if (value == null ||
        value.isEmpty) {
      return null;
    }

    return value;
  }
}