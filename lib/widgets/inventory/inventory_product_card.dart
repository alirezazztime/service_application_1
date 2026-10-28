import 'dart:io';
import 'package:flutter/material.dart';
import 'package:service_application_1/widgets_style/colors.dart';
import 'package:service_application_1/widgets_style/typographick.dart';
import '../../models/product.dart';

// ============================================================
// بخش اول: صفحه پیش‌نمایش کارت محصول
// ============================================================

class ProductCardPreview extends StatelessWidget {
  const ProductCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // محصول آزمایشی
    const product = Product(
      id: 1,
      name: 'قهوه اسپرسو',
      salePrice: 120000,
      purchasePrice: 70000,
      stockType: 'quantity',
      stockQuantity: 20,
    );

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Center(
        child: SizedBox(
          width: 500,
          height: 290,
          child: InventoryProductCard(
            product: product,
            onEdit: () {},
            onDeactivate: () {},
          ),
        ),
      ),
    );
  }
}

// ============================================================
// بخش دوم: کلاس اصلی کارت محصول
// ============================================================

class InventoryProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDeactivate;

  const InventoryProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDeactivate,
  });

  // مسیر تصویر پیش‌فرض
  static const String defaultProductImage = 'assets/img/no img.jpg';

  // ==========================================================
  // بخش سوم: قالب‌بندی قیمت
  // ==========================================================

  String _formatPrice(int price) {
    final digits = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  // ==========================================================
  // بخش چهارم: ساخت ظاهر اصلی کارت
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth < 300
            ? constraints.maxWidth
            : 300;
        return SizedBox(
          width: cardWidth,
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: Basicolor.basic09),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // بخش بالایی: منو، نام و تصویر
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // منوی سه‌نقطه در گوشه بالا
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            color: Basicolor.basic11,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                width: 1,
                                color: Basicolor.basic09,
                              ),
                            ),
                            icon: const Icon(Icons.more_horiz, size: 22),
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit?.call();
                              } else if (value == 'deactivate') {
                                onDeactivate?.call();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'ویرایش محصول',
                                      style: AppTextStyle.titleLarge.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.edit),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'deactivate',
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'حذف محصول',
                                      style: AppTextStyle.titleLarge.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.delete),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // نام محصول در وسط
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              style: AppTextStyle.headlineMedium,
                              product.name,
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.rtl,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // تصویر محصول در سمت راست
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: _buildProductImage(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // موجودی
                  _buildInfoRow(
                    'موجودی',
                    product.stockType == 'unlimited'
                        ? 'نامحدود'
                        : _formatPrice(product.stockQuantity),
                  ),

                  const SizedBox(height: 4),

                  // قیمت خرید
                  _buildInfoRow(
                    'قیمت خرید',
                    product.purchasePrice == null
                        ? 'ثبت نشده'
                        : '${_formatPrice(product.purchasePrice!)} تومان',
                  ),

                  const SizedBox(height: 4),

                  // قیمت فروش
                  _buildInfoRow(
                    'قیمت فروش',
                    '${_formatPrice(product.salePrice)} تومان',
                  ),

                  const SizedBox(height: 0),

                  // وضعیت محصول
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStockStatus(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // بخش پنجم: تصویر محصول
  // اگر عکس وجود نداشته باشد، تصویر پیش‌فرض نمایش داده می‌شود.
  // ==========================================================

  Widget _buildProductImage() {
    final imagePath = product.imagePath;

    // محصول عکس ندارد
    if (imagePath == null || imagePath.isEmpty) {
      return _buildDefaultImage();
    }

    // محصول عکس دارد؛ تلاش برای نمایش فایل
    return Image.file(
      File(imagePath),
      width: 150,
      height: 150,
      fit: BoxFit.cover,

      // اگر فایل قابل بارگذاری نباشد، تصویر پیش‌فرض نمایش داده می‌شود.
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultImage();
      },
    );
  }

  // ==========================================================
  // بخش ششم: تصویر پیش‌فرض
  // ==========================================================

  Widget _buildDefaultImage() {
    return Image.asset(
      defaultProductImage,
      width: 64,
      height: 64,
      fit: BoxFit.cover,

      // اگر مسیر Asset اشتباه باشد، آیکون جایگزین نمایش داده می‌شود.
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          width: 64,
          height: 64,
          child: Icon(Icons.inventory_2_outlined),
        );
      },
    );
  }

  // ==========================================================
  // بخش هفتم: نمایش ردیف اطلاعات
  // برای قیمت فروش، قیمت خرید و موجودی استفاده می‌شود.
  // ==========================================================

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: AppTextStyle.titleLarge),
        Text(title, style: AppTextStyle.titleLarge),
      ],
    );
  }

  // ==========================================================
  // بخش هشتم: وضعیت موجودی
  // ==========================================================

  Widget _buildStockStatus() {
    if (product.stockType == 'unlimited') {
      return const Text(
        'موجودی: نامحدود',
        style: TextStyle(color: Color(0xff34C759), fontFamily: "kalame"),
      );
    }

    if (product.stockQuantity == 0) {
      return const Text(
        'ناموجود',
        style: TextStyle(color: Color(0xffFF383C), fontFamily: "kalame"),
      );
    }

    if (product.stockQuantity <= 5) {
      return const Text(
        'موجودی کم',
        style: TextStyle(color: Color(0xffFFCC00), fontFamily: "kalame"),
      );
    }

    return const Text(
      'موجود',
      style: TextStyle(color: Color(0xff34C759), fontFamily: "kalame"),
    );
  }
}
