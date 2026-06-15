import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class OfflineAdWidget extends StatefulWidget {
  const OfflineAdWidget({super.key});

  @override
  State<OfflineAdWidget> createState() => _OfflineAdWidgetState();
}

class _OfflineAdWidgetState extends State<OfflineAdWidget> {
  int _currentSlide = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        setState(() {
          _currentSlide = (_currentSlide + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleAction(
      BuildContext context, Future<void> Function() action) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "ናይ ኢንተርኔት ኮኔክሽን የብልኩምን! በጃኹም ኮኔክሽን ኣብርሁ።",
              style:
                  TextStyle(fontFamily: 'Nyala', fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFC61B1B),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      await action();
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? const Color(0xFF1C1814) : Colors.white;
    final Color borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final Color textPrimaryColor =
        isDark ? Colors.white : const Color(0xFF2B2418);
    final Color textSecondaryColor =
        isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        switch (_currentSlide) {
          case 0:
            _handleAction(
                context,
                () => _launchURL(
                    'https://play.google.com/store/apps/details?id=com.BHLabs.mezmur_app'));
            break;
          case 1:
            _handleAction(
                context,
                () => _launchURL(
                    'https://play.google.com/store/apps/details?id=com.BHLabs.catholicapp'));
            break;
          case 2:
            _handleAction(context, () async {
              await Share.share(
                "ነዛ መኣዲ ጸጋ ካቶሊካዊት ኣፕሊኬሽን ካብ Play Store ኣውሪድኩም ተጠቐሙላ! https://play.google.com/store/apps/details?id=com.BHLabs.catholicapp",
              );
            });
            break;
          case 3:
            _handleAction(
                context, () => _launchURL('https://t.me/CatholicSpiritialApp'));
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildSlideContent(
              _currentSlide, textPrimaryColor, textSecondaryColor, isDark),
        ),
      ),
    );
  }

  Widget _buildSlideContent(
      int slideIndex, Color primaryColor, Color secondaryColor, bool isDark) {
    switch (slideIndex) {
      case 0:
        return Row(
          key: const ValueKey(0),
          children: [
            // 🌟 ናይ «ድምጸ በረኸት» ሓቀኛ ሎጎ ምስሊ (PNG) 🌟
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/dmtse_bereket.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFFC61B1B).withOpacity(0.2),
                    child: const Icon(Icons.install_mobile_rounded,
                        color: Color(0xFFC61B1B)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "መሓዛ መተግበሪና «ድምጸ በረኸት»",
                        style: TextStyle(
                          fontFamily: 'Nyala',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "ኣውርድ",
                          style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ልዕሊ 1040 ዝኾኑ መንፈሳዊ መዛሙር ብግጥሚ ዝቀረበሉ መተግበሪ",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Row(
          key: const ValueKey(1),
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ደግፉና (Rate App) ⭐️",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "በጃኹም 5 ኮከብ ብምሃብ ኣብ Play Store ደግፉና!",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Row(
          key: const ValueKey(2),
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.share_rounded, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ኣካፍሉ (Share App)",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ነዛ ኣፕሊኬሽን ንኣዕሩኽኩም ብምክፋል ኣገልግሎት ኣስፍሑ!",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      case 3:
        return Row(
          key: const ValueKey(3),
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0088CC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.telegram,
                  color: Color(0xFF0088CC), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ናብ ቴሌግራም ቻነልና ተጸንበሩ 📢",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ዝተፈላለዩ ሓበሬታታት ንምርካብ ወግዓዊ ቻነልና ይቀላቐሉ",
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
