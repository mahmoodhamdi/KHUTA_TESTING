import 'package:flutter/material.dart';

class InputThemes {
  static InputDecorationTheme lightInputTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4299E1), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade300),
    ),
    labelStyle: const TextStyle(color: Color(0xFF4A5568)),
    hintStyle: TextStyle(color: Colors.grey.shade400),
    prefixIconColor: const Color(0xFF4299E1),
    suffixIconColor: const Color(0xFF4299E1),
  );

  static InputDecorationTheme darkInputTheme = InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2D3748),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade800),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF63B3ED), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade300),
    ),
    labelStyle: const TextStyle(color: Color(0xFFE2E8F0)),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    prefixIconColor: const Color(0xFF63B3ED),
    suffixIconColor: const Color(0xFF63B3ED),
  );

  static DropdownMenuThemeData lightDropdownTheme = DropdownMenuThemeData(
    textStyle: const TextStyle(color: Color(0xFF2D3748), fontSize: 16),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(8),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static DropdownMenuThemeData darkDropdownTheme = DropdownMenuThemeData(
    textStyle: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 16),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF2D3748)),
      elevation: WidgetStateProperty.all(8),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static BoxDecoration getDropdownDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF2D3748) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? Colors.grey.shade800
            : Colors.grey.withValues(alpha: 0.2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
