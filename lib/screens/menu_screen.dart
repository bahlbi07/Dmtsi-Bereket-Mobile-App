// lib/screens/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../app_colors.dart';
import '../custom_page_route.dart';
import 'favorites_list_screen.dart';

// ==========================================================
// ==================== 1. Menu Screen ======================
// ==========================================================
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _showDisabledSnackbar(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'እዚ ሊንክ ንግዜኡ ተዓፅዩ ኣሎ።',
          style: GoogleFonts.notoSansEthiopic(),
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuSections = [
      {
        'title': 'ተግባራትን ርእይቶን',
        'items': [
          {
            'icon': Icons.favorite_rounded,
            'color': Colors.red.shade600,
            'title': 'ንዋየ-ልበይ (Favorites)',
            'onTap': () => Navigator.push(context,
                SlowCupertinoPageRoute(builder: (context) => const FavoritesCategoryScreen())),
          },
          {
            'icon': Icons.coffee_rounded,
            'color': Colors.brown.shade600,
            'title': 'ነዚ ኣፕሊኬሽን ደግፉ',
            'onTap': () => _showDisabledSnackbar(context),
          },
          {
            'icon': Icons.star_rounded,
            'color': Colors.amber.shade700,
            'title': 'ኣብ Play Store ርእይቶ ሃቡ',
            'onTap': () => _showDisabledSnackbar(context),
          },
          {
            'icon': Icons.feedback_rounded,
            'color': Colors.teal.shade600,
            'title': 'ርእይቶ ወይ ሓሳብ ስደዱ',
            'onTap': () => Navigator.push(context,
                SlowCupertinoPageRoute(builder: (context) => const FeedbackScreen())),
          },
        ],
      },
      {
        'title': 'ተኸታተሉና',
        'items': [
          {
            'icon': Icons.send_rounded,
            'color': Colors.blue.shade700,
            'title': 'ኣብ ቴሌግራም ርኸቡና',
            'onTap': () => _showDisabledSnackbar(context),
          },
          {
            'icon': Icons.play_circle_fill_rounded,
            'color': Colors.red.shade700,
            'title': 'ኣብ ዩትዩብ ሰብስክራይብ ግበሩ',
            'onTap': () => _showDisabledSnackbar(context),
          },
        ]
      },
      {
        'title': 'ሓበሬታን ፖሊሲታትን',
        'items': [
          {
            'icon': Icons.info_rounded,
            'title': 'ብዛዕባ`ዚ ኣፕሊኬሽን',
            'onTap': () => _showAboutAppDialog(context),
          },
          {
            'icon': Icons.privacy_tip_rounded,
            'title': 'ፖሊሲ ውልቃዊ-ሓበሬታ',
            'onTap': () => Navigator.push(context,
                SlowCupertinoPageRoute(builder: (context) => const PrivacyPolicyScreen())),
          },
        ]
      }
    ];

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
        itemCount: menuSections.length,
        itemBuilder: (context, index) {
          final section = menuSections[index];
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
  }

  void _showAboutAppDialog(BuildContext context) {
    final theme = Theme.of(context);
    const String appDisplayName = 'መኣዲ ፀጋ';
    final String currentYear = DateTime.now().year.toString();
    final String versionNumber = '1.1.0';

    showAboutDialog(
      context: context,
      applicationName: appDisplayName,
      applicationVersion: versionNumber,
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/others/jesus.jpg', width: 50, height: 50)),
      ),
      applicationLegalese: '© $currentYear BHD Apps',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            "እንኳዕ ናብ መኣዲ ፀጋ ብደሓን መፃእኩም። እዛ ኣፕሊኬሽን እዚኣ ንዓኹም፡ ምእመናን፡ ዝተፈላለዩ ናይ ትግርኛ ካቶሊካውያን መዛሙር፡ ፀሎታት፡ ታሪኽ ቅዱሳንን ብቐሊሉ ኣብ ኢድኩም ንምእታው ዝተዳለወት እያ።",
            style: GoogleFonts.notoSerifEthiopic(
                color: theme.textTheme.bodyMedium?.color, height: 1.6),
          ),
        ),
      ],
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
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 60, endIndent: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                leading: Icon(
                  item['icon'],
                  color: item['color'] ?? theme.colorScheme.primary,
                  size: 26,
                ),
                title: Text(item['title'], style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w600, fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  item['onTap']();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ================= 2. Privacy Policy Screen ===============
// ==========================================================
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionalBackgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6);
    
    final markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: GoogleFonts.notoSerif(
          textStyle: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
      h2: GoogleFonts.notoSans(
          textStyle: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, height: 1.8)),
      strong: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Scaffold(
      backgroundColor: professionalBackgroundColor,
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: MarkdownBody(
          data: _policyText,
          styleSheet: markdownStyleSheet,
          selectable: true,
        ),
      ),
    );
  }
}

// ==========================================================
// =================== 3. Feedback Screen ===================
// ==========================================================
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _feedbackType = 'General Feedback';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'dmtsibereketapp@gmail.com',
        query: 'subject=${Uri.encodeComponent('App Feedback: $_feedbackType')}&body=${Uri.encodeComponent(_feedbackController.text)}',
      );
      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          if (mounted) Navigator.pop(context);
        } else { throw 'Could not launch email client'; }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : refinedPastelGradient.colors.last,
      appBar: AppBar(
        title: Text('Send Feedback', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'ሓሳብኩም ወይ ርእይቶኹም ኣዝዩ የሐጉሰና! ዝኾነ ይኹን ፀገም ወይ መመሓየሺ ሓሳብ እንተለኩም፡ ኣብዚ ፅሒፍኩም ስደዱልና።',
                style: GoogleFonts.notoSerifEthiopic(fontSize: 17, height: 1.6),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                initialValue: _feedbackType,
                decoration: const InputDecoration(labelText: 'ዓይነት ርእይቶ'),
                items: <String>[ 'General Feedback', 'Bug Report', 'Feature Request', 'Lyrics Correction', 'Other' ]
                  .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>( value: value, child: Text(value)))
                  .toList(),
                onChanged: (String? newValue) => setState(() => _feedbackType = newValue!),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'ናትኩም ርእይቶ',
                  hintText: 'ነቲ ርእይቶኹም ኣብዚ ብዝርዝር ፅሓፉ...',
                  alignLabelWithHint: true,
                ),
                maxLines: 7,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'በጃኹም ርእይቶኹም ኣእትዉ።';
                  if (value.length < 10) return 'በጃኹም ሓንሳብ ብዝርዝр ግለፁልና።';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded),
                  label: Text('ብኢመይል ስደድ', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _policyText = '''
Privacy Policy for መኣዲ ፀጋ (Dmtsi Bereket) App
Last Updated: May 31, 2025

**1. Introduction**

Welcome to መኣዲ ፀጋ (Dmtse Bereket). This application is developed by BHD Apps. This Privacy Policy describes how your information is handled when you use the App. Our commitment is to provide you with a rich collection of Tigrinya Catholic hymns, information about singers, history and quotes of Catholic saints, various prayers including "Mebaeta Timhirti Kristos" for children, with regular updates, while respecting your privacy.
This App is designed to function primarily offline.

**2. Information We Collect**

We are committed to user privacy. The መኣዲ ፀጋ App DOES NOT collect any Personally Identifiable Information (PII) from its users. This includes, but is not limited to:
Your name, email address, physical address, or phone number.
Your device identifiers (like IMEI, Advertising ID, etc.).
Your precise or approximate location data.
Account creation is not required to use the App.
The only data that might be stored locally on your device through the App's functionality is:
Search History: If you use the search feature, your search terms may be stored locally on your device using SharedPreferences to improve your future search experience. This data is stored only on your device and is not transmitted to us or any third party. You can clear this search history at any time from within the App settings (e.g., a "Clear All" button associated with the search history).
We do not use any third-party analytics services to collect usage data.

**3. How We Use Information**

Since we do not collect any Personally Identifiable Information, we do not use it for any purpose. The locally stored search history is solely for your convenience and to enhance your user experience within the App on your device.

**4. Information Sharing and Disclosure**

We DO NOT share, sell, rent, or trade any Personally Identifiable Information with third parties as we do not collect such information.
The App may contain links to external third-party services or websites for your convenience or information. These include:
Telegram: For sending lyrics or feedback.
YouTube: For accessing related channel content.
Email Client: For sending feedback directly to us.
App Store / Google Play Store: For rating the App.
Please be aware that when you click on these links, you will be navigating to a third-party site or service. These external sites have their own separate and independent privacy policies. We, therefore, have no responsibility or liability for the content, activities, and privacy practices of these linked sites. We encourage you to review the privacy policies of any third-party sites or services you visit.

**5. Data Security**

All the content provided by the App (hymns, lyrics, prayers, saints' histories, images) is embedded within the application package or loaded from the application's own assets. No user-specific data, other than the locally stored search history (as described in Section 2), is stored by the App in a way that is accessible to us. The security of the locally stored search history depends on the security of your own device.

**6. Children's Privacy**

The መኣዲ ፀጋ App is intended for a general audience, including children (specifically from 6 years and above) with content such as "መባእታ ትምህርቲ ክርስቶስ" (Mebaeta Timhirti Kristos). We do not knowingly collect any Personally Identifiable Information from children under the age of 13 (or the relevant age of consent in your jurisdiction). If you are a parent or guardian and you believe that your child has provided us with personal information (which should not be possible through the App's design), please contact us immediately so that we can take necessary steps.

**7. User Rights and Choices (Opt-Out)**

As we do not collect Personally Identifiable Information, there are no specific opt-out mechanisms required for data collection beyond the App's core functionality.
For the locally stored Search History, you have the right to clear it at any time from within the App.

**8. International Users**

The App is intended for use by Tigrinya-speaking Catholic faithful around the world. While we do not specifically target users in any particular jurisdiction for data collection (as we collect no PII), we aim to respect general privacy principles.

**9. Changes to This Privacy Policy**

We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the App. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted.

**10. Contact Us**

If you have any questions or suggestions about this Privacy Policy, or how we handle data (or the lack thereof), do not hesitate to contact us:

**By email:** bahlbi0909@gmail.com
''';