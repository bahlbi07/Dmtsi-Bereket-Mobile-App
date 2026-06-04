// lib/screens/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart'; // 🌟 ሓዱሽ መእተዊ

import '../custom_page_route.dart';
import '../ui_helpers.dart'; // FontSizeController ካብዚ ቦታ ንምምፃእ

// ንበይኖም ዝተፈጠሩ 4 ሓደስቲ ስክሪናት
import 'support_app_screen.dart';
import 'feedback_screen.dart';
import 'about_app_screen.dart';
import 'privacy_policy_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // 🌟 ሓዱሽ ተግባር፦ ብውሑስ መንገዲ ናብ Play Store መተግበሪ ናይ ምስዳድ ሎጂክ
  Future<void> _launchPlayStore(BuildContext context) async {
    const String packageName = 'com.BHLabs.catholicapp';
    final Uri playStoreUri = Uri.parse('market://details?id=$packageName');
    final Uri webUri =
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    try {
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ሊንክ ምኽፋት ኣይተኻእለን።',
                    style: TextStyle(fontFamily: 'Nyala', fontSize: 18),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showDisabledSnackbar(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.star_half_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'እዚ ሊንክ ንግዜኡ ተዓፅዩ ኣሎ።',
                style: TextStyle(fontFamily: 'Nyala', fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> menuSections = [
      {
        'title': 'ተግባራትን ርእይቶን',
        'items': [
          {
            'imagePath': 'assets/icons/financing.png', // Support
            'title': 'ነዚ ኣፕሊኬሽን ደግፉ',
            'onTap': () => Navigator.push(
                context,
                SlowCupertinoPageRoute(
                    builder: (context) => const SupportAppScreen())),
          },
          {
            'imagePath': 'assets/icons/star.png', // Play Store Rating
            'title': 'ኣብ Play Store ርእይቶ ሃቡ',
            'onTap': () => _launchPlayStore(context), // 🌟 ሓዱሽ ምትእስሳር
          },
          {
            'imagePath': 'assets/icons/review.png', // Feedback
            'title': 'ርእይቶ ወይ ሓሳብ ስደዱ',
            'onTap': () => Navigator.push(
                context,
                SlowCupertinoPageRoute(
                    builder: (context) => const FeedbackScreen())),
          },
        ],
      },
      {
        'title': 'ሓበሬታን ፖሊሲታትን',
        'items': [
          {
            'imagePath': 'assets/icons/app1.png', // About App
            'title': 'ብዛዕባ`ዚ ኣፕሊኬሽን',
            'onTap': () => Navigator.push(
                context,
                SlowCupertinoPageRoute(
                    builder: (context) => const AboutAppScreen())),
          },
          {
            'imagePath': 'assets/icons/insurance.png', // Privacy Policy
            'title': 'ፖሊሲ ውልቃዊ-ሓበሬታ',
            'onTap': () => Navigator.push(
                context,
                SlowCupertinoPageRoute(
                    builder: (context) => const PrivacyPolicyScreen())),
          },
        ]
      }
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Back Chevron Appbar with 38.0 Padding
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
                    'ዝርዝር (Menu)',
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
              child: ListenableBuilder(
                listenable: FontSizeController.multiplier,
                builder: (context, child) {
                  return AnimationLimiter(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(38.0, 10.0, 38.0, 80.0),
                      itemCount: menuSections.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: const SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _FontSizeAdjustmentCard(),
                              ),
                            ),
                          );
                        }

                        final section = menuSections[index - 1];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _MenuSectionCard(
                                title: section['title'],
                                items: section['items'],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ናይ ፎንት ሳይዝ መቆፃፀሪ ዘመናዊ ካርድ
class _FontSizeAdjustmentCard extends StatelessWidget {
  const _FontSizeAdjustmentCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: FontSizeController.multiplier,
      builder: (context, child) {
        final currentMultiplier = FontSizeController.multiplier.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
                child: Text(
                  'ናይ ፅሑፍ ዓቐን (Font Size)',
                  style: TextStyle(
                    fontFamily: 'Nyala',
                    color: Color(0xFFC61B1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: currentMultiplier <= 0.8
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              FontSizeController.decrease();
                            },
                      icon: Icon(
                        Icons.remove_circle_outline_rounded,
                        size: 26,
                        color: currentMultiplier <= 0.8
                            ? Colors.grey
                            : const Color(0xFFC61B1B),
                      ),
                    ),
                    Text(
                      '${(currentMultiplier * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: 'Nyala',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: currentMultiplier >= 1.4
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              FontSizeController.increase();
                            },
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 26,
                        color: currentMultiplier >= 1.4
                            ? Colors.grey
                            : const Color(0xFFC61B1B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }
}

class _MenuSectionCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const _MenuSectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nyala',
                color: Color(0xFFC61B1B),
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 76,
                endIndent: 20,
                color: Colors.grey.withValues(alpha: 0.12)),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.grey.shade900 : const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        item['imagePath'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                title: Text(item['title'],
                    style: TextStyle(
                        fontFamily: 'Nyala',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white70 : Colors.black87)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
                onTap: () {
                  HapticFeedback.lightImpact();
                  item['onTap']();
                },
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
