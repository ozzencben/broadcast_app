import 'package:flutter/material.dart';

class AppTheme {
  // Görselden damıtılan renk paleti
  static const Color primaryGreen = Color(0xFF8CE58C);
  static const Color accentPurple = Color(0xFFA197FB);
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color lightBackground = Color(0xFFF9F9F9);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentPurple,
        surface: Colors.white,
        onPrimary: textDark, // Yeşil butonların üstündeki yazı rengi
        onSecondary: textDark,
        onSurface: textDark,
      ),

      // Tipografi (Pubspec'e Poppins eklemeyi unutma)
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textDark,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
      ),

      // Buton Stilleri (Görseldeki o tam oval (pill) butonlar)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Tam yuvarlak köşeler
          ),
        ),
      ),

      // Outlined Buton (Belki siyah butonlar için kullanırsın)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textLight,
          backgroundColor: darkBackground,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),

      // Kart Stilleri (O kocaman kıvrımlı menüler için)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Geniş kıvrımlar
        ),
      ),

      // Input Stilleri (Login/Register için şık durur)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
