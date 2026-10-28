import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'inventory_product_card.dart';

class InventoryProductGrid extends StatelessWidget {
  final List<Product> products;
  final void Function(Product product)? onEdit;
  final void Function(Product product)? onDeactivate;

  const InventoryProductGrid({
    super.key,
    required this.products,
    this.onEdit,
    this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تعداد ستون‌ها بر اساس عرض فضای موجود
        final int columns = constraints.maxWidth >= 1626
            ? 3
            : constraints.maxWidth >= 800
            ? 2
            : 1;

        return GridView.builder(
          itemCount: products.length,

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 290,
          ),

          itemBuilder: (context, index) {
            final product = products[index];

            return InventoryProductCard(
              product: product,
              onEdit: () => onEdit?.call(product),
              onDeactivate: () => onDeactivate?.call(product),
            );
          },
        );
      },
    );
  }
}
