import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Book-inspired color palette
  static const Color _primaryBookBlue = Color(0xFF4F46E5); // Deep book blue
  static const Color _secondaryOrange = Color(0xFFEF4444); // Warm orange/red
  static const Color _accentLightBlue = Color(0xFF3B82F6); // Light blue accent
  static const Color _warmBeige = Color(0xFFFEF7CD); // Paper-like beige
  static const Color _darkCharcoal = Color(0xFF1F2937); // Dark text color
  static const Color _softGray = Color(0xFF6B7280); // Subtitle gray
  static const Color _paperWhite = Color(0xFFFDFDF8); // Off-white paper

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.crimsonText().fontFamily, // Book-like serif font
      
      colorScheme: ColorScheme.light(
        primary: _primaryBookBlue,
        secondary: _secondaryOrange,
        tertiary: _accentLightBlue,
        surface: _paperWhite,
        onSurface: _darkCharcoal,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surfaceContainerHighest: _warmBeige,
        outline: _softGray.withOpacity(0.3),
        shadow: _darkCharcoal.withOpacity(0.1),
      ),

      // Text Theme with book-like typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.crimsonText(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: _darkCharcoal,
        ),
        displayMedium: GoogleFonts.crimsonText(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: _darkCharcoal,
        ),
        displaySmall: GoogleFonts.crimsonText(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: _darkCharcoal,
        ),
        headlineLarge: GoogleFonts.crimsonText(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _darkCharcoal,
        ),
        headlineMedium: GoogleFonts.crimsonText(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _darkCharcoal,
        ),
        headlineSmall: GoogleFonts.crimsonText(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _darkCharcoal,
        ),
        titleLarge: GoogleFonts.crimsonText(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: _darkCharcoal,
        ),
        titleMedium: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: _darkCharcoal,
        ),
        titleSmall: GoogleFonts.crimsonText(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: _darkCharcoal,
        ),
        bodyLarge: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: _darkCharcoal,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.crimsonText(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: _darkCharcoal,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.crimsonText(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: _softGray,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: _darkCharcoal,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: _darkCharcoal,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: _softGray,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _paperWhite,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _darkCharcoal,
        titleTextStyle: GoogleFonts.crimsonText(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _darkCharcoal,
        ),
        iconTheme: IconThemeData(color: _darkCharcoal),
      ),

      // Card Theme - Book page-like cards
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: _darkCharcoal.withOpacity(0.1),
        color: _paperWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _warmBeige.withOpacity(0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBookBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: _darkCharcoal.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _secondaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBookBlue,
          side: BorderSide(color: _primaryBookBlue.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _warmBeige.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _softGray.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _softGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryBookBlue, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: _softGray,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: _softGray.withOpacity(0.7),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _paperWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: _darkCharcoal.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.crimsonText(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _darkCharcoal,
        ),
        contentTextStyle: GoogleFonts.crimsonText(
          fontSize: 16,
          color: _darkCharcoal,
          height: 1.5,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _paperWhite,
        selectedItemColor: _primaryBookBlue,
        unselectedItemColor: _softGray,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: _primaryBookBlue,
        unselectedLabelColor: _softGray,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _primaryBookBlue,
              width: 3,
            ),
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _warmBeige,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _darkCharcoal,
        ),
        selectedColor: _primaryBookBlue.withOpacity(0.2),
        checkmarkColor: _primaryBookBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _secondaryOrange,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryBookBlue,
        linearTrackColor: _warmBeige,
        circularTrackColor: _warmBeige,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _softGray.withOpacity(0.2),
        thickness: 1,
        space: 20,
      ),
    );
  }

  // Dark theme for nighttime reading
  static ThemeData get darkTheme {
    const Color darkBg = Color(0xFF0F1419);
    const Color darkSurface = Color(0xFF1A1E23);
    const Color darkCard = Color(0xFF252A31);
    const Color darkText = Color(0xFFE5E7EB);
    const Color darkSecondary = Color(0xFF9CA3AF);

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.crimsonText().fontFamily,
      
      colorScheme: ColorScheme.dark(
        primary: _accentLightBlue,
        secondary: _secondaryOrange,
        tertiary: _primaryBookBlue,
        surface: darkSurface,
        onSurface: darkText,
        onPrimary: darkBg,
        onSecondary: darkBg,
        surfaceContainerHighest: darkCard,
        outline: darkSecondary.withOpacity(0.3),
        shadow: Colors.black.withOpacity(0.3),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.crimsonText(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: darkText,
        ),
        displayMedium: GoogleFonts.crimsonText(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: darkText,
        ),
        displaySmall: GoogleFonts.crimsonText(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: darkText,
        ),
        headlineLarge: GoogleFonts.crimsonText(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.crimsonText(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: darkText,
        ),
        headlineSmall: GoogleFonts.crimsonText(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: darkText,
        ),
        titleLarge: GoogleFonts.crimsonText(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: darkText,
        ),
        titleMedium: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: darkText,
        ),
        titleSmall: GoogleFonts.crimsonText(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: darkText,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.crimsonText(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: darkText,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.crimsonText(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: darkSecondary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: darkText,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: darkText,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: darkSecondary,
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: darkText,
        titleTextStyle: GoogleFonts.crimsonText(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        color: darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: darkSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentLightBlue,
          foregroundColor: darkBg,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _secondaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Add other dark theme properties as needed...
    );
  }
}
