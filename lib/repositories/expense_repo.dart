import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense_model.dart';

class ExpenseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'expenses';

  Future<ExpenseModel> addExpense(ExpenseModel expense) async{
    final response = await _supabase.from(_table)
        .insert(expense.toJson()).select().single();
    return ExpenseModel.fromJson(response);
  }


  /// Get Expenses of Shop
  Future<List<ExpenseModel>> getExpenses(int shopId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('shop_id', shopId)
        .order('expense_date', ascending: false)
        .order('created_at', ascending: false);

    return response
        .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
        .toList();
  }

  /// Delete Expense
  Future<void> deleteExpense(String expenseId) async {
    await _supabase
        .from(_table)
        .delete()
        .eq('id', expenseId);
  }
}