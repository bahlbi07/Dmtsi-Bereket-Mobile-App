import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  // ንቋንቋ መቆፃፀሪ (false = ትግርኛ፣ true = English)
  bool _isEnglish = false;

  // ሊንክታት ብቐሊሉን ብውሕስነትን ንምኽፋት ዝሕግዝ ዘመናዊ ፈንክሽን
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEnglish
                  ? 'Could not open the link.'
                  : 'ነቲ ሊንክ ክንከፍቶ ኣይከኣልናን።'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ንኣርእስትታት ፍሉይ ፅባቐ ንምሃብ ዝተዳለወ ንእሽተይ ዊድጀት
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFC61B1B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nyala',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Area
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        _isEnglish ? 'About App' : 'ብዛዕባ ኣፕ (About App)',
                        style: const TextStyle(
                          fontFamily: 'Nyala',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // ቋንቋ መለዋወጢ በተን (Language Selector Toggle)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _isEnglish = !_isEnglish;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC61B1B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFC61B1B),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _isEnglish ? 'ትግርኛ' : 'English',
                        style: const TextStyle(
                          fontFamily: 'Nyala',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC61B1B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 38.0),
                child: Column(
                  children: [
                    // ካርድ 1፦ መግለፂ መኣዲ ጸጋ (App Overview & Vision)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/icons/app1.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'መኣዲ ጸጋ',
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC61B1B),
                            ),
                          ),
                          const Text(
                            'Version 2.0.0',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),
                          // መእተዊ (Mission & Value Proposition) - 🌟 ሓዱሽ ፕሮፌሽናል ፅሑፍ
                          Text(
                            _isEnglish
                                ? "Me'adi Tsega is an official spiritual application designed for Tigrinya-speaking Catholic faithful. Committed to enriching daily devotional life and deepening ecclesiastical knowledge, the app provides structured, offline-ready access to essential prayers, liturgical frameworks, and authentic Catholic catechism."
                                : "መኣዲ ጸጋ ንተዛረብቲ ቋንቋ ትግርኛ ካቶሊካውያን መእመናን ዝተዳለወ ወግዓዊ መንፈሳዊ መተግበሪ እዩ። እዚ መተግበሪ እዚ፣ ዕለታዊ ጸሎታት፣ ስርዓተ ኣምልኾ፣ ሃብታም ትምህርተ ሃይማኖትን ታሪኽ ቤተክርስትያንን ብቐሊሉ ኣብ ዘለዉዎ ኮይኖም ንኽረኽቡ ብምግባር፣ ዕለታዊ መንፈሳዊ ህይወት መእመናን ንምሕጋዝን ሃይማኖታዊ ፍልጠቶም ንምዕባይን ዝዓለመ እዩ።",
                            style: const TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 17,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 15),
                          // ብዛዕባ መኣዲ ጸጋ (Features Intro) - 🌟 ሓዱሽ ፕሮፌሽናል ፅሑፍ
                          Text(
                            _isEnglish
                                ? "The application is engineered for maximum accessibility, user convenience, and reliable performance to serve as a trustworthy spiritual companion in the daily life of believers."
                                : "እዛ ኣፕሊኬሽን እዚኣ ንተበጻሕነት (Accessibility)፣ ንቐሊል ኣጠቓቕማ (Ease of Use)፣ ከምኡ እውን ኣብ ዕለታዊ ሃይማኖታዊ ህይወት መእመናን ቀጻሊ ደጋፊ ንኽትከውን ብዝለዓለ ውሕስነትን ብቕዓትን ተዳልያ እያ።",
                            style: const TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 17,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureItem(
                              Icons.star_rounded,
                              _isEnglish
                                  ? "Daily Prayers & Holy Rosary"
                                  : "ዝተፈላለዩ ጸሎታትን ጸሎተ መቑጸርያን"),
                          _buildFeatureItem(
                              Icons.menu_book_rounded,
                              _isEnglish
                                  ? "Lives of Saints (Over 27 Saints' Biographies)"
                                  : "ታሪኽ ቅዱሳን (ልዕሊ 27 ቅዱሳን ሓፂር ዛንታ)"),
                          _buildFeatureItem(
                              Icons.format_quote_rounded,
                              _isEnglish
                                  ? "Quotes of Saints (Over 23 Spiritual Themes)"
                                  : "ጥቅስታት ቅዱሳን (ልዕሊ 23 መንፈሳዊ ዛዕባታት)"),
                          _buildFeatureItem(
                              Icons.church_rounded,
                              _isEnglish
                                  ? "Catechism & Rich Church History"
                                  : "ትምህርተ ሃይማኖትን ታሪኽ ቤተክርስትያንን"),
                          _buildFeatureItem(
                              Icons.spa_rounded,
                              _isEnglish
                                  ? "Spiritual Life & Liturgical Guides"
                                  : "መንፈሳዊ ህይወትን ስርዓተ ቅዳሴን"),
                          _buildFeatureItem(
                              Icons.wifi_off_rounded,
                              _isEnglish
                                  ? "100% Offline Access"
                                  : "ሙሉእ ብሙሉእ ኦፍላይን (Offline) ዝሰርሕ"),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC61B1B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon:
                                const Icon(Icons.rate_review_rounded, size: 18),
                            label: Text(
                              _isEnglish
                                  ? 'Rate Us on Play Store'
                                  : 'ኣብ Play Store ኮኾብ (5 Stars) ሃቡና',
                              style: const TextStyle(
                                  fontFamily: 'Nyala',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _launchURL(context,
                                  'https://play.google.com/store/apps/details?id=com.BHLabs.catholicapp');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ካርድ 2፦ ምስጋናን ኣፍልጦን (Acknowledgements & Credits) - 🌟 ሓዱሽ ፕሮፌሽናል ፅሑፍ
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEnglish
                                ? 'Acknowledgements & Credits'
                                : 'ምስጋናን ኣፍልጦን (Credits)',
                            style: const TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC61B1B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isEnglish
                                ? "We express our profound gratitude to the ecclesiastical authorities and authors whose canonical resources, blessings, and literature made this application possible:"
                                : "እዚ ኣገልግሎት እዚ ብትኽክለኛን ብስርዓት ተዳልዩ ንኽበፅሕ፣ ወሰንቲ መንፈሳዊ ፅሑፋትን መጻሕፍትን ንኽንጥቀም ፍቓድን ኣቦኣዊ ቡራኬን ዘበርከቱልና ኣካላት ምስጋናና ልዑል እዩ፦",
                            style: const TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.grey),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _isEnglish
                                ? "His Excellency Abune Tesfasellassie Medhin (Bishop of Adigrat)"
                                : "ብፁዕ ኣቡነ ተስፋስላሴ መድህን (ጳጳስ ዘካቶሊካውያን ዘዓዲግራት)፦",
                            style: const TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _isEnglish
                                ? "— For his fatherly blessings and for granting the rights to utilize essential literature on 'Church History'."
                                : "— ኣብዛ ኣፕሊኬሽን ንዘሎ 'ታሪኽ ቤተ-ክርስትያን' ዘለዎ መፅሓፍ ናብዚ መተግበሪ ንክፀዓን ብምፍቃድን ነዚ ስራሕ ብኣቦኣዊ ፍቕሪ ብምባረኾምን።",
                            style: const TextStyle(
                                fontFamily: 'Nyala', fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _isEnglish
                                ? "Rev. Abba Musie Dori"
                                : "ክቡር ኣባ ሙሴ ዶሪ፦",
                            style: const TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _isEnglish
                                ? "— For officially permitting the adaptation of the hagiographical texts and spiritual insights from his published book, 'Short History of Saints and Quotes'."
                                : "— ካብቲ ንሶም ዘሰናደውዎ 'ሓፂር ታሪኽ ቅዱሳን እና ጥቅስታት' ዝብል መፅሓፍ፣ ታሪኽ ቅዱሳንን ጥቅስታቶምን ንኽንወስድ ወግዓዊ ፍቓዶም ስለዝሃቡና።",
                            style: const TextStyle(
                                fontFamily: 'Nyala', fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 15),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isEnglish ? 'UI/UX Designer:' : 'UI/UX ዲዛይነር፦',
                                style: const TextStyle(
                                    fontFamily: 'Nyala',
                                    fontSize: 15,
                                    color: Colors.grey),
                              ),
                              Text(
                                _isEnglish
                                    ? 'Nahom Embaye'
                                    : 'ናሆም እምባየ (Nahom Embaye)',
                                style: TextStyle(
                                  fontFamily: 'Nyala',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEnglish
                                ? "Acknowledged for his precise craftsmanship and dedication in designing this modern interface."
                                : "እዛ ኣፕሊኬሽን ንዓይኒ ምጭውትን ዘመናዊትን ንክትከውን ንለባም ስራሑን ዓቢ ኣበርክቶኡን ኣፍልጦ ንህብ።",
                            style: const TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ካርድ 3፦ ምልላይ "ድምፀ በረኸት" ኣፕሊኬሽን (Cross-Promotion) - 🌟 ሓዱሽ ፕሮፌሽናል ፅሑፍ
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.music_note_rounded,
                                  color: Color(0xFFC61B1B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isEnglish
                                      ? 'My Other App: Dmtsi Bereket'
                                      : 'ድምፀ በረኸት (Catholic Mezmur Lyrics)',
                                  style: const TextStyle(
                                    fontFamily: 'Nyala',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC61B1B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isEnglish
                                ? "To further enrich your devotion, we warmly invite you to explore 'Dmtsi Bereket' (Catholic Mezmur Lyrics), containing over 1,030 hymns to accompany your daily worship."
                                : "ንተወሳኺ መንፈሳዊ ዕቤት፣ ልዕሊ 1030 ናይ ካቶሊክ መዛሙር ግጥምታት ዝሓዘት 'ድምፀ በረኸት' (ካቶሊክ መዝሙር ግጥሚ) እትበሃል መተግበሪና ብምውራድ ክትጥቀሙ ብፍቕሪ ይዕድም።",
                            style: const TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFC61B1B), width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              icon: const Icon(Icons.download_rounded,
                                  color: Color(0xFFC61B1B), size: 18),
                              label: Text(
                                _isEnglish
                                    ? 'Download Dmtsi Bereket'
                                    : 'ድምፀ በረኸት ኣፕሊኬሽን ኣውርድ',
                                style: const TextStyle(
                                  fontFamily: 'Nyala',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC61B1B),
                                ),
                              ),
                              onPressed: () {
                                _launchURL(context,
                                    'https://play.google.com/store/apps/details?id=com.BHLabs.mezmur_app');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ካርድ 4፦ ዲቨሎፐር ሓበሬታ
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEnglish
                                ? 'Developer Contact'
                                : 'ዲቨሎፐር ሓበሬታ (Developer)',
                            style: const TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC61B1B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_isEnglish ? 'Developed By:' : 'ዝሰርሖ ዲቨሎፐር፦',
                                  style: const TextStyle(
                                      fontFamily: 'Nyala', fontSize: 16)),
                              const Text('© 2026 BHD Apps',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              _launchURL(context,
                                  'mailto:dmtsibereketapp@gmail.com?subject=Feedback%20for%20Meadi%20Tsega');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_isEnglish ? 'Email Us:' : 'ኢሜይል፦',
                                    style: const TextStyle(
                                        fontFamily: 'Nyala', fontSize: 16)),
                                const Text(
                                  'dmtsibereketapp@gmail.com',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC61B1B),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
