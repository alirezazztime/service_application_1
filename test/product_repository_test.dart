import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:service_application_1/database/app_database.dart';
import 'package:service_application_1/models/product.dart';
import 'package:service_application_1/repositories/product_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Product can be saved and retrieved', () async {
    final db = await AppDatabase.instance.database;

    // دیتابیس را برای تست خالی می‌کنیم.
    await db.delete('inventory_movements');
    await db.delete('payments');
    await db.delete('order_items');
    await db.delete('orders');
    await db.delete('products');

    final repository = ProductRepository();

    const product = Product(
      name: 'قهوه اسپرسو',
      salePrice: 120000,
      purchasePrice: 70000,
      stockQuantity: 20,
    );

    // ذخیره محصول
    final id = await repository.insertProduct(product);

    expect(id, greaterThan(0));

    // دریافت محصول ذخیره‌شده
    final savedProduct = await repository.getProductById(id);

    expect(savedProduct, isNotNull);
    expect(savedProduct!.name, 'قهوه اسپرسو');
    expect(savedProduct.salePrice, 120000);
    expect(savedProduct.purchasePrice, 70000);
    expect(savedProduct.stockQuantity, 20);

    // دریافت فهرست محصولات
    final products = await repository.getAllProducts();

    expect(products, hasLength(1));
  });
}
