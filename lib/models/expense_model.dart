//├── id           UUID
// ├── shop_id      BIGINT
// ├── category     TEXT
// ├── description  TEXT
// ├── amount       NUMERIC(12,2)
// ├── expense_date DATE
// ├── created_by   UUID
// ├── created_at   TIMESTAMPTZ
// └── updated_at   TIMESTAMPTZ

class ExpenseModel {
  final String? id;
  final int shopId;
  final String category;
  final String? description;
  final double amount;
  final DateTime expenseDate;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    this.id,
    required this.shopId,
    required this.category,
    this.description,
    required this.amount,
    required this.expenseDate,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Supabase JSON -> Model
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String?,
      shopId: (json['shop_id'] as num).toInt(),
      category: json['category'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expense_date']),
      createdBy: json['created_by'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Model -> Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': _dateOnly(expenseDate),
      'created_by': createdBy,
    };
  }

  /// For UPDATE
  Map<String, dynamic> toUpdateJson() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': _dateOnly(expenseDate),
    };
  }

  static String _dateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  ExpenseModel copyWith({
    String? id,
    int? shopId,
    String? category,
    String? description,
    double? amount,
    DateTime? expenseDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}