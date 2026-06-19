import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color surface = Color(0xFFFBF9F6);
  static const Color surfaceDim = Color(0xFFDBDAD7);
  static const Color surfaceBright = Color(0xFFFBF9F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3F0);
  static const Color surfaceContainer = Color(0xFFEFEEEB);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E5);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DF);
  
  static const Color onSurface = Color(0xFF110F2D);
  static const Color onSurfaceVariant = Color(0xFF47464D);
  
  static const Color outline = Color(0xFF78767E);
  static const Color outlineVariant = Color(0xFFC9C5CE);
  
  static const Color primary = Color(0xFF110F2D); // Indigo Night
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1A1833);
  static const Color onPrimaryContainer = Color(0xFF8480A0);
  
  static const Color secondary = Color(0xFFA258F3); // Magic Lilac
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF1DAFF);
  static const Color onSecondaryContainer = Color(0xFF2D004F);
  
  static const Color tertiary = Color(0xFFFF9933); // Sunset Gold
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF2F1500);
  static const Color onTertiaryContainer = Color(0xFFC96B00);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  
  static const Color shadowColor = Color(0x0D110F2D); // 5% opacity of primary

  // Magic button linear gradient or solid color
  static const Color magicButtonColor = Color(0xFFB159F7); // HSL 275, 85%, 65% is approx #B352F7
  
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        surface: surface,
        onSurface: onSurface,
        surfaceDim: surfaceDim,
        surfaceBright: surfaceBright,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: baseTextTheme.copyWith(
        // display-lg (Desktop)
        displayLarge: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.displayLarge,
          fontSize: 56.0,
          fontWeight: FontWeight.bold,
          height: 64.0 / 56.0,
          letterSpacing: -0.02,
          color: onSurface,
        ),
        // display-lg-mobile
        displayMedium: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.displayMedium,
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
          height: 48.0 / 40.0,
          letterSpacing: -0.02,
          color: onSurface,
        ),
        // headline-md
        headlineLarge: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.headlineLarge,
          fontSize: 32.0,
          fontWeight: FontWeight.w600,
          height: 40.0 / 32.0,
          color: onSurface,
        ),
        // headline-sm
        headlineMedium: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.headlineMedium,
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          height: 32.0 / 24.0,
          color: onSurface,
        ),
        // body-lg
        bodyLarge: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.bodyLarge,
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          height: 28.0 / 18.0,
          color: onSurfaceVariant,
        ),
        // body-md
        bodyMedium: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.bodyMedium,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          height: 24.0 / 16.0,
          color: onSurface,
        ),
        // label-md
        labelLarge: GoogleFonts.plusJakartaSans(
          textStyle: baseTextTheme.labelLarge,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          height: 20.0 / 14.0,
          letterSpacing: 0.05,
          color: onSurface,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x1A110F2D), // Indigo Night at 10% opacity
        thickness: 1.0,
      ),
    );
  }
}
