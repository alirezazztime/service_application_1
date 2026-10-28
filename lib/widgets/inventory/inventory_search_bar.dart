import 'package:flutter/material.dart';
import 'package:service_application_1/widgets_style/colors.dart';

class InventorySearchBar extends StatelessWidget {
  // کنترل‌کننده متن کادر جست‌وجو
  final TextEditingController controller;

  // هنگام تغییر متن جست‌وجو اجرا می‌شود
  final ValueChanged<String>? onChanged;

  const InventorySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      // اتصال کنترل‌کننده به کادر ورودی
      controller: controller,

      // ارسال متن تایپ‌شده به صفحه انبار
      onChanged: onChanged,

      // تنظیم جهت نوشتار فارسی
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      // ظاهر کادر جست‌وجو
      decoration: InputDecoration(
        hintText: '...جست‌وجوی محصول در انبار',
        hintStyle: const TextStyle(fontFamily: 'kalame'),

        // آیکون ذره‌بین
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 18),
          child: const Icon(Icons.search),
        ),
        // پس‌زمینه کادر
        filled: true,
        fillColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.focused)) {
            return Prime.prime10;
          }
          return Basicolor.basic11;
        }),

        // فاصله داخلی
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),

        // شکل کادر در حالت عادی
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(width: 1, color: Basicolor.basic09),
        ),

        // شکل کادر هنگام غیرفعال بودن
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),

        // شکل کادر هنگام تایپ
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: Prime.prime, width: 1),
        ),
      ),
    );
  }
}
