import 'package:flutter/material.dart';
import 'app_colors.dart';

// --- Light Theme ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryRed,
  scaffoldBackgroundColor: lightBackground,
  fontFamily: 'Nyala', // <<< GoogleFonts ጠፊኡ Nyala ኣትዩ
  colorScheme: const ColorScheme.light(
    primary: primaryRed,
    secondary: primaryRed,
    surface: lightCardColor,
    onPrimary: Colors.white,
    onSurface: lightTextColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBackground,
    foregroundColor: lightTextColor,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: lightTextColor),
    titleTextStyle: TextStyle(
      fontFamily: 'Nyala',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: lightTextColor,
    ),
  ),
  cardTheme: CardThemeData(
    color: lightCardColor,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  textTheme: const TextTheme(
    headlineSmall:
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryRed),
    titleLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: lightTextColor),
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: lightTextColor),
    bodyLarge: TextStyle(fontSize: 20, color: lightTextColor, height: 1.6),
    bodyMedium: TextStyle(fontSize: 18, color: lightTextColor, height: 1.5),
    bodySmall: TextStyle(fontSize: 16, color: Colors.grey),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lightCardColor,
    selectedItemColor: primaryRed,
    unselectedItemColor: Colors.grey.shade500,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: const TextStyle(
        fontFamily: 'Nyala', fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: const TextStyle(fontFamily: 'Nyala', fontSize: 12),
  ),
);

// --- Dark Theme ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryRed,
  scaffoldBackgroundColor: darkBackground,
  fontFamily: 'Nyala', // <<< GoogleFonts ጠፊኡ Nyala ኣትዩ
  colorScheme: const ColorScheme.dark(
    primary: primaryRed,
    secondary: primaryRed,
    surface: darkCardColor,
    onPrimary: Colors.white,
    onSurface: darkTextColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    foregroundColor: darkTextColor,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: darkTextColor),
    titleTextStyle: TextStyle(
      fontFamily: 'Nyala',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: darkTextColor,
    ),
  ),
  cardTheme: CardThemeData(
    color: darkCardColor,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  textTheme: const TextTheme(
    headlineSmall:
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryRed),
    titleLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: darkTextColor),
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: darkTextColor),
    bodyLarge: TextStyle(fontSize: 20, color: darkTextColor, height: 1.6),
    bodyMedium: TextStyle(fontSize: 18, color: darkTextColor, height: 1.5),
    bodySmall: TextStyle(fontSize: 16, color: Colors.grey),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkCardColor,
    selectedItemColor: primaryRed,
    unselectedItemColor: Colors.grey.shade600,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: const TextStyle(
        fontFamily: 'Nyala', fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: const TextStyle(fontFamily: 'Nyala', fontSize: 12),
  ),
);
