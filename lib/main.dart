import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'home_page.dart';
import 'favorites_manager.dart';
import 'ui_helpers.dart'; // FontSizeController ንምርካብ ዝተወሰኸ
import 'utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

// ማእኸላይ ናይ ቴማ (Theme) መቆፃፃሪ መታን ዳርክ/ላይት ሞድ ብቐሊሉ ክቕየር
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Favorites Manager ምድላው
  await FavoritesManager().init();

  // ሓዱሽ ኣናሊቲክስ ሰርቪስ ምጅማር
  await AnalyticsService.init();

  // ፖርትሬት (Portrait) ጥራይ ንኽኸውን
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        // ንፎንት ሳይዝ ለውጢ ዝሰምዕ መቆፃፃሪ
        return ListenableBuilder(
          listenable: FontSizeController.multiplier,
          builder: (context, _) {
            return MaterialApp(
              title: 'መኣዲ ፀጋ',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: currentMode, // ብ ValueNotifier ዝቆፃፀር
              debugShowCheckedModeBanner: false,

              // ንመላእ ኣፕሊኬሽን (Global) ዘገልግል ናይ ፅሑፍ መለክዒ (Text Scaling)
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler:
                        TextScaler.linear(FontSizeController.multiplier.value),
                  ),
                  child: child!,
                );
              },

              home: const MeadiTsegaHomePage(),
            );
          },
        );
      },
    );
  }
}
