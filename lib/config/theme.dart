import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBackground,
      colorScheme: const ColorScheme.dark(
        surface: kBackground,
        onSurface: kPrimaryText,
        primary: kAccentBlue,
        onPrimary: Colors.white,
        secondary: kAccentBlue,
        onSecondary: Colors.white,
        error: kError,
        onError: Colors.white,
        surfaceContainerHighest: kSurface,
        outline: kBorderColor,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: kPrimaryText,
          fontSize: kFontHeading,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: kPrimaryText),
      ),

      // Text
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: kPrimaryText, fontSize: kFontBase),
        bodyMedium: TextStyle(color: kPrimaryText, fontSize: kFontBase),
        bodySmall: TextStyle(color: kSecondaryText, fontSize: kFontSmall),
        titleLarge: TextStyle(color: kPrimaryText, fontSize: kFontHeading, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: kPrimaryText, fontSize: kFontTitle, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: kPrimaryText, fontSize: kFontBase, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: kSecondaryText, fontSize: kFontLabel),
        labelMedium: TextStyle(color: kSecondaryText, fontSize: kFontSmall),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: kBorderColor,
        thickness: 1,
        space: 0,
      ),

      // Card
      cardTheme: CardThemeData(
        color: kBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
          side: const BorderSide(color: kBorderColor, width: 1),
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: kFontBase,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryText,
          side: const BorderSide(color: kBorderColor),
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: kFontBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kAccentBlue,
          textStyle: const TextStyle(fontSize: kFontBase),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: kAccentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: kError),
        ),
        labelStyle: const TextStyle(color: kSecondaryText),
        hintStyle: const TextStyle(color: kSecondaryText, fontSize: kFontBase),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kSurface,
        contentTextStyle: const TextStyle(color: kPrimaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
        behavior: SnackBarBehavior.floating,
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kSurface,
        modalBackgroundColor: kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(color: kPrimaryText),
      primaryIconTheme: const IconThemeData(color: kAccentBlue),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: kAccentBlue,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: kAccentBlue,
        brightness: Brightness.light,
        surface: Colors.white,
        onSurface: kPrimaryText,
        primary: kAccentBlue,
        onPrimary: Colors.white,
        secondary: kAccentBlue,
        outline: const Color(0xFFE0E0E0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: kPrimaryText,
          fontSize: kFontHeading,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: kPrimaryText),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: kPrimaryText, fontSize: kFontBase),
        bodyMedium: TextStyle(color: kPrimaryText, fontSize: kFontBase),
        bodySmall: TextStyle(color: kSecondaryText, fontSize: kFontSmall),
        titleLarge: TextStyle(color: kPrimaryText, fontSize: kFontHeading, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: kPrimaryText, fontSize: kFontTitle, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: kPrimaryText, fontSize: kFontBase, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: kSecondaryText, fontSize: kFontLabel),
        labelMedium: TextStyle(color: kSecondaryText, fontSize: kFontSmall),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
          side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: kFontBase,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryText,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: kFontBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kAccentBlue,
          textStyle: const TextStyle(fontSize: kFontBase),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusInput),
          borderSide: const BorderSide(color: kAccentBlue, width: 2),
        ),
      ),
    );
  }
}
