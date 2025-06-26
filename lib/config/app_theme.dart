import 'package:flutter/material.dart';

class AppColors {
  // الألوان الذهبية العربية الكلاسيكية
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFF5E6A3);

  // الألوان الخضراء الطبيعية
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF81C784);

  // الألوان الكريمية والبيج
  static const Color cream = Color(0xFFF5F5DC);
  static const Color lightCream = Color(0xFFFAFAFA);
  static const Color darkCream = Color(0xFFE8E8DC);

  // الألوان البنية الترابية
  static const Color brown = Color(0xFF8D6E63);
  static const Color darkBrown = Color(0xFF5D4037);
  static const Color lightBrown = Color(0xFFBCAAA4);

  // الألوان الحمراء التقليدية
  static const Color traditionalRed = Color(0xFFD32F2F);
  static const Color darkRed = Color(0xFFB71C1C);

  // الألوان الرمادية
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFFBFBFB);
}

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,

      // نظام الألوان
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryGold,
        surface: AppColors.lightCream,
        background: AppColors.background,
      ),

      // تخصيص AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryGreen,
        titleTextStyle: TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // تخصيص الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // تخصيص البطاقات
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),

      // تخصيص حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.lightGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.lightGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
