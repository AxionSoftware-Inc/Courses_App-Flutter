import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    textColor: AppColors.textMainLight,
    subTextColor: AppColors.textSecondaryLight,
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    textColor: AppColors.textMainDark,
    subTextColor: AppColors.textSecondaryDark,
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color primary,
    required Color secondary,
  }) {
    final isDark = brightness == Brightness.dark;
    final baseText = GoogleFonts.manropeTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? AppColors.premiumNavy : Colors.white,
      secondary: secondary,
      onSecondary: AppColors.premiumNavy,
      error: AppColors.danger,
      onError: Colors.white,
      surface: cardColor,
      onSurface: textColor,
      surfaceContainerHighest: isDark
          ? const Color(0xFF16322D)
          : const Color(0xFFE4F0EC),
      onSurfaceVariant: subTextColor,
      outline: isDark ? const Color(0xFF20433D) : const Color(0xFFD7E4DE),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? Colors.white : AppColors.premiumNavy,
      onInverseSurface: isDark ? AppColors.premiumNavy : Colors.white,
      inversePrimary: isDark ? AppColors.primaryLight : AppColors.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: colorScheme,
      cardColor: cardColor,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
        bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
        bodySmall: baseText.bodySmall?.copyWith(
          fontSize: 12,
          color: subTextColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.manrope(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          backgroundColor: primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF112824) : Colors.white,
        hintStyle: TextStyle(color: subTextColor),
        labelStyle: TextStyle(color: subTextColor),
        prefixIconColor: subTextColor,
        suffixIconColor: subTextColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.45),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        height: 82,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? primary
                : subTextColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primary
                : subTextColor,
            size: states.contains(WidgetState.selected) ? 26 : 22,
          );
        }),
        indicatorColor: primary.withValues(alpha: 0.14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF18332E)
            : AppColors.premiumNavy,
        contentTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withValues(alpha: 0.08),
        selectedColor: primary,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        secondaryLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }
}
