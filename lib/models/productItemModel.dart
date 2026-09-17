class ProductItemModel {
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String iconEmoji;
  final String? stockStatus;

  const ProductItemModel({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.iconEmoji,
    this.stockStatus,
  });
}