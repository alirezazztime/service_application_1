import 'package:service_application_1/database/app_database.dart';
import 'package:service_application_1/models/product.dart';

class ProductRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  // افزودن محصول جدید
  Future<int> insertProduct(Product product) async {
    final db = await _appDatabase.database;

    final id = await db.insert('products', product.toMap()..remove('id'));

    return id;
  }

  // دریافت محصولات فعال
  Future<List<Product>> getActiveProducts() async {
    final db = await _appDatabase.database;

    final result = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );

    return result.map((row) => Product.fromMap(row)).toList();
  }

  // دریافت تمام محصولات، شامل محصولات غیرفعال
  Future<List<Product>> getAllProducts() async {
    final db = await _appDatabase.database;

    final result = await db.query('products', orderBy: 'id DESC');

    return result.map((row) => Product.fromMap(row)).toList();
  }

  // دریافت محصولات دارای موجودی تعدادی
  Future<List<Product>> getQuantityProducts() async {
    final db = await _appDatabase.database;

    final result = await db.query(
      'products',
      where: "stock_type = ? AND is_active = ?",
      whereArgs: ['quantity', 1],
      orderBy: 'id DESC',
    );

    return result.map((row) => Product.fromMap(row)).toList();
  }

  // دریافت یک محصول با شناسه
  Future<Product?> getProductById(int id) async {
    final db = await _appDatabase.database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Product.fromMap(result.first);
  }

  // ویرایش اطلاعات محصول
  Future<int> updateProduct(Product product) async {
    if (product.id == null) {
      throw ArgumentError('Product ID is required for update.');
    }

    final db = await _appDatabase.database;

    return db.update(
      'products',
      {
        'name': product.name,
        'sale_price': product.salePrice,
        'purchase_price': product.purchasePrice,
        'stock_type': product.stockType,
        'stock_quantity': product.stockQuantity,
        'image_path': product.imagePath,
        'is_active': product.isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // تغییر موجودی محصول
  Future<int> updateStock({
    required int productId,
    required int quantity,
  }) async {
    if (quantity < 0) {
      throw ArgumentError('Stock quantity cannot be negative.');
    }

    final db = await _appDatabase.database;

    return db.update(
      'products',
      {
        'stock_quantity': quantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: "id = ? AND stock_type = 'quantity'",
      whereArgs: [productId],
    );
  }

  // غیرفعال کردن محصول بدون حذف سوابق
  Future<int> deactivateProduct(int productId) async {
    final db = await _appDatabase.database;

    return db.update(
      'products',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // فعال کردن مجدد محصول
  Future<int> activateProduct(int productId) async {
    final db = await _appDatabase.database;

    return db.update(
      'products',
      {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
