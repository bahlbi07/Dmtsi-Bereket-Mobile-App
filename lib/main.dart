// lib/main.dart

import 'package:flutter/material.dart';
import 'app_theme.dart'; // <<< ሓድሽ፡ ነቲ ናይ ቴማ ፋይል ንፅውዖ
import 'home_page.dart';
import 'favorites_manager.dart'; // <<< ሓድሽ፡ ን Favorites Manager ንፅውዖ

Future<void> main() async { // <<< ተለዊጡ፡ ን Favorites init ንምግባር
  WidgetsFlutterBinding.ensureInitialized();
  
  // <<< ሓድሽ፡ ነቲ Favorites Manager ኣብ መጀመርታ ንምድላው
  await FavoritesManager().init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'መኣዲ ፀጋ',
      // <<< እዚ ክፍል ተለዊጡ >>>
      theme: lightTheme, // ን Light Mode ዝኸውን ቴማ
      darkTheme: darkTheme, // ን Dark Mode ዝኸውን ቴማ
      themeMode: ThemeMode.system, // ነቲ ናይ ስልኪ ሴቲንግ ይኽተል
      debugShowCheckedModeBanner: false,
      home: const DmtsiBereketHomePage(),
    );
  }
}