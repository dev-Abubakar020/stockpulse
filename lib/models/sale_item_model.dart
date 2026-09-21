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