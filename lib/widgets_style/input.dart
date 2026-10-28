import 'package:flutter/material.dart';
import 'package:service_application_1/widgets_style/colors.dart';

class AppInputs {
  static InputDecoration customInput({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: WidgetStateTextStyle.resolveWith((state) {
        if (state.contains(WidgetState.focused)) {
          return TextStyle(color: Prime.prime, fontFamily: "kalame");
        }
        return TextStyle(color: Basicolor.basic05, fontFamily: "kalame");
      }),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return Prime.prime10; // رنگ پس‌زمینه هنگام فوکوس (دلخواه شما)
        }
        return Basicolor.basic11; // رنگ پس‌زمینه در حالت عادی
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: Basicolor.basic09, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: Prime.prime07, width: 1),
      ),
    );
  }
}
