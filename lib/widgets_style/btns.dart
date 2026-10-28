import 'package:flutter/material.dart';
import 'package:service_application_1/widgets_style/colors.dart';

class Buttons {
  static ButtonStyle normalbtn = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.transparent),

    foregroundColor: WidgetStateProperty.all(Basicolor.basic01),

    elevation: WidgetStateProperty.all(0),

    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(color: Basicolor.basic10, width: 1),
      ),
    ),

    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
    ),

    overlayColor: WidgetStateProperty.all(Colors.transparent),
  );

  static ButtonStyle primeBtn = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Prime.prime),

    foregroundColor: WidgetStateProperty.all(Basicolor.basic11),

    elevation: WidgetStateProperty.all(0),

    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(width: 0),
      ),
    ),

    padding: WidgetStateProperty.all(
      const EdgeInsets.only(left: 18, right: 24, top: 8, bottom: 8),
    ),

    overlayColor: WidgetStateProperty.all(null),
  );
}
