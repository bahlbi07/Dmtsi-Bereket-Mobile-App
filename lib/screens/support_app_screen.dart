import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../utils/analytics_service.dart';

class SupportAppScreen extends StatefulWidget {
  const SupportAppScreen({super.key});

  @override
  State<SupportAppScreen> createState() => _SupportAppScreenState();
}

class _SupportAppScreenState extends State<SupportAppScreen> {
  // 🌟 ናይ ቴሌግራም ወግዓዊ ዩዘርነይም (ወይ ቦት) ኣብዚ ይቕመጥ
  final String telegramUsername = "SpiritualApp";

  bool _isCheckingConnection = true;
  bool _hasInternet = false;
  String? _detectedCountryCode; // "ET" ወይ ካልእ ሃገር
  String _selectedOption = 'local'; // 'local' ወይ 'international'

  @override
  void initState() {
    super.initState(); // ✅ ብትኽክል ዝተኣረመ
    _initializeScreen();
  }

  // ኩሉ ናይ ኢንተርኔትን IP ፍተሻን ብሓንሳብ ዘጀምር ፋንክሽን
  Future<void> _initializeScreen() async {
    setState(() {
      _isCheckingConnection = true;
    });

    final hasNetwork = await _checkNetworkConnectivity();
    if (hasNetwork) {
      final hasActualInternet = await _verifyActualInternet();
      if (hasActualInternet) {
        _hasInternet = true;
        final country = await _fetchCountryCode();
        setState(() {
          _detectedCountryCode = country;
          // ብኣውቶማቲክ ናይቲ ተጠቃሚ ቦታ ምእማት (Smart Default Selection)
          if (country == 'ET') {
            _selectedOption = 'local';
          } else if (country != null) {
            _selectedOption = 'international';
          }
          _isCheckingConnection = false;
        });
        return;
      }
    }

    setState(() {
      _hasInternet = false;
      _isCheckingConnection = false;
    });
  }

  // 1. ናይ ዋይፋይ ወይ ዳታ ምብራሁ ጥራይ ፍተሻ
  Future<bool> _checkNetworkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  // 2. ብትኽክል ናይ ኢንተርኔት ዳታ ምህላዉ ምርግጋጽ
  Future<bool> _verifyActualInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
    return false;
  }

  // 3. ናይ ተጠቃሚ IP ብምፍታሽ ሃገር ምልላይ (Asynchronous Geolocation)
  Future<String?> _fetchCountryCode() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['country_code'] as String?;
      }
    } catch (_) {
      // ጌጋ እንተጋጢሙ ብስቕታ ይሓልፍ (Fallback to manual)
    }
    return null;
  }

  // ኢንተርኔት እንተዘይሃልዩ ዝርአ ስኪሪን ወይ መልእኽቲ
  void _showNoInternetSnackbar() {
    HapticFeedback.vibrate();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'በጃኹም ኢንተርኔት ወልዑ እሞ ዳግማይ ፈትኑ!',
                style: TextStyle(fontFamily: 'Nyala', fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC61B1B),
        action: SnackBarAction(
          label: 'ፈትን',
          textColor: Colors.white,
          onPressed: _initializeScreen,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ተጠቃሚ ጌጋ ምርጫ እንተገይሩ ዘጠንቅቕ ልስሉስ Dialogue (Soft Warning)
  void _showSoftWarningDialog(String targetOption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isLocalWarning = targetOption == 'local';
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFC61B1B)),
              const SizedBox(width: 10),
              Text(
                isLocalWarning ? 'ናይ ውሽጢ ዓዲ መሪጽካ' : 'ናይ ወጻኢ መሪጽካ',
                style: const TextStyle(
                    fontFamily: 'Nyala', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isLocalWarning
                ? 'ካብ ሃገር ወጻኢ ትርከብ ዘለኻ ይመስል፧ ናይ ውሽጢ ዓዲ ኣማራጺ (CBE/telebirr) ናይ ኢትዮጵያ ስልኪ ወይ ባንክ ኣካውንት ይሓትት እዩ።'
                : 'ኣብ ውሽጢ ኢትዮጵያ ዘለኻ ይመስል፧ ናይ ወጻኢ ኣማራጺ (PayPal/Buy Me a Coffee) ንምጥቃም ዓለምለኻዊ ናይ ክፍሊት ካርድ የድልየካ እዩ።',
            style:
                const TextStyle(fontFamily: 'Nyala', fontSize: 18, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ቀይር',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC61B1B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _proceedToTelegram(targetOption);
              },
              child: const Text('ቀጽል',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // ብመሰረት ዝተመርጸ ቦታ ፕሮምትድ መልእኽቲ ኣዳልዩ ናብ ቴሌግራም ዝሰድድ ፋንክሽን
  Future<void> _proceedToTelegram(String option) async {
    String message = "";
    if (option == 'local') {
      message =
          "ሰላም፣ ነዚ ኣፕሊኬሽን ንምድጋፍ ዝርዝር ናይ ውሽጢ ዓዲ (ንግድ ባንክ፣ ቴሌብር፣ ዳሽን) ሕሳብ ቁጽሪ ክትልእኹለይ ትኽእሉ ዶ፧ የቐንየለይ።";
    } else {
      message =
          "Hello, I would like to support the app from abroad. Could you please send me your PayPal or Buy Me a Coffee details? Thank you.";
    }

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri url =
        Uri.parse('https://t.me/$telegramUsername?text=$encodedMessage');

    AnalyticsService.track('donation_option_clicked', {
      'selected_region': option,
      'detected_ip_country': _detectedCountryCode ?? 'Unknown',
    });

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ቴሌግራም ክኽፈት ኣይከኣለን።')),
      );
    }
  }

  // ተጠቃሚ "ቀጽል" ክብል ከሎ ዝፍጸም ፍተሻታት
  void _onProceedPressed() {
    HapticFeedback.mediumImpact();

    // 1. መጀመሪያ ናይ ኢንተርኔት ኩነታት ቼክ ንገብር
    if (!_hasInternet) {
      _showNoInternetSnackbar();
      return;
    }

    // 2. ናይ ጌጋ ምርጫ ፍተሻ (Soft Warning Validation)
    if (_detectedCountryCode != null) {
      if (_detectedCountryCode == 'ET' && _selectedOption == 'international') {
        _showSoftWarningDialog('international');
        return;
      } else if (_detectedCountryCode != 'ET' && _selectedOption == 'local') {
        _showSoftWarningDialog('local');
        return;
      }
    }

    // 3. ጸገም እንተዘይሃልዩ ቀጥታ ይልእኽ
    _proceedToTelegram(_selectedOption);
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.maybePop(context);
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
                    // 🌟 መብርሂ ጽሑፍ ዘለዎ ካርድ
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
                            "ነዚ ኣፕሊኬሽን ምምዕባልን ስራሕቲ ስብከተ ወንጌል ንምስፋሕን ዝግበር ዝኾነ ይኹን መንፈሳዊ ሓገዝን ድጋፍን ምስጋናና ልዑል እዩ። ደገፍኩም እቲ ኣገልግሎት ብዝበለጸ ክቕጽልን ክሰፍሕን ዓቢ ዓቕሚ እዩ።",
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

                    // 🌟 ናይ ኢንተርኔትን IP ፍተሻን ዝሕብር ስታተስ (Status Indicator)
                    if (_isCheckingConnection)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFFC61B1B)),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "",
                            style: TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 16,
                                color: Colors.grey),
                          )
                        ],
                      )
                    else if (!_hasInternet)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "ኢንተርኔት የለን",
                            style: TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _detectedCountryCode == 'ET' ? "" : "",
                            style: const TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 15,
                                color: Colors.green,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    const SizedBox(height: 24),

                    // 🌟 ናይ ቦታ መረጻ ካርታታት (Custom Selector Cards)
                    _buildSelectionCard(
                      id: 'local',
                      title: 'ኣብ ውሽጢ ዓዲ (ኢትዮጵያ)',
                      subtitle: 'CBE (ንግድ ባንክ)፣ telebirr (ቴሌብር)፣ Dashen Bank',
                      icon: Icons.account_balance_rounded,
                      isRecommended: _detectedCountryCode == 'ET',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSelectionCard(
                      id: 'international',
                      title: 'ካብ ወጻኢ ሃገር (International)',
                      subtitle: 'PayPal, Buy Me a Coffee (Visa/Mastercard)',
                      icon: Icons.language_rounded,
                      isRecommended: _detectedCountryCode != null &&
                          _detectedCountryCode != 'ET',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 40),

                    // 🌟 ቀጽል ዝብል ዋና ናይ መወዳእታ ቁልፊ (Action Button)
                    ElevatedButton.icon(
                      onPressed: _onProceedPressed,
                      icon: const Icon(Icons.telegram, size: 24),
                      label: const Text(
                        "ቀጽል (Proceed)",
                        style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC61B1B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ናይ መረጻ ካርታ ዲዛይን ዝሰርሕ Helper Widget
  Widget _buildSelectionCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isRecommended,
    required bool isDark,
  }) {
    final isSelected = _selectedOption == id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedOption = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C1E1E) : const Color(0xFFFFF5F5))
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFC61B1B) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFC61B1B) : Colors.grey,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFFC61B1B)
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFC61B1B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Recommended",
                            style: TextStyle(
                                fontFamily: 'Nyala',
                                color: Color(0xFFC61B1B),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
