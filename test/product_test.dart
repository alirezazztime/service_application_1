import 'package:flutter_test/flutter_test.dart';
import 'package:service_application_1/models/product.dart';

void main() {
  test('Product converts to Map and back', () {
    const product = Product(
      name: 'قهوه اسپرسو',
      salePrice: 120000,
      purchasePrice: 70000,
      stockQuantity: 20,
    );

    final map = product.toMap();

    final restoredProduct = Product.fromMap({...map, 'id': 1});

    expect(restoredProduct.id, 1);
    expect(restoredProduct.name, 'قهوه اسپرسو');
    expect(restoredProduct.salePrice, 120000);
    expect(restoredProduct.purchasePrice, 70000);
    expect(restoredProduct.stockQuantity, 20);
  });

  test('Product can have no purchase price', () {
    const product = Product(name: 'پیتزا پپرونی', salePrice: 350000);

    final map = product.toMap();

    final restoredProduct = Product.fromMap({...map, 'id': 2});

    expect(restoredProduct.purchasePrice, isNull);
    expect(restoredProduct.salePrice, 350000);
  });
}
