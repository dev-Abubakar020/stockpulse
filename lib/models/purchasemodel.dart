class PurchaseItemModel {
  final String productId;
  final String article;
  final String? color;
  final String? size;
  final String unit;

  final double quantity;
  final double purchasePrice;

  const PurchaseItemModel({
    required this.productId,
    required this.article,
    this.color,
    this.size,
    required this.unit,
    required this.quantity,
    required this.purchasePrice,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['products'] as Map<String, dynamic>?;
    return PurchaseItemModel(
      productId: json['product_id'] as String,
      article: productJson?['article'] as String? ?? json['article'] as String? ?? '',
      color: productJson?['color'] as String? ?? json['color'] as String?,
      size: productJson?['size'] as String? ?? json['size'] as String?,
      unit: productJson?['unit'] as String? ?? json['unit'] as String? ?? 'pcs',
      quantity: _toDouble(json['quantity']),
      purchasePrice: _toDouble(json['purchase_price']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double get lineTotal => quantity * purchasePrice;

  /// Data required by create_purchase() RPC
  Map<String, dynamic> toRpcJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
    };
  }

  PurchaseItemModel copyWith({
    double? quantity,
    double? purchasePrice,
  }) {
    return PurchaseItemModel(
      productId: productId,
      article: article,
      color: color,
      size: size,
      unit: unit,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}


class PurchaseModel {
  final String id;
  final String purchaseNo;
  final DateTime purchaseDate;

  final double subtotal;
  final double discount;
  final double totalAmount;

  final String? notes;
  final String status;

  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PurchaseModel({
    required this.id,
    required this.purchaseNo,
    required this.purchaseDate,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    this.notes,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String,
      purchaseNo: json['purchase_no'] as String,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),

      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      totalAmount: _toDouble(json['total_amount']),

      notes: json['notes'] as String?,
      status: json['status'] as String,

      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}