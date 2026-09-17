

class ProductItemModel {
  final String id;
  final String article;
  final String? categoryId;
  final String? categoryName;

  final String? color;
  final String? size;
  final String? barcode;
  final String unit;

  final double purchasePrice;
  final double salePrice;

  final double currentStock;
  final double minStockThreshold;

  final String? imageUrl;
  final bool isActive;

  final String? createdBy;
  final String? updatedBy;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductItemModel({
    required this.id,
    required this.article,
    this.categoryId,
    this.categoryName,
    this.color,
    this.size,
    this.barcode,
    required this.unit,
    required this.purchasePrice,
    required this.salePrice,
    required this.currentStock,
    required this.minStockThreshold,
    this.imageUrl,
    required this.isActive,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Supabase -> Flutter
  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    return ProductItemModel(
      id: json['id'] ?? '',
      article: json['article'] ?? '',
      categoryId: json['category_id'],

      // Comes from joined categories table
      categoryName: json['categories']?['name'],

      color: json['color'],
      size: json['size'],
      barcode: json['barcode'],
      unit: json['unit'] ?? 'pcs',

      purchasePrice:
      (json['purchase_price'] as num?)?.toDouble() ?? 0,

      salePrice:
      (json['sale_price'] as num?)?.toDouble() ?? 0,

      currentStock:
      (json['current_stock'] as num?)?.toDouble() ?? 0,

      minStockThreshold:
      (json['min_stock_threshold'] as num?)?.toDouble() ?? 0,

      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,

      createdBy: json['created_by'],
      updatedBy: json['updated_by'],

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Flutter -> Supabase
  Map<String, dynamic> toJson() {
    return {
      'article': article,
      'category_id': categoryId,
      'color': color,
      'size': size,
      'barcode': barcode,
      'unit': unit,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'current_stock': currentStock,
      'min_stock_threshold': minStockThreshold,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  bool get isOutOfStock => currentStock <= 0;

  bool get isLowStock =>
      currentStock > 0 &&
          currentStock <= minStockThreshold;

  String? get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return null;
  }
}