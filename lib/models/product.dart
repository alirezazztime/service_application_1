class Product {
  final int? id;
  final String name;
  final int salePrice;
  final int? purchasePrice;
  final String stockType;
  final int stockQuantity;
  final String? imagePath;
  final bool isActive;

  const Product({
    this.id,
    required this.name,
    required this.salePrice,
    this.purchasePrice,
    this.stockType = 'quantity',
    this.stockQuantity = 0,
    this.imagePath,
    this.isActive = true,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'stock_type': stockType,
      'stock_quantity': stockQuantity,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      salePrice: map['sale_price'] as int,
      purchasePrice: map['purchase_price'] as int?,
      stockType: map['stock_type'] as String,
      stockQuantity: map['stock_quantity'] as int,
      imagePath: map['image_path'] as String?,
      isActive: map['is_active'] == 1,
    );
  }
}
