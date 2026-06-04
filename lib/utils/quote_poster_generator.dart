import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../home_page.dart'; // RotatingRosarySpinner ንምጥቃም ዝተገበረ ኢምፖርት
import 'analytics_service.dart'; // ሓዱሽ ሰርቪስ

class QuotePosterGenerator {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// ጥቅሲ ተቐቢሉ ፖስተር ምስሊ ዝሰርሕን ብግልፂ ዝተዓቀበሉ ቦታ ዝሕብርን ፍሉይ ፈንክሽን
  static Future<void> generateAndShare({
    required BuildContext context,
    required String quote,
    required String author,
    required String topic,
  }) async {
    // 1. ሎዲንግ ፖፕ-ኣፕ ምስቲ ዝዘውር ናይ መቁፀርያ ስፒነር (Rotating Rosary Spinner ካብ ሆምፔጅ ዝተወሰደ)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // እቲ ካብ ሆምፔጅ ዝመፀ ዝዘውር ናይ መቁፀርያ ምልክት
              RotatingRosarySpinner(
                size: 110,
                color: Color(0xFFC61B1B), // primaryRed
              ),
              SizedBox(height: 20),
              Text(
                'ጥቅሲ ብምስሊ መልክዕ ይስራሕ ኣሎ...',
                style: TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );

    try {
      String cleanedQuote = quote.trim();

      // ካብቶም 40 ዲዛይናት ብዘይ ደጋጋሚ ሕብርታት ብራንደም ምምራፅ
      int randomStyleIndex = math.Random().nextInt(40);

      // 🛡️ ንናይ View.of() ፀገም ንምፈታሕ ናይ ኮንቴክስት ዳታታት ኣቐዲምና ንወስድ
      final mediaQueryData = MediaQuery.of(context);
      final themeData = Theme.of(context);

      // ምስሊ ጀነሬት ምግባር (ብቀጥታ ካብ ዩዘር ኮንቴክስት ፍፁም ጌጋ ንኸይፍጠር ጌርናዮ ኣለና)
      final Uint8List? imageBytes =
          await _screenshotController.captureFromLongWidget(
        _buildPosterCanvas(
          cleanedQuote,
          author,
          topic,
          randomStyleIndex,
          mediaQueryData,
          themeData,
        ),
        context: context,
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 350),
      );

      if (imageBytes == null) throw Exception("ምስሊ ክስራሕ ኣይከኣለን።");

      // 2. ምስሉ ዝዕቀበሉ ትኽክለኛ ቦታ መምረፂ ሎጂክ (Safe dynamic filename with sanitized title & timestamp)
      File file;
      String saveLocationMsg;

      // ንስም እቲ ፋይል ካብ ፍሉያት ምልክታት ነፃ ምግባርን ፍሉይ ታይምስታምፕ ምጥቃምን
      final safeTitle = topic
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      try {
        // መጀመርታ ኣብ Downloads/መኣዲ ጸጋ ፎልደር ንምዕቃብ ንፍትን
        final publicDir = Directory('/storage/emulated/0/Download/MeadiTsega');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }
        file = File('${publicDir.path}/MeadiTsega_${safeTitle}_$timestamp.png');
        await file.writeAsBytes(imageBytes);
        saveLocationMsg = 'ምስሊ ተዓቂቡ ኣሎ (Downloads/MeadiTsega)';
      } catch (e) {
        // ናይ ፍቃድ ፀገም እንተሃሊዩ ብዘይ ፍቃድ ምስሊ ሼር ንምግባር ኣብ ግዝያዊ ኬሽ ይዕቅቦ
        final tempDir = await getTemporaryDirectory();
        file = File('${tempDir.path}/MeadiTsega_${safeTitle}_$timestamp.png');
        await file.writeAsBytes(imageBytes);
        saveLocationMsg = 'ምስሊ ብዓወት ተዳልዩ ኣሎ (ግዝያዊ ማህደር)';
      }

      // ሎዲንግ መዕፀዊ
      if (context.mounted) Navigator.pop(context);

      // 3. ምስሊ ዝተዓቀበሉ ቦታ ብትኽክል ዝሕብር SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.folder_shared_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    saveLocationMsg,
                    style: const TextStyle(fontFamily: 'Nyala', fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC61B1B), // primary red
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      // 4. ሼር ምግባር
      final xFile = XFile(file.path);

      // ሼር ንጥፈት ብዓወት ምምዝጋብ
      AnalyticsService.track('poster_shared', {
        'topic': topic,
        'author': author ?? 'Unknown',
      });

      await Share.shareXFiles(
        [xFile],
        text: '"$cleanedQuote"\n- $author (ካብ መኣዲ ጸጋ ኣፕሊኬሽን)',
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      // ጌጋ እንተሃልዩ ምምዝጋብ
      AnalyticsService.track('poster_failed', {
        'topic': topic,
        'reason': e.toString(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ጌጋ ተፈጢሩ: $e',
                style: const TextStyle(fontFamily: 'Nyala')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 40 ፍሉያት መንፈሳውያን ንድፍታት (Gradients & Custom PNG Assets)
  /// እዚ ዊጀት እዚ ንናይ View/MediaQuery ፀገማት ብዘላቕነት ንምፍታሕ ካብ ንጡፍ ኣፕሊኬሽን ዳታታት ይወስድ።
  static Widget _buildPosterCanvas(
    String content,
    String author,
    String topic,
    int styleIndex,
    MediaQueryData mediaQuery,
    ThemeData theme,
  ) {
    // 40 ፍሉያት ጥምረታት
    final List<Map<String, dynamic>> posterStyles = [
      {
        'grad': [const Color(0xFFFDFBF7), const Color(0xFFF4EDE2)],
        'accent': const Color(0xFF5D4037),
        'symbol': 'rosary.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFFFFDF0), const Color(0xFFF2E3C6)],
        'accent': const Color(0xFFB58925),
        'symbol': 'cross.png',
        'isAsset': true,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF4A0E17), const Color(0xFF1E0307)],
        'accent': const Color(0xFFDCAE96),
        'symbol': 'holy-ghost.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF1A237E), const Color(0xFF0D1240)],
        'accent': const Color(0xFFE0F2F1),
        'symbol': 'church.png',
        'isAsset': true,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFF4F9F4), const Color(0xFFD6E4D6)],
        'accent': const Color(0xFF2E5A2E),
        'symbol': 'holy-ghost.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFFFFFFF), const Color(0xFFECEFF1)],
        'accent': const Color(0xFF263238),
        'symbol': 'christianity.png',
        'isAsset': true,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFFF8E1), const Color(0xFFFFD54F)],
        'accent': const Color(0xFF5D4037),
        'symbol': 'praying.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF880E4F), const Color(0xFF31021A)],
        'accent': const Color(0xFFFFCDD2),
        'symbol': 'holy-chalice.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)],
        'accent': const Color(0xFF0277BD),
        'symbol': 'holy-ghost.png',
        'isAsset': true,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF2D241E), const Color(0xFF1A120E)],
        'accent': const Color(0xFFE6C594),
        'symbol': 'cross.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF004D40), const Color(0xFF00251A)],
        'accent': const Color(0xFF80CBC4),
        'symbol': '⛪',
        'isAsset': false,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFFF3E0), const Color(0xFFFFCDD2)],
        'accent': const Color(0xFFB71C1C),
        'symbol': '🕊️',
        'isAsset': false,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)],
        'accent': const Color(0xFF4527A0),
        'symbol': 'rosary.png',
        'isAsset': true,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF37474F), const Color(0xFF21272B)],
        'accent': const Color(0xFFECEFF1),
        'symbol': 'virgen-de-guadalupe.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFF8BBD0), const Color(0xFFE1BEE7)],
        'accent': const Color(0xFF880E4F),
        'symbol': 'guadaloupe.png',
        'isAsset': true,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFBE9E7), const Color(0xFFFFCC80)],
        'accent': const Color(0xFFD84315),
        'symbol': '🕯️',
        'isAsset': false,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFE0F7FA), const Color(0xFF80DEEA)],
        'accent': const Color(0xFF006064),
        'symbol': '🕊️',
        'isAsset': false,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFD7CCC8), const Color(0xFFA1887F)],
        'accent': const Color(0xFF4E342E),
        'symbol': 'cross.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF4A148C), const Color(0xFF21004A)],
        'accent': const Color(0xFFE1BEE7),
        'symbol': '⛪',
        'isAsset': false,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFFE0B2), const Color(0xFFFFB74D)],
        'accent': const Color(0xFFE65100),
        'symbol': '🕯️',
        'isAsset': false,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
        'accent': const Color(0xFF004D40),
        'symbol': '🕊️',
        'isAsset': false,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF1C3AA9), const Color(0xFF001150)],
        'accent': const Color(0xFF9FA8DA),
        'symbol': 'church.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFFFF9C4), const Color(0xFFFFF59D)],
        'accent': const Color(0xFFF57F17),
        'symbol': 'rosary.png',
        'isAsset': true,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF333333), const Color(0xFF111111)],
        'accent': const Color(0xFFE0E0E0),
        'symbol': 'cross.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFEFEBE9), const Color(0xFFD7CCC8)],
        'accent': const Color(0xFF5D4037),
        'symbol': '🕯️',
        'isAsset': false,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
        'accent': const Color(0xFF6A1B9A),
        'symbol': 'holy-ghost.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
        'accent': const Color(0xFF2E7D32),
        'symbol': '🕊️',
        'isAsset': false,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFFFDE7), const Color(0xFFFFF9C4)],
        'accent': const Color(0xFFFBC02D),
        'symbol': '🕯️',
        'isAsset': false,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF311B92), const Color(0xFF12005E)],
        'accent': const Color(0xFFD1C4E9),
        'symbol': '⛪',
        'isAsset': false,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFFEB3B), const Color(0xFFFF9800)],
        'accent': const Color(0xFF3E2723),
        'symbol': '🕯️',
        'isAsset': false,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF00695C), const Color(0xFF004D40)],
        'accent': const Color(0xFFE0F2F1),
        'symbol': 'cross.png',
        'isAsset': true,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
        'accent': const Color(0xFF424242),
        'symbol': 'church.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF5C0632), const Color(0xFF210011)],
        'accent': const Color(0xFFFFE0B2),
        'symbol': 'holy-chalice.png',
        'isAsset': true,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)],
        'accent': const Color(0xFFFF6F00),
        'symbol': 'praying.png',
        'isAsset': true,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFF1B5E20), const Color(0xFF002200)],
        'accent': const Color(0xFFA5D6A7),
        'symbol': 'church.png',
        'isAsset': true,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFFB2EBF2), const Color(0xFF80DEEA)],
        'accent': const Color(0xFF00796B),
        'symbol': '🕊️',
        'isAsset': false,
        'isDark': false,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFFFAB91), const Color(0xFFE64A19)],
        'accent': const Color(0xFFFFFFFF),
        'symbol': '✝️',
        'isAsset': false,
        'isDark': true,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF4A148C), const Color(0xFF010101)],
        'accent': const Color(0xFFE1BEE7),
        'symbol': 'cross.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
      {
        'grad': [const Color(0xFFFFE082), const Color(0xFFFFB300)],
        'accent': const Color(0xFF4E342E),
        'symbol': '🕯️',
        'isAsset': false,
        'isDark': false,
        'font': 'sans'
      },
      {
        'grad': [const Color(0xFF8D6E63), const Color(0xFF4E342E)],
        'accent': const Color(0xFFFFF3E0),
        'symbol': 'christianity.png',
        'isAsset': true,
        'isDark': true,
        'font': 'serif'
      },
    ];

    final style = posterStyles[styleIndex];
    final List<Color> colors = style['grad'];
    final Color accentColor = style['accent'];
    final String symbol = style['symbol'];
    final bool isAsset = style['isAsset'];
    final bool isDark = style['isDark'];
    final String fontTheme = style['font'];

    // 🛡️ ንናይ View.of() ፀገም ብዘላቕነት ንምክልኻል ንጡፍ ኮንቴክስት ዳታታት ኢንጀክት ንገብር
    return MediaQuery(
      data: mediaQuery,
      child: Theme(
        data: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 600,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Watermark Logo with errorBuilder fallback
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.04,
                        child: isAsset
                            ? Padding(
                                padding: const EdgeInsets.all(80.0),
                                child: Image.asset(
                                  'assets/icons/$symbol',
                                  fit: BoxFit.contain,
                                  color: accentColor,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox
                                        .shrink(); // ምስሊ እንተዘይሃልዩ ባዶ ይግበሮ
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  symbol,
                                  style: const TextStyle(fontSize: 350),
                                ),
                              ),
                      ),
                    ),

                    // Main Content Column
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Symbol with errorBuilder fallback to prevent crash
                          isAsset
                              ? Image.asset(
                                  'assets/icons/$symbol',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.church,
                                      color: accentColor,
                                      size: 80,
                                    );
                                  },
                                )
                              : Text(
                                  symbol,
                                  style: const TextStyle(fontSize: 65),
                                ),
                          const SizedBox(height: 12),
                          Text(
                            topic,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: accentColor.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100),
                            child: Container(
                              height: 2,
                              color: accentColor.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 35),

                          // Quotes Card Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.45)
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: accentColor.withOpacity(0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  color: accentColor.withOpacity(0.25),
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                // ✍️ ዝተመሓየሸ ጎልሂ ዝበለ ቦልድ (FontWeight.w900) ጥቅሲ
                                Text(
                                  '"$content"',
                                  style: fontTheme == 'serif'
                                      ? GoogleFonts.notoSerifEthiopic(
                                          fontSize:
                                              content.length > 200 ? 21 : 26,
                                          height: 1.7,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.95)
                                              : Colors.black87,
                                        )
                                      : GoogleFonts.notoSansEthiopic(
                                          fontSize:
                                              content.length > 200 ? 21 : 26,
                                          height: 1.7,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.95)
                                              : Colors.black87,
                                        ),
                                ),
                                const SizedBox(height: 30),

                                // 🎨 ናይቲ ቅዱስ ሽም ብጣዕሚ ማራኺ ብዝኾነ ቦክስ ዲዛይን ዝተሰርሐ
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.35),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      '- $author',
                                      style: GoogleFonts.notoSerifEthiopic(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),

                          // App Branding Footer with errorBuilder & constrained layout to prevent layout crashes
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 🛡️ ErrorBuilder prevents RIGHT OVERFLOWED crashes if assets aren't registered yet in pubspec
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8), // ነቲ ሎጎ ዙርያኡ ፅቡቕ ቅርፂ (Rounded) ንምሃብ
                                    child: Image.asset(
                                      'assets/app_logo.jpg', // <== ነቲ ትኽክለኛ ናይ ኣፕሊኬሽን ሎጎ ንጥቀም
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover, // እቲ ሎጎ ሙሉእ ንሙሉእ ክሽፍን
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.church,
                                          color: Color(0xFFC61B1B),
                                          size: 32,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "መኣዲ ጸጋ",
                                      style: TextStyle(
                                        fontFamily: 'Nyala',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC61B1B),
                                      ),
                                    ),
                                    Text(
                                      "መንፈሳዊ ጥቅስታት መተግበሪ",
                                      style: TextStyle(
                                        fontFamily: 'Nyala',
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
