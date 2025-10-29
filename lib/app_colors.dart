// lib/app_colors.dart
import 'package:flutter/material.dart';

// --- ቀንዲ ናይ ኣፕሊኬሽን ሕብርታት ---

/// ን AppBar ከምኡ'ውን ን ቀንዲ UI ዝኸውን ሰማያዊ ሕብሪ።
const Color primaryAppBarColor = Color(0xFF2196F3);

/// ን ኣይኮናት ናይ ድሮወር (Drawer) ዝኸውን ሕብሪ።
const Color drawerIconColor = Color.fromARGB(255, 31, 114, 221);

/// ን ኣይኮናት ናይ ቀንዲ ገፅ (Home Screen Grid) ዝኸውን ሕብሪ።
const Color homeGridIconColor = Color.fromARGB(255, 40, 149, 233);

/// ን ናቪጌሽን ባር ናይ ኩፐርቲኖ (iOS style) ዝኸውን ሕብሪ።
const Color cupertinoNavBarColor = Color.fromRGBO(249, 249, 249, 0.98);

/// ን ገፅ ፀሎታት (Prayer Screen) ዝኸውን ቀሊል ሕብሪ።
const Color softIvory = Color(0xFFFFF4D5);


// --- ፓስቴል ግራድየንት (Pastel Gradient) ---

/// ንቐንዲ ናይ ኣፕሊኬሽን ባግራውንድ ዝጠቕሙ ቀለልቲ ሕብርታት (Pastel Colors)።
const Color softPeach = Color(0xFFFFE0B2);
const Color softRose = Color(0xFFF8BBD0);
const Color softSky = Color(0xFFB3E5FC);
const Color softLime = Color(0xFFDCEDC8);

/// ንኹሉ ባግራውንድ ናይ ኣፕሊኬሽን ዝኸውን ቋሚ ግራድየንት።
const LinearGradient refinedPastelGradient = LinearGradient(
  colors: [
    softPeach,
    softRose,
    softSky,
    softLime,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.35, 0.7, 1.0],
);


// --- ኣማራፂ ፓለታት (ንመፃኢ ክጠቕሙ ዝኽእሉ) ---

/// "ሞቕ ዝበለ ጀምበር ዕራርቦ" ዝብል ናይ ሕብሪ ንድፊ (Palette)።
const Map<String, Color> sunsetPalette = {
  'deepTerracotta': Color(0xFF8C4843),
  'burntOrange':    Color(0xFFD16045),
  'softGold':       Color(0xFFF0A868),
  'creamyWhite':    Color(0xFFFFF3E8),
};

/// ንባግራውንድ ዝኸውን ናይ ጀምበር ዕራርቦ ሕብርታት (Gradient)።
const LinearGradient sunsetGradient = LinearGradient(
  colors: [
    Color(0xFFD16045),
    Color(0xFFF0A868),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);