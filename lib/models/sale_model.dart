class SaleModel {
  final String id;
  final String saleNo;

  final DateTime saleDate;

  final double subtotal;
  final double discount;
  final double totalAmount;

  final String paymentMethod;

  final String? notes;

  final String status;

  final String createdBy;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SaleModel({
    required this.id,
    required this.saleNo,
    required this.saleDate,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
    this.notes,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================================
  // FROM SUPABASE
  // ============================================================

  factory SaleModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SaleModel(
      id: json['id'] as String,

      saleNo: json['sale_no'] as String,

      saleDate: DateTime.parse(
        json['sale_date'] as String,
      ),

      subtotal: _toDouble(
        json['subtotal'],
      ),

      discount: _toDouble(
        json['discount'],
      ),

      totalAmount: _toDouble(
        json['total_amount'],
      ),

      paymentMethod:
      json['payment_method'] as String? ??
          'cash',

      notes: json['notes'] as String?,

      status:
      json['status'] as String,

      createdBy:
      json['created_by'] as String,

      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),

      updatedAt: DateTime.parse(
        json['updated_at'] as String,
      ),
    );
  }

  // ============================================================
  // NUMERIC CONVERTER
  // ============================================================

  static double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }
}