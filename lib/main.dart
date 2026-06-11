import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'home_page.dart';
import 'favorites_manager.dart';
import 'ui_helpers.dart'; // FontSizeController ንምርካብ ዝተወሰኸ
import 'utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FavoritesManager().init();
  await AnalyticsService.init();

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
        return ListenableBuilder(
          listenable: FontSizeController.multiplier,
          builder: (context, _) {
            return MaterialApp(
              title: 'መኣዲ ጸጋ',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: currentMode,
              debugShowCheckedModeBanner: false,
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
