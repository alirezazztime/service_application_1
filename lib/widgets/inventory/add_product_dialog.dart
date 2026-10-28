import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_application_1/widgets_style/typographick.dart';
import 'package:service_application_1/models/product.dart';
import 'package:service_application_1/repositories/product_repository.dart';
import 'package:service_application_1/widgets_style/colors.dart';

// ============================================================
// دکمه افزودن محصول
// ============================================================
class AddProductButton extends StatelessWidget {
  final VoidCallback? onProductAdded;

  const AddProductButton({super.key, this.onProductAdded});

  Future<void> _openDialog(BuildContext context) async {
    final added = await showDialog<bool>(
      context: context,

      // رفتار پنجره: با کلیک بیرون پنجره بسته نشود.
      barrierDismissible: false,

      builder: (_) => const AddProductDialog(),
    );

    // اگر محصول با موفقیت ثبت شد، فهرست محصولات به‌روزرسانی شود.
    if (added == true) {
      onProductAdded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _openDialog(context),

      // 🎨 تغییر آیکون دکمه افزودن
      icon: const Icon(Icons.add),

      // 🎨 تغییر متن دکمه افزودن
      label: const Text('افزودن محصول جدید'),
    );
  }
}

// ============================================================
// پنجره افزودن محصول
// ============================================================
class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  // کلید فرم برای بررسی معتبر بودن اطلاعات واردشده
  final _formKey = GlobalKey<FormState>();

  // کنترل‌کننده‌های فیلدهای ورودی
  final _nameController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();

  // ارتباط با دیتابیس و انتخاب تصویر
  final _repository = ProductRepository();
  final _imagePicker = ImagePicker();

  // نوع موجودی: محدود یا نامحدود
  String _stockType = 'quantity';

  // مسیر تصویر انتخاب‌شده
  String? _imagePath;

  // مشخص می‌کند که ذخیره‌سازی در حال انجام است یا نه
  bool _isSaving = false;

  // ============================================================
  // بررسی آماده بودن فرم برای ثبت
  // این قسمت منطق برنامه است؛ برای تغییر ظاهر ویرایشش نکن.
  // ============================================================
  bool get _isFormReady {
    final name = _nameController.text.trim();

    final salePrice = int.tryParse(_salePriceController.text.trim());

    final quantity = int.tryParse(_stockQuantityController.text.trim());

    final validName = name.isNotEmpty;
    final validSalePrice = salePrice != null && salePrice > 0;

    final validQuantity =
        _stockType == 'unlimited' || (quantity != null && quantity >= 0);

    return validName && validSalePrice && validQuantity && !_isSaving;
  }

  // ============================================================
  // انتخاب تصویر محصول
  // ============================================================
  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,

        // 🎨 کیفیت تصویر انتخاب‌شده
        // عدد بالاتر معمولاً کیفیت بیشتر و حجم فایل بزرگ‌تر دارد.
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() {
        _imagePath = image.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتخاب تصویر با خطا مواجه شد.')),
      );
    }
  }

  // ============================================================
  // ذخیره محصول در دیتابیس
  // این بخش منطق برنامه است؛ برای تغییر ظاهر ویرایشش نکن.
  // ============================================================
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isFormReady) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final product = Product(
        name: _nameController.text.trim(),

        salePrice: int.parse(_salePriceController.text.trim()),

        purchasePrice: _purchasePriceController.text.trim().isEmpty
            ? null
            : int.parse(_purchasePriceController.text.trim()),

        stockType: _stockType,

        stockQuantity: _stockType == 'unlimited'
            ? 0
            : int.parse(_stockQuantityController.text.trim()),

        imagePath: _imagePath,
        isActive: true,
      );

      await _repository.insertProduct(product);

      if (!mounted) return;

      // با مقدار true به پنجره قبلی اعلام می‌کنیم محصول ثبت شده است.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ذخیره محصول انجام نشد. دوباره تلاش کنید.'),
        ),
      );
    }
  }

  // ============================================================
  // آزاد کردن منابع کنترل‌کننده‌ها
  // ============================================================
  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _stockQuantityController.dispose();

    super.dispose();
  }

  // ============================================================
  // ساخت فیلدهای ورودی
  //
  // این تابع برای نام محصول، قیمت فروش، تعداد و قیمت خرید
  // استفاده می‌شود؛ بنابراین تغییر ظاهر این تابع روی همه آن‌ها
  // اثر می‌گذارد.
  // ============================================================
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool requiredField = false,
    bool numeric = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          requiredField ? '$label (اجباری)' : label,
          // 🎨 ظاهر عنوان بالای فیلد
          style: const TextStyle(
            // اندازه نوشته عنوان فیلد
            fontSize: 16,
            fontFamily: "kalame",
            // ضخامت نوشته عنوان فیلد
            fontWeight: FontWeight.w400,
          ),
        ),

        // 🎨 فاصله عنوان فیلد تا کادر ورودی
        const SizedBox(height: 8),

        SizedBox(
          height: 40,
          child: TextFormField(
            textAlign: TextAlign.right,
            controller: controller,

            // نوع کیبورد: عددی یا متنی
            keyboardType: numeric ? TextInputType.number : TextInputType.text,

            // هنگام تایپ، وضعیت دکمه ثبت دوباره بررسی شود.
            onChanged: (_) => setState(() {}),

            // اعتبارسنجی اطلاعات ورودی
            validator: validator,

            decoration: InputDecoration(
              // 🎨 متن راهنمای داخل کادر
              hintText: hint,
              hintStyle: WidgetStateTextStyle.resolveWith((state) {
                if (state.contains(WidgetState.focused)) {
                  return TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Prime.prime,
                    fontFamily: "kalame",
                  );
                }
                return TextStyle(
                  color: Basicolor.basic06,
                  fontFamily: "kalame",
                  fontSize: 14,
                );
              }),
              // فعال کردن رنگ پس‌زمینه کادر
              filled: true,

              // 🎨 رنگ پس‌زمینه فیلد
              fillColor: WidgetStateColor.resolveWith((state) {
                if (state.contains(WidgetState.focused)) {
                  return Prime.prime10;
                }
                return Basicolor.basic11;
              }),
              // 🎨 فاصله متن داخل کادر از لبه‌های آن
              // horizontal = فاصله چپ و راست
              // vertical = فاصله بالا و پایین
              contentPadding: const EdgeInsets.only(right: 16),

              // 🎨 ظاهر کادر در حالت عادی
              border: OutlineInputBorder(
                // 🎨 میزان گردی گوشه‌های کادر
                // عدد بیشتر = گوشه‌های گردتر
                borderRadius: BorderRadius.circular(100),

                // 🎨 رنگ و ضخامت خط دور کادر
                borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Prime.prime),
                borderRadius: BorderRadius.circular(100),
              ),
              // 🎨 ظاهر کادر در حالت فعال و آماده تایپ
              enabledBorder: OutlineInputBorder(
                // 🎨 میزان گردی گوشه‌های کادر
                borderRadius: BorderRadius.circular(22),

                // 🎨 رنگ خط دور کادر در حالت عادی
                borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
              ),

              // 🎨 اندازه نوشته خطا زیر فیلد
              errorStyle: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // بررسی معتبر بودن قیمت
  // این قسمت منطق اعتبارسنجی است؛ برای تغییر ظاهر ویرایشش نکن.
  // ============================================================
  String? _validatePrice(String? value, {bool requiredField = false}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return requiredField ? 'این فیلد اجباری است.' : null;
    }

    final price = int.tryParse(text);

    if (price == null || price <= 0) {
      return 'مبلغ باید عددی بزرگ‌تر از صفر باشد.';
    }

    return null;
  }

  // ============================================================
  // ساخت ظاهر اصلی پنجره
  // اگر می‌خواهی اندازه، شکل یا فاصله پنجره را تغییر بدهی،
  // از این قسمت شروع کن.
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      // 🎨 رنگ پس‌زمینه کل پنجره
      backgroundColor: Colors.white,

      // 🎨 فاصله پنجره از لبه‌های صفحه
      // عدد بیشتر = پنجره از اطراف فاصله بیشتری می‌گیرد.
      insetPadding: const EdgeInsets.all(24),

      // 🎨 شکل و گردی گوشه‌های پنجره
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          // 🎨 حداکثر عرض پنجره
          maxWidth: 711,

          // 🎨 حداکثر ارتفاع پنجره
          maxHeight: 520,
        ),

        child: Padding(
          // 🎨 فاصله محتوای داخل پنجره از لبه‌های آن
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // اگر عرض موجود حداقل 500 باشد، فرم دو ستونه می‌شود.
                        // 🎨 برای تغییر نقطه تبدیل به حالت دو ستونه،
                        // عدد 500 را تغییر بده.
                        final wide = constraints.maxWidth >= 500;

                        // بخش انتخاب تصویر
                        final imageSection = _buildImageSection();

                        // =================================================
                        // بخش فیلدهای محصول
                        // ترتیب فیلدها را از این قسمت تغییر بده.
                        // =================================================
                        final formSection = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // -------------------------------
                            // 🎨 فیلد نام محصول
                            // -------------------------------
                            _buildInput(
                              // 🎨 عنوان فیلد
                              label: 'نام محصول',

                              controller: _nameController,

                              // 🎨 متن راهنمای داخل فیلد
                              hint: 'نام محصول را وارد کنید',

                              requiredField: true,

                              // منطق بررسی خالی نبودن نام
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'نام محصول الزامی است.';
                                }

                                return null;
                              },
                            ),

                            // 🎨 فاصله نام محصول تا فیلد بعدی
                            const SizedBox(height: 14),

                            // -------------------------------
                            // 🎨 فیلد قیمت فروش
                            // -------------------------------
                            _buildInput(
                              label: 'قیمت فروش',
                              controller: _salePriceController,
                              hint: 'قیمت فروش به تومان',
                              requiredField: true,
                              numeric: true,

                              // منطق بررسی قیمت فروش
                              validator: (value) =>
                                  _validatePrice(value, requiredField: true),
                            ),

                            // 🎨 فاصله قیمت فروش تا نوع موجودی
                            const SizedBox(height: 14),

                            // -------------------------------
                            // 🎨 عنوان انتخاب نوع موجودی
                            // -------------------------------
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'نوع موجودی محصول (اجباری)',

                                // 🎨 اندازه نوشته نوع موجودی
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: "kalame",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            // 🎨 فاصله عنوان تا دکمه‌های نوع موجودی
                            const SizedBox(height: 8),

                            // -------------------------------
                            // 🎨 دکمه‌های انتخاب نوع موجودی
                            // ظاهر دکمه‌ها را در تابع _stockOption
                            // در انتهای فایل تغییر بده.
                            // -------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: _stockOption(
                                      title: 'محدود',
                                      value: 'quantity',
                                    ),
                                  ),
                                ),

                                // 🎨 فاصله بین دو دکمه
                                const SizedBox(width: 8),

                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: _stockOption(
                                      title: 'نامحدود',
                                      value: 'unlimited',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // اگر موجودی محدود باشد، فیلد تعداد نمایش داده می‌شود.
                            if (_stockType == 'quantity') ...[
                              // 🎨 فاصله دکمه‌های موجودی تا فیلد تعداد
                              const SizedBox(height: 14),

                              // -------------------------------
                              // 🎨 فیلد تعداد موجودی
                              // -------------------------------
                              _buildInput(
                                label: 'تعداد موجودی',
                                controller: _stockQuantityController,
                                hint: 'تعداد محصول',
                                requiredField: true,
                                numeric: true,

                                // منطق بررسی تعداد موجودی
                                validator: (value) {
                                  if (_stockType == 'unlimited') {
                                    return null;
                                  }

                                  final text = value?.trim() ?? '';
                                  final quantity = int.tryParse(text);

                                  if (text.isEmpty) {
                                    return 'تعداد موجودی الزامی است.';
                                  }

                                  if (quantity == null || quantity < 0) {
                                    return 'تعداد باید صفر یا بیشتر باشد.';
                                  }

                                  return null;
                                },
                              ),
                            ],

                            // 🎨 فاصله تا فیلد قیمت خرید
                            const SizedBox(height: 24),

                            // -------------------------------
                            // 🎨 فیلد قیمت خرید
                            // -------------------------------
                            _buildInput(
                              label: 'قیمت خرید',
                              controller: _purchasePriceController,
                              hint: 'قیمت خرید به تومان (اختیاری)',
                              numeric: true,

                              // منطق بررسی قیمت خرید
                              validator: (value) {
                                final text = value?.trim() ?? '';

                                if (text.isEmpty) return null;

                                final price = int.tryParse(text);

                                if (price == null || price < 0) {
                                  return 'قیمت خرید معتبر نیست.';
                                }

                                return null;
                              },
                            ),
                          ],
                        );

                        // =================================================
                        // چیدمان موبایل و صفحه باریک
                        // تصویر بالای فیلدها نمایش داده می‌شود.
                        // =================================================
                        if (!wide) {
                          return Column(
                            children: [
                              imageSection,

                              // 🎨 فاصله تصویر تا فیلدها
                              const SizedBox(height: 8),

                              formSection,
                            ],
                          );
                        }

                        // =================================================
                        // چیدمان صفحه عریض
                        // فیلدها سمت چپ و تصویر سمت راست قرار می‌گیرند.
                        // =================================================
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 250, child: formSection),

                            // 🎨 فاصله بین فیلدها و بخش تصویر
                            const SizedBox(width: 18),

                            Expanded(child: imageSection),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 🎨 فاصله فرم تا دکمه‌های پایین پنجره
                const SizedBox(height: 0),

                // =================================================
                // 🎨 دکمه‌های پایین پنجره
                // ظاهر دکمه ثبت را در FilledButton.styleFrom
                // ویرایش کن.
                // =================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // -------------------------------
                    // دکمه بستن پنجره
                    // -------------------------------
                    SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style:
                            TextButton.styleFrom(
                              foregroundColor: Colors.white, // رنگ متن
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 24,
                              ),
                            ).copyWith(
                              // حتماً باید نام ویژگی رو اینجا هم بنویسی
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Prime.prime08; // رنگ هنگام کلیک
                                    }
                                    if (states.contains(WidgetState.hovered)) {
                                      return Prime.prime10; // رنگ هنگام هاور
                                    }
                                    return Colors.white; // رنگ در حالت عادی
                                  }),
                              foregroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.white; // رنگ هنگام کلیک
                                }
                                if (states.contains(WidgetState.hovered)) {
                                  return Prime.prime; // رنگ هنگام هاور
                                }
                                return Prime.prime; // رنگ در حالت عادی
                              }),
                            ),
                        child: const Text(
                          'بستن صفحه',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: "kalame",
                          ),
                        ),
                      ),
                    ),
                    // -------------------------------
                    // 🎨 دکمه ثبت اطلاعات
                    // -------------------------------
                    SizedBox(width: 18),
                    SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: _isFormReady ? _saveProduct : null,
                        style:
                            TextButton.styleFrom(
                              foregroundColor: Prime.prime, // رنگ متن
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 24,
                              ),
                            ).copyWith(
                              // حتماً باید نام ویژگی رو اینجا هم بنویسی
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Prime.prime08; // رنگ هنگام کلیک
                                    }
                                    if (states.contains(WidgetState.hovered)) {
                                      return Prime.prime10; // رنگ هنگام هاور
                                    }
                                    if (states.contains(WidgetState.disabled)) {
                                      return Basicolor.basic11;
                                    }
                                    return Colors.white; // رنگ در حالت عادی
                                  }),
                              foregroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Prime.prime; // رنگ هنگام کلیک
                                }
                                if (states.contains(WidgetState.hovered)) {
                                  return Prime.prime; // رنگ هنگام هاور
                                }
                                if (states.contains(WidgetState.disabled)) {
                                  return Basicolor.basic07;
                                }
                                return Prime.prime; // رنگ در حالت عادی
                              }),
                            ),
                        child: const Text(
                          'ثبت اطلاعات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: "kalame",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 بخش انتخاب و نمایش تصویر محصول
  // اگر می‌خواهی اندازه، رنگ، گوشه‌ها یا دکمه تصویر را تغییر بدهی،
  // این تابع را ویرایش کن.
  // ============================================================
  Widget _buildImageSection() {
    return Container(
      // 🎨 ارتفاع کادر تصویر
      height: 396,
      // 🎨 عرض کادر تصویر
      // double.infinity یعنی تمام عرض فضای موجود
      width: double.infinity,

      decoration: BoxDecoration(
        // 🎨 رنگ پس‌زمینه کادر تصویر
        color: Basicolor.basic11,

        // 🎨 میزان گردی گوشه‌های کادر تصویر
        borderRadius: BorderRadius.circular(24),

        // 🎨 خط دور کادر تصویر
        border: Border.all(color: Basicolor.basic09),
      ),

      child: Column(
        // 🎨 محل قرارگیری محتویات داخل کادر تصویر
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          // اگر تصویر انتخاب شده باشد، آن را نمایش بده.
          if (_imagePath != null)
            Expanded(
              child: ClipRRect(
                // 🎨 گردی گوشه‌های خود تصویر
                borderRadius: BorderRadius.circular(20),

                child: Image.file(
                  File(_imagePath!),

                  // 🎨 عرض تصویر
                  width: double.infinity,

                  // 🎨 نحوه پر شدن فضای تصویر
                  // cover یعنی کادر پر شود؛ ممکن است بخشی از تصویر بریده شود.
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            // 🎨 متن زمانی که هنوز تصویری انتخاب نشده
            Text('عکس خود را وارد کنید', style: AppTextStyle.displayLarge),

          // 🎨 فاصله تصویر یا متن راهنما تا دکمه انتخاب تصویر
          const SizedBox(height: 12),

          // =================================================
          // 🎨 دکمه انتخاب تصویر
          // =================================================
          SizedBox(
            width: 232,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _pickImage,

              // 🎨 آیکون دکمه تصویر
              icon: const Icon(Icons.add_photo_alternate_outlined),

              // 🎨 متن دکمه تصویر
              label: Text(
                'عکس خود را انتخاب کنید',
                style: AppTextStyle.titleMedium,
              ),

              style: OutlinedButton.styleFrom(
                // 🎨 رنگ متن و آیکون دکمه
                foregroundColor: Prime.prime,

                // 🎨 رنگ خط دور دکمه
                side: BorderSide(color: Prime.prime09),
              ),
            ),
          ),

          // 🎨 فاصله پایین دکمه تا انتهای کادر
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 دکمه‌های انتخاب نوع موجودی
  // تغییر رنگ حالت انتخاب‌شده و انتخاب‌نشده از این قسمت است.
  // ============================================================
  Widget _stockOption({required String title, required String value}) {
    // بررسی می‌کند که این گزینه انتخاب شده است یا نه.
    final selected = _stockType == value;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _stockType = value;
        });
      },

      style: OutlinedButton.styleFrom(
        // 🎨 رنگ پس‌زمینه دکمه انتخاب‌شده
        // 🎨 رنگ پس‌زمینه دکمه انتخاب‌نشده
        backgroundColor: selected ? Prime.prime : Basicolor.basic11,

        // 🎨 رنگ متن دکمه انتخاب‌شده
        // 🎨 رنگ متن دکمه انتخاب‌نشده
        foregroundColor: selected ? Colors.white : Colors.black87,

        // 🎨 رنگ خط دور دکمه
        // حالت انتخاب‌شده نارنجی و حالت انتخاب‌نشده خاکستری است.
        side: BorderSide(color: selected ? Prime.prime : Basicolor.basic09),
      ),

      // 🎨 عنوان هر گزینه
      child: Text(title, style: AppTextStyle.labelLarge),
    );
  }
}
