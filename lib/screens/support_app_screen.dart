import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/analytics_service.dart';

class SupportAppScreen extends StatelessWidget {
  const SupportAppScreen({super.key});

  void _copyToClipboard(BuildContext context, String title, String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.mediumImpact();

    // ኮፒ ባንክ ንጥፈት ምምዝጋብ
    AnalyticsService.track('copy_bank_account', {
      'bank_name': title,
      'acc_number': value,
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title ቁፅሪ ሕሳብ ብዓወት ተገሊቢጡ (Copied)!',
          style: const TextStyle(fontFamily: 'Nyala', fontSize: 18),
        ),
        backgroundColor: const Color(0xFFC61B1B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🌟 ሓቀኛ ሓበሬታ ባህልቢ ሃይለ ደበሳይ ጥራይ ዝሓዘ ዝተመርፁ ባንክታት
    final List<Map<String, dynamic>> bankAccounts = [
      {
        'bankName': 'Commercial Bank of Ethiopia (CBE)',
        'shortName': 'CBE',
        'accNumber': '100062158997',
        'holderName': 'Bahlbi Haile Debesay',
        'gradientColors': [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
        'accentColor': const Color(0xFFFFEB3B),
      },
      {
        'bankName': 'telebirr (ቴሌብር)',
        'shortName': 'telebirr',
        'accNumber': '0985485550',
        'holderName': 'Bahlbi Haile Debesay',
        'gradientColors': [const Color(0xFF007EC3), const Color(0xFF00B0FF)],
        'accentColor': Colors.white,
      },
      {
        'bankName': 'Bank of Abyssinia (BoA)',
        'shortName': 'BoA',
        'accNumber': '136075586',
        'holderName': 'Bahlbi Haile Debesay',
        'gradientColors': [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)],
        'accentColor': const Color(0xFFFFD700), // Gold
      },
      {
        'bankName': 'Awash Bank',
        'shortName': 'Awash',
        'accNumber': '013201156136400',
        'holderName': 'Bahlbi Haile Debesay',
        'gradientColors': [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
        'accentColor': const Color(0xFFFFB300), // Amber
      }
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'ኣገልግሎትና ይደግፉ',
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // 🌟 ዘመናዊ መእተዊ ካርድ ምስ ልስሉስ ሻዶውን ዲዛይንን
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC61B1B)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFC61B1B),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "ነዚ ኣፕሊኬሽን ምምዕባልን ስራሕቲ ስብከተ ወንጌል ንምስፋሕን ዝግበር ዝኾነ ይኹን መንፈሳዊ ሓገዝን ድጋፍን ምስጋናና ልዑል እዩ።",
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 18,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🌟 ዘመናዊ ዲጂታል ብራንድ ካርታታት (Digital Brand Cards Grid/List)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bankAccounts.length,
                      itemBuilder: (context, index) {
                        final acc = bankAccounts[index];
                        final colors = acc['gradientColors'] as List<Color>;
                        final accentColor = acc['accentColor'] as Color;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors[0].withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                // subtle background patterns/circles for credit card look
                                Positioned(
                                  right: -20,
                                  top: -20,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Colors.white.withValues(alpha: 0.05),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Bank Badge Logo
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              acc['shortName']!,
                                              style: TextStyle(
                                                color: accentColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                          ),
                                          // Quick Copy Icon Button on top right
                                          IconButton(
                                            icon: const Icon(
                                              Icons.copy_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            onPressed: () => _copyToClipboard(
                                              context,
                                              acc['bankName']!,
                                              acc['accNumber']!,
                                            ),
                                            tooltip: 'Copy Account Number',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.white
                                                  .withValues(alpha: 0.1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Bank Name (Full)
                                      Text(
                                        acc['bankName']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Account Number formatted like credit card numbers
                                      Text(
                                        acc['accNumber']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Divider(
                                        color: Colors.white12,
                                        height: 1,
                                      ),
                                      const SizedBox(height: 12),
                                      // Card Holder Name
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'CARDHOLDER NAME',
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                acc['holderName']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Nyala',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Mini Wi-Fi contactless style icon for styling
                                          const Icon(
                                            Icons.wifi_rounded,
                                            color: Colors.white30,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
