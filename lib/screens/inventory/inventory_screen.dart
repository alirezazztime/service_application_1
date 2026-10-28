import 'package:flutter/material.dart';
import 'package:service_application_1/models/product.dart';
import 'package:service_application_1/repositories/product_repository.dart';
import 'package:service_application_1/widgets/inventory/inventory_header.dart';
import 'package:service_application_1/widgets/inventory/inventory_product_grid.dart';
import 'package:service_application_1/widgets_style/colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // ==================================================
  // متغیرها و کنترل‌کننده‌ها
  // ==================================================

  // ارتباط با پایگاه داده محصولات
  final ProductRepository _productRepository = ProductRepository();

  // کنترل‌کننده کادر جست‌وجو
  final TextEditingController _searchController = TextEditingController();

  // فهرست تمام محصولات موجود در انبار
  List<Product> products = [];

  // متن فعلی جست‌وجو
  String searchQuery = '';

  // گزینه مرتب‌سازی پیش‌فرض
  // newest = جدیدترین
  // oldest = قدیمی‌ترین
  // expensive = گران‌ترین
  // cheap = ارزان‌ترین
  String sortOption = 'newest';

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ==================================================
  // دریافت محصولات از پایگاه داده
  // ==================================================

  Future<void> _loadProducts() async {
    try {
      final result = await _productRepository.getAllProducts();

      if (!mounted) return;

      setState(() {
        products = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'خطا در دریافت محصولات: $e';
        isLoading = false;
      });
    }
  }

  // ==================================================
  // جست‌وجو و مرتب‌سازی محصولات
  // ==================================================

  List<Product> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();

    // فیلتر محصولات بر اساس نام
    final result = products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();

    // مرتب‌سازی محصولات
    switch (sortOption) {
      case 'newest':
        // فرض: شناسه بزرگ‌تر نشان‌دهنده ثبت جدیدتر است.
        result.sort((a, b) => (b.id ?? -1).compareTo(a.id ?? -1));
        break;

      case 'oldest':
        result.sort((a, b) => (a.id ?? -1).compareTo(b.id ?? -1));
        break;

      case 'expensive':
        result.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;

      case 'cheap':
        result.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
    }

    return result;
  }

  // ==================================================
  // ساخت هر گزینه از پاپ‌آپ
  // ==================================================

  PopupMenuEntry<String> _buildPopupOption({
    required String value,
    required String title,
  }) {
    final bool isSelected = sortOption == value;

    return PopupMenuItem<String>(
      value: value,

      // ظاهر: ارتفاع هر گزینه
      height: 44,

      // ظاهر: فاصله داخلی گزینه
      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          // ظاهر: رنگ پس‌زمینه گزینه انتخاب‌شده
          color: isSelected ? Prime.prime : Colors.transparent,

          // ظاهر: گردی گوشه‌های گزینه
          borderRadius: BorderRadius.circular(8),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

        child: Text(
          title,
          textAlign: TextAlign.right,

          // ظاهر: استایل متن گزینه‌ها
          style: TextStyle(
            fontFamily: 'kalame',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,

            // ظاهر: رنگ متن گزینه انتخاب‌شده
            color: isSelected ? Colors.white : Basicolor.basic01,
          ),
        ),
      ),
    );
  }

  // ==================================================
  // ساخت منوی مرتب‌سازی با Stroke سفارشی
  // ==================================================

  Widget _buildSortDropdown() {
    return SizedBox(
      width: 200, // ظاهر: عرض دکمه اصلی
      height: 40, // ظاهر: ارتفاع دکمه اصلی
      // ==========================================
      // تنظیم Theme مخصوص پاپ‌آپ
      // ==========================================
      child: Theme(
        data: Theme.of(context).copyWith(
          // ظاهر: رنگ پس‌زمینه هنگام Hover
          hoverColor: Colors.white,

          // ظاهر: رنگ پس‌زمینه هنگام کلیک
          highlightColor: Colors.white,

          // ظاهر: حذف افکت موجی کلیک
          splashColor: Colors.transparent,
        ),

        child: PopupMenuButton<String>(
          // مقدار انتخاب‌شده فعلی
          initialValue: sortOption,

          // ظاهر: محل بازشدن منو
          position: PopupMenuPosition.under,

          // ظاهر: فاصله منو از دکمه اصلی
          offset: const Offset(0, 4),

          // ظاهر: رنگ پس‌زمینه کل پاپ‌آپ
          color: Colors.white,

          // ظاهر: حذف سایه منو
          elevation: 0,

          // ظاهر: فاصله داخلی منوی بازشده
          menuPadding: const EdgeInsets.symmetric(vertical: 6),

          // ظاهر: محدودیت عرض منوی بازشده
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),

          // ==========================================
          // ظاهر: Stroke دور کل پاپ‌آپ
          // ==========================================
          shape: RoundedRectangleBorder(
            // ظاهر: گردی گوشه‌های کل منو
            borderRadius: BorderRadius.circular(16),

            // ظاهر: خط دور کل باکس
            side: const BorderSide(
              color: Prime.prime07, // رنگ Stroke
              width: 1.2, // ضخامت Stroke
              style: BorderStyle.solid,
            ),
          ),

          // گزینه‌های داخل منوی بازشونده
          itemBuilder: (context) => [
            _buildPopupOption(value: 'newest', title: 'جدیدترین محصولات'),
            _buildPopupOption(value: 'oldest', title: 'قدیمی‌ترین محصولات'),
            _buildPopupOption(value: 'expensive', title: 'گران‌ترین محصولات'),
            _buildPopupOption(value: 'cheap', title: 'ارزان‌ترین محصولات'),
          ],

          // تغییر گزینه مرتب‌سازی
          onSelected: (value) {
            setState(() {
              sortOption = value;
            });
          },

          // ==========================================
          // ظاهر دکمه اصلی Dropdown
          // ==========================================
          child: Container(
            width: double.infinity,
            height: 40,

            // ظاهر: فاصله داخلی دکمه
            padding: const EdgeInsets.symmetric(horizontal: 14),

            decoration: BoxDecoration(
              color: Colors.white,

              // ظاهر: گردی گوشه‌های دکمه اصلی
              borderRadius: BorderRadius.circular(100),

              // ظاهر: Stroke دور دکمه اصلی
              border: Border.all(color: Basicolor.basic10, width: 1),
            ),

            child: Row(
              children: [
                // متن گزینه انتخاب‌شده
                Expanded(
                  child: Text(
                    _getSortTitle(),

                    // ظاهر: استایل متن دکمه اصلی
                    style: const TextStyle(
                      fontFamily: 'kalame',
                      fontSize: 14,
                      color: Basicolor.basic01,
                    ),

                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // ظاهر: آیکون فلش
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 22,
                  color: Basicolor.basic01,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // عنوان گزینه انتخاب‌شده
  // ==================================================

  String _getSortTitle() {
    switch (sortOption) {
      case 'newest':
        return 'جدیدترین محصولات';

      case 'oldest':
        return 'قدیمی‌ترین محصولات';

      case 'expensive':
        return 'گران‌ترین محصولات';

      case 'cheap':
        return 'ارزان‌ترین محصولات';

      default:
        return 'مرتب‌سازی';
    }
  }

  // ==================================================
  // آزادسازی منابع
  // ==================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================================================
  // ساخت رابط کاربری صفحه انبار
  // ==================================================

  @override
  Widget build(BuildContext context) {
    // محصولات فیلترشده و مرتب‌شده
    final visibleProducts = filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              // سربرگ و کادر جست‌وجو
              InventoryHeader(
                onProductAdded: _loadProducts,
                searchController: _searchController,

                // دریافت متن جست‌وجو
                onSearchChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ردیف مرتب‌سازی
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // منوی مرتب‌سازی
                  _buildSortDropdown(),

                  // تعداد محصولات
                  Text(
                    'تعداد محصولات: ${visibleProducts.length}',
                    style: const TextStyle(
                      fontFamily: 'kalame',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Basicolor.basic01,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // نمایش محصولات
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : visibleProducts.isEmpty
                    ? Center(
                        child: Text(
                          searchQuery.trim().isEmpty
                              ? 'هنوز محصولی ثبت نشده است.'
                              : 'محصولی با این نام پیدا نشد.',
                        ),
                      )
                    : InventoryProductGrid(
                        products: visibleProducts,
                        onEdit: (product) {},
                        onDeactivate: (product) {},
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
