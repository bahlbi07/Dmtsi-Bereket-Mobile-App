// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Light Theme ---
// FIXED: Removed "yy" typo and invalid parameters 'background' and 'onBackground'
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.lightBlue,
  brightness: Brightness.light,
  surface: Colors.white,
  primary: Colors.blue.shade600,
  onPrimary: Colors.white,
  secondary: Colors.blueAccent,
  onSecondary: Colors.white,
  error: Colors.red.shade700,
  onError: Colors.white,
  onSurface: Colors.black87,
  background: const Color(0xFFF0F4F8),
);

final ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: lightColorScheme.surface, // Consider if this should be a solid color from app_colors
  fontFamily: GoogleFonts.notoSerifEthiopic().fontFamily,
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.primary,
    elevation: 2,
    titleTextStyle: GoogleFonts.notoSerifEthiopic( fontSize: 20, fontWeight: FontWeight.w600, color: lightColorScheme.onPrimary, ),
    iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
  ),
  // FIXED: Changed CardTheme to CardThemeData
  cardTheme: CardThemeData(
    elevation: 1.5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    color: Colors.white.withOpacity(0.70),
  ),
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: lightColorScheme.primary.withOpacity(0.8),
    collapsedIconColor: Colors.grey[700],
    textColor: lightColorScheme.primary,
    collapsedTextColor: Colors.grey[900],
    backgroundColor: Colors.white.withOpacity(0.3),
    collapsedBackgroundColor: Colors.transparent,
    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
    childrenPadding: const EdgeInsets.only(left: 32.0, bottom: 8.0, right: 16.0),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white.withOpacity(0.9),
    selectedItemColor: lightColorScheme.primary,
    unselectedItemColor: Colors.grey[700],
    selectedLabelStyle: GoogleFonts.notoSerifEthiopic(fontWeight: FontWeight.w500, fontSize: 11.5),
    unselectedLabelStyle: GoogleFonts.notoSerifEthiopic(fontSize: 11),
    elevation: 4,
    type: BottomNavigationBarType.fixed,
  ),
  textTheme: GoogleFonts.notoSerifEthiopicTextTheme().copyWith( // Apply base TextTheme here
    headlineSmall: GoogleFonts.notoSerifEthiopic( fontSize: 18, fontWeight: FontWeight.w600, color: lightColorScheme.primary.withOpacity(0.95), ),
    bodyMedium: GoogleFonts.notoSerifEthiopic( fontSize: 16, color: Colors.grey[850], height: 1.55, fontWeight: FontWeight.w500, ),
    titleMedium: GoogleFonts.notoSerifEthiopic( fontSize: 16.5, fontWeight: FontWeight.w600, color: Colors.black87, ),
    titleSmall: GoogleFonts.notoSerifEthiopic( fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[700], ),
    bodyLarge: GoogleFonts.notoSerifEthiopic( fontSize: 19.5, color: Colors.black87, height: 1.7, fontWeight: FontWeight.w500, ),
    labelLarge: GoogleFonts.notoSerifEthiopic( fontWeight: FontWeight.w600, fontSize: 16, color: lightColorScheme.onPrimary, )
  ).apply(
     bodyColor: lightColorScheme.onSurface,
     displayColor: lightColorScheme.onSurface,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder( borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none, ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    hintStyle: GoogleFonts.notoSerifEthiopic(color: Colors.grey[600]),
    prefixIconColor: lightColorScheme.primary.withOpacity(0.8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData( style: ElevatedButton.styleFrom( backgroundColor: lightColorScheme.primary, foregroundColor: lightColorScheme.onPrimary, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), textStyle: GoogleFonts.notoSerifEthiopic(fontSize: 16, fontWeight: FontWeight.w600, color: lightColorScheme.onPrimary), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20), ), ) ),
  iconTheme: IconThemeData(color: lightColorScheme.primary),
  progressIndicatorTheme: ProgressIndicatorThemeData( color: lightColorScheme.primary, ),
  sliderTheme: SliderThemeData( activeTrackColor: lightColorScheme.primary, inactiveTrackColor: lightColorScheme.primary.withOpacity(0.3), thumbColor: lightColorScheme.primary, overlayColor: lightColorScheme.primary.withOpacity(0.2), valueIndicatorColor: lightColorScheme.secondary, valueIndicatorTextStyle: TextStyle(color: lightColorScheme.onSecondary) ),
  dividerTheme: DividerThemeData( color: Colors.grey[400], thickness: 1, space: 24, indent: 16, endIndent: 16, ),
  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    dense: true,
    horizontalTitleGap: 12.0,
    iconColor: lightColorScheme.primary.withOpacity(0.8),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);


// --- Dark Theme ---
final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue.shade700,
  brightness: Brightness.dark,
  surface: const Color(0xFF1E1E1E), // ቁሩብ ዝቐለለ ፀሊም
  primary: Colors.lightBlueAccent,
  onPrimary: Colors.black87,
  onSurface: Colors.white.withOpacity(0.9),
  error: Colors.redAccent.shade100,
  onError: Colors.black,
  background: const Color(0xFF121212),
);

final ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,
    fontFamily: GoogleFonts.notoSerifEthiopic().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface.withOpacity(0.8),
      elevation: 0,
      titleTextStyle: GoogleFonts.notoSerifEthiopic( fontSize: 20, fontWeight: FontWeight.w600, color: darkColorScheme.onSurface, ),
      iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    ),
    // FIXED: Changed CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: darkColorScheme.surface.withOpacity(0.7),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: darkColorScheme.primary.withOpacity(0.8),
      collapsedIconColor: Colors.grey[400],
      textColor: darkColorScheme.primary,
      collapsedTextColor: Colors.grey[300],
      backgroundColor: darkColorScheme.surface.withOpacity(0.5),
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      childrenPadding: const EdgeInsets.only(left: 32.0, bottom: 8.0, right: 16.0),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black.withOpacity(0.7),
      selectedItemColor: darkColorScheme.primary,
      unselectedItemColor: Colors.grey[400],
      selectedLabelStyle: GoogleFonts.notoSerifEthiopic(fontWeight: FontWeight.w500, fontSize: 11.5),
      unselectedLabelStyle: GoogleFonts.notoSerifEthiopic(fontSize: 11),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: GoogleFonts.notoSerifEthiopicTextTheme().copyWith( // Apply base TextTheme here
      headlineSmall: GoogleFonts.notoSerifEthiopic(fontSize: 18, fontWeight: FontWeight.w600, color: darkColorScheme.primary),
      bodyMedium: GoogleFonts.notoSerifEthiopic(fontSize: 16, color: Colors.grey[300], height: 1.55, fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.notoSerifEthiopic(fontSize: 16.5, fontWeight: FontWeight.w600, color: Colors.grey[100]),
      titleSmall: GoogleFonts.notoSerifEthiopic(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[400]),
      bodyLarge: GoogleFonts.notoSerifEthiopic(fontSize: 19.5, color: Colors.grey[200], height: 1.7, fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.notoSerifEthiopic(fontWeight: FontWeight.w600, fontSize: 16, color: darkColorScheme.onPrimary),
    ).apply( bodyColor: darkColorScheme.onSurface, displayColor: darkColorScheme.onSurface, ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder( borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none, ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      hintStyle: GoogleFonts.notoSerifEthiopic(color: Colors.grey[500]),
      prefixIconColor: darkColorScheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData( style: ElevatedButton.styleFrom( backgroundColor: darkColorScheme.primary,
     foregroundColor: darkColorScheme.onPrimary,
     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), textStyle: GoogleFonts.notoSerifEthiopic(fontSize: 16, fontWeight: FontWeight.w600, color: darkColorScheme.onPrimary), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20), ), ) ),
    iconTheme: IconThemeData(color: darkColorScheme.primary),
    progressIndicatorTheme: ProgressIndicatorThemeData( color: darkColorScheme.primary, ),
    sliderTheme: SliderThemeData(
        activeTrackColor: darkColorScheme.primary,
        inactiveTrackColor: darkColorScheme.primary.withOpacity(0.3),
        thumbColor: darkColorScheme.primary,
        overlayColor: darkColorScheme.primary.withOpacity(0.2),
        valueIndicatorColor: darkColorScheme.secondary,
        valueIndicatorTextStyle: TextStyle(color: darkColorScheme.onSecondary)
    ),
    dividerTheme: DividerThemeData( color: Colors.grey[700], thickness: 1, space: 24, indent: 16, endIndent: 16, ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      dense: true,
      horizontalTitleGap: 12.0,
      iconColor: darkColorScheme.primary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );