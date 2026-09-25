class SaleItemModel {
  final String productId;
  final String article;
  final String? color;
  final String? size;
  final String unit;

  final double quantity;
  final double salePrice;

  const SaleItemModel({
    required this.productId,
    required this.article,
    this.color,
    this.size,
    required this.unit,
    required this.quantity,
    required this.salePrice,
  });


  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['products'] as Map<String, dynamic>?;
    return SaleItemModel(
      productId: json['product_id'] as String,
      article: productJson?['article'] as String? ?? json['article'] as String? ?? '',
      color: productJson?['color'] as String? ?? json['color'] as String?,
      size: productJson?['size'] as String? ?? json['size'] as String?,
      unit: productJson?['unit'] as String? ?? json['unit'] as String? ?? 'pcs',
      quantity: _toDouble(json['quantity']),
      salePrice: _toDouble(json['sale_price']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // LINE TOTAL
  // ============================================================

  double get lineTotal => quantity * salePrice;

  // ============================================================
  // DATA SENT TO create_sale() RPC
  // ============================================================

  Map<String, dynamic> toRpcJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'sale_price': salePrice,
    };
  }

  // ============================================================
  // COPY
  // ============================================================

  SaleItemModel copyWith({
    double? quantity,
    double? salePrice,
  }) {
    return SaleItemModel(
      productId: productId,
      article: article,
      color: color,
      size: size,
      unit: unit,
      quantity: quantity ?? this.quantity,
      salePrice: salePrice ?? this.salePrice,
    );
  }
}