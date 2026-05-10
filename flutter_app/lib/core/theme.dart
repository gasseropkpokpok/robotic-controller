import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkRedTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.redAccent,
      scaffoldBackgroundColor: const Color(0xFF0A0000), // Deep space black/red
      colorScheme: const ColorScheme.dark(
        primary: Colors.redAccent,
        secondary: Colors.red,
        surface: Color(0xFF140000),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Colors.redAccent,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.red,
        overlayColor: Color(0x29F44336),
        valueIndicatorColor: Colors.redAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 8,
          shadowColor: Colors.redAccent.withOpacity(0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A0000),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
