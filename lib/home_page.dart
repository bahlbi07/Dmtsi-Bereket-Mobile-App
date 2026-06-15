// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io'; // 🌟 ሓዱሽ ዝተወሰኸ (ን Platform.isAndroid ፍተሻ)
import 'dart:math' as math;
import 'dart:async'; // ን ስላይድ ማኒፑሌት ንምግባር
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart'; // 🌟 ሓዱሽ ዝተወሰኸ (ን Google Play In-App Updates)

// 🌟 AdMob ንምእታው ዝተወሰኹ ሓደስቲ ፓኬጃት 🌟
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ad_helper.dart';
import 'widgets/offline_ad_widget.dart';

import 'custom_page_route.dart';
import 'main.dart'; // ን themeNotifier ንምርካብ
import 'utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

// Data & Search Engine
import 'data/quotes_of_saint_data.dart';

// Screens
import 'screens/prayer_content_screen.dart';
import 'screens/saints_history_screen.dart';
import 'screens/quotes_of_saint_screen.dart';
import 'screens/doctrine_screen.dart';
import 'screens/church_history_screen.dart';
import 'screens/spiritual_life_screen.dart';
import 'screens/favorites_list_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/global_search_screen.dart';

class MeadiTsegaHomePage extends StatefulWidget {
  const MeadiTsegaHomePage({super.key});

  @override
  State<MeadiTsegaHomePage> createState() => _MeadiTsegaHomePageState();
}

class _MeadiTsegaHomePageState extends State<MeadiTsegaHomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  // 🌟 ዝተመሓየሸ፦ ብዘንደር ንዝተላእኩን ፕለይ ስቶር ንዘይብሎምን ስልካታት ብስቕታ ዝሓልፍ ውሑስ መቆጻጻሪ
  Future<void> _checkForUpdate() async {
    if (Platform.isAndroid) {
      try {
        final updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          await InAppUpdate.performImmediateUpdate();
        }
      } catch (e) {
        // ዝኾነ ናይ ኔትወርክ ወይ የለን ፕለይ ስቶር ጌጋ (PlatformException) እንተጋጢሙ ብስቕታ ይሓልፍ (ንኣፕሊኬሽን ኣይዓጽዎን) [1]
        AnalyticsService.track('in_app_update_failed', {
          'error': e.toString(),
        });
      }
    }
  }

  // 🌟 ሓዱሽ ዝተወሰኸ፦ ካብ ኣፕሊኬሽን ቅድሚ ምውጻእ ናይ ምርግጋጽ Dialogue መርኣዪ
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final isDark = themeNotifier.value == ThemeMode.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1814) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ርግጸኛታት ዲኹም？',
          style: TextStyle(
            fontFamily: 'Nyala',
            fontWeight: FontWeight.bold,
            color: Color(0xFFC61B1B),
          ),
        ),
        content: const Text(
          'ካብዚ ኣፕሊኬሽን ክትወጹ ትደልዩ ዶ？',
          style: TextStyle(fontFamily: 'Nyala', fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ኣይፋል',
                style: TextStyle(
                    fontFamily: 'Nyala', color: Colors.grey, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC61B1B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('እወ',
                style: TextStyle(
                    fontFamily: 'Nyala', color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ን 3 ካልኢት ዝጸንሕ ናይ ሎዲንግ/ስፕላሽ ግዜ (Splash Timing)
  void _loadAppData() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _checkForUpdate(); // 🌟 ስፕላሽ ሎዲንግ ምስ ተወድአ ኣፕዴት ይፍትሽ
    }
  }

  // እቶም 4 ታባት
  final List<Widget> _pages = [
    const _HomeView(),
    const GlobalSearchScreen(),
    const FavoritesCategoryScreen(),
    const MenuScreen(),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    if (index == 2) {
      AnalyticsService.track('favorites_tab_clicked', {});
    }
    if (_selectedIndex == index) {
      // Tap same tab → pop to root of that tab
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. መጀመርታ ሎዲንግ/ስፕላሽ ስክሪን የርኢ
    if (_isLoading) {
      return _buildLoadingScreen(context);
    }

    // 2. ድሕሪኡ እቲ ናይ 4 ታባት ዋና ገጽ
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // First try to pop within the current tab's navigator (safe: maybePop)
        final popped =
            await (_navigatorKeys[_selectedIndex].currentState?.maybePop() ??
                Future.value(false));
        if (!popped) {
          if (_selectedIndex != 0) {
            // Go back to home tab
            setState(() => _selectedIndex = 0);
          } else {
            // On home with nothing to pop → exit app with confirmation dialogue
            final shouldExit = await _showExitConfirmationDialog(context);
            if (shouldExit) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            for (int i = 0; i < _pages.length; i++)
              _TabNavigator(
                navigatorKey: _navigatorKeys[i],
                child: _pages[i],
              ),
          ],
        ),
        bottomNavigationBar: _buildGlideNavBar(isDark),
      ),
    );
  }

  // ===== Island Glide Navigation Bar =====
  Widget _buildGlideNavBar(bool isDark) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double barWidth = screenWidth - 36;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1814) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGlideNavItem(
                  0, 'ገዛ', Icons.home_outlined, isDark, barWidth),
              _buildGlideNavItem(1, 'ድለ', Icons.search, isDark, barWidth),
              _buildGlideNavItem(
                  2, 'ዝፈተኽዎም', Icons.bookmark_border_rounded, isDark, barWidth),
              _buildGlideNavItem(
                  3, 'ዝርዝር', Icons.grid_view_outlined, isDark, barWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlideNavItem(
      int index, String label, IconData icon, bool isDark, double barWidth) {
    final bool sel = _selectedIndex == index;

    const Color amberCircle = Color(0xFFFAEDD4);
    const Color amberIcon = Color(0xFFB8860B);
    final Color inactiveIcon =
        isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF2B2418);

    final double targetWidth = sel ? barWidth * 0.40 : barWidth * 0.20;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: targetWidth,
        height: 64,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: sel ? targetWidth - 8 : 44,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: sel ? amberCircle : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: sel ? amberIcon : inactiveIcon,
                ),
                if (sel) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: amberIcon,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F2ED),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RotatingRosarySpinner(
                  size: 140,
                  color: Color(0xFFC61B1B),
                ),
                const SizedBox(height: 32),
                Text(
                  'መኣዲ ጸጋ',
                  style: TextStyle(
                    fontFamily: 'Nyala',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFEEEEEE)
                        : const Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        return true;
      },
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late final Timer _slideTimer;
  int _currentImageIndex = 0;
  Map<String, String>? _randomQuote;

  late DateTime _homeStartTime;

  // 🌟 AdMob Banner Ad ንምቁጽጻር ዝተወሰኹ ቫርየብልስ 🌟
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  final List<String> _homeImages = const [
    'assets/images/home/jesus2.jpg',
    'assets/images/home/jesus10.jpg',
    'assets/images/home/jesus12.jpg',
    'assets/images/home/jesus13.jpg',
    'assets/images/home/jesus15.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _homeStartTime = DateTime.now();
    _selectRandomQuote();

    _slideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _homeImages.length;
        });
      }
    });
  }

  // 🌟 Context ደሓን ኮይኑ ምስ ተዳለወ ሓዱሽ Banner Ad ንምፅዓን 🌟
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadBannerAd();
    }
  }

  // 🌟 Banner Ad Load ዝገብር ሓዱሽ ፈንክሽን 🌟
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded.');
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          // 🌟 ሓዱሽ ዝተወሰኸ፦ እቲ ኣፕሊኬሽን ኔትወርክ ምስ ተመልሰ ዳግማይ Ad ንኽልምን ይሕግዝ
          setState(() {
            _bannerAd = null;
            _isBannerAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  void _selectRandomQuote() {
    setState(() {
      _randomQuote = GlobalSearchScreen.getRandomQuote(quotesContentData);
    });
  }

  @override
  void dispose() {
    _slideTimer.cancel();
    final int secondsSpent =
        DateTime.now().difference(_homeStartTime).inSeconds;
    AnalyticsService.track('time_spent_on_home', {
      'seconds': secondsSpent,
    });
    // 🌟 ነቲ Banner Ad ካብ ሜሞሪ ንምድምሳስ ዝተወሰኸ 🌟
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 1. Hero Banner
          Padding(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 230,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: Image.asset(
                          _homeImages[_currentImageIndex],
                          key: ValueKey<int>(_currentImageIndex),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.82),
                              Colors.black.withValues(alpha: 0.58),
                              Colors.black.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.30, 0.62, 0.90],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'መኣዲ',
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 14)
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 32.0),
                            child: Text(
                              'ጸጋ',
                              style: TextStyle(
                                fontFamily: 'Nyala',
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                height: 0.88,
                                shadows: [
                                  Shadow(color: Colors.black38, blurRadius: 14)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2.5,
                            width: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.85),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'ቃል ኣምላኽ ዝምገብሉ መንፈሳዊ ማእኸል',
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 14,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 10)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 14,
                      top: 14,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final nextMode =
                              isDark ? ThemeMode.light : ThemeMode.dark;
                          themeNotifier.value = nextMode;
                          AnalyticsService.track('dark_mode_toggled', {
                            'is_dark_mode': nextMode == ThemeMode.dark,
                            'source': 'home_screen_banner'
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.wb_sunny_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _homeImages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _currentImageIndex ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _currentImageIndex
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🌟 Google AdMob Banner Ad / Offline Banner Placement (ኣብ መንጎ ምስልን ጥቅስን ዘመናዊ ኣቀማምጣ) 🌟
          if (_isBannerAdLoaded && _bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          else
            const OfflineAdWidget(), // 🌟 ኢንተርኔት ኦፍላይን ክኸውን ከሎ እዚ ስማርት ባነር ባዕሉ የርእይ 🌟
          const SizedBox(height: 16),

          // 2. Quote Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1C1414), const Color(0xFF1A1A1A)]
                      : [Colors.white, const Color(0xFFFDF5EE)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC61B1B)
                        .withValues(alpha: isDark ? 0.12 : 0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\u201c',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 84,
                        height: 0.55,
                        color: Color(0xFFE8B15A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _randomQuote != null
                          ? _randomQuote!['quote']!
                          : '\u1275\u1215\u12d8\u1276 \u12ed\u1345\u12d3\u1295 \u12a3\u120e...',
                      style: TextStyle(
                        fontFamily: 'Nyala',
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8B15A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _randomQuote?['author'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 14.5,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          3,
                          (i) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: i == 1 ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: i == 1
                                      ? const Color(0xFFE8B15A)
                                      : Colors.grey.withValues(alpha: 0.30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC61B1B), Color(0xFF9E0B0F)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ዝርዝር ዕዮታት',
                  style: TextStyle(
                    fontFamily: 'Nyala',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Grid View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
              children: [
                _buildGridItem(context, 'ዝተፈላለዩ ጸሎታት', const PrayerScreen()),
                _buildGridItem(
                    context, 'ታሪኽ ቅዱሳን', const SaintsHistoryScreen()),
                _buildGridItem(
                    context, 'ጥቅስታት ቅዱሳን', const QuotesOfSaintScreen()),
                _buildGridItem(context, 'ትምህርተ ሃይማኖት', const DoctrineScreen()),
                _buildGridItem(
                    context, 'ታሪኽ ቤተክርስትያን', const ChurchHistoryScreen()),
                _buildGridItem(
                    context, 'መንፈሳዊ ህይወት', const SpiritualLifeScreen()),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, String title, Widget destinationPage) {
    const Map<String, IconData> categoryIcons = {
      'ዝተፈላለዩ ጸሎታት': Icons.favorite_rounded,
      'ታሪኽ ቅዱሳን': Icons.menu_book_rounded,
      'ጥቅስታት ቅዱሳን': Icons.format_quote_rounded,
      'ትምህርተ ሃይማኖት': Icons.school_rounded,
      'ታሪኽ ቤተክርስትያን': Icons.church_rounded,
      'መንፈሳዊ ህይወት': Icons.eco_rounded,
    };
    const Map<String, String> categorySubtitles = {
      'ዝተፈላለዩ ጸሎታት': 'መሰረታዊ ትምህርትን ጸሎታትን',
      'ታሪኽ ቅዱሳን': 'ኣብነት ቅዱሳን ብሓጺሩ',
      'ጥቅስታት ቅዱሳን': 'መንፈሳዊ ጥበብን ኣስተንትኖን',
      'ትምህርተ ሃይማኖት': 'ዶግማን መሰረተ እምነትን',
      'ታሪኽ ቤተክርስትያን': 'ታሪኽ ካቶሊክ ኣብ ሓበሻ',
      'መንፈሳዊ ህይወት': 'ስርዓተ ቅዳሴ፣ ቃል ኣምላኽን መንፈሳዊ ተጋድሎን',
    };
    final Map<String, String> gridIcons = {
      'ዝተፈላለዩ ጸሎታት': 'assets/icons/All_Prayer.jpg',
      'ታሪኽ ቅዱሳን': 'assets/icons/sainthistory.jpg',
      'ጥቅስታት ቅዱሳን': 'assets/icons/quotes.jpg',
      'ትምህርተ ሃይማኖት': 'assets/icons/doctrine.png',
      'ታሪኽ ቤተክርስትያን': 'assets/icons/Churchhistory.jpg',
      'መንፈሳዊ ህይወት': 'assets/icons/spirituallife.png',
    };

    const Map<String, List<Color>> categoryAccents = {
      'ዝተፈላለዩ ጸሎታት': [Color(0xFFC61B1B), Color(0xFF7B0000)],
      'ታሪኽ ቅዱሳን': [Color(0xFF1565C0), Color(0xFF0A2472)],
      'ጥቅስታት ቅዱሳን': [Color(0xFF6A1B9A), Color(0xFF38006B)],
      'ትምህርተ ሃይማኖት': [Color(0xFF2E7D32), Color(0xFF1B5E20)],
      'ታሪኽ ቤተክርስትያን': [Color(0xFF795548), Color(0xFF3E2723)],
      'መንፈሳዊ ህይወት': [Color(0xFFE65100), Color(0xFF7F2800)],
    };

    final imageAssetPath = gridIcons[title] ?? 'assets/images/others/jesus.jpg';
    final accentColors = categoryAccents[title] ??
        [const Color(0xFFC61B1B), const Color(0xFF7B0000)];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AnalyticsService.track('category_clicked', {'category_name': title});
        Navigator.push(context,
            SlowCupertinoPageRoute(builder: (context) => destinationPage));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColors[0].withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imageAssetPath, fit: BoxFit.cover),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColors[0].withValues(alpha: 0.22),
                        accentColors[1].withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        accentColors[1].withValues(alpha: 0.5),
                        accentColors[1].withValues(alpha: 0.92),
                      ],
                      stops: const [0.35, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColors[0].withValues(alpha: 0.40),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    categoryIcons[title] ?? Icons.apps_rounded,
                    size: 30,
                    color: accentColors[0],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Nyala',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8)
                          ],
                        ),
                      ),
                      Text(
                        categorySubtitles[title] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nyala',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.80),
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ],
                        ),
                      ),
                    ],
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

class RotatingRosarySpinner extends StatefulWidget {
  final double size;
  final Color color;
  final bool showCross;

  const RotatingRosarySpinner({
    super.key,
    this.size = 140,
    required this.color,
    this.showCross = true,
  });

  @override
  State<RotatingRosarySpinner> createState() => _RotatingRosarySpinnerState();
}

class _RotatingRosarySpinnerState extends State<RotatingRosarySpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RosaryPainter(color: widget.color),
            ),
          ),
          if (widget.showCross)
            CustomPaint(
              size: Size(widget.size * 0.4, widget.size * 0.4),
              painter: _CrossPainter(color: widget.color),
            ),
        ],
      ),
    );
  }
}

class _RosaryPainter extends CustomPainter {
  final Color color;
  _RosaryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, linePaint);

    final beadPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const int totalBeads = 10;
    const double beadRadius = 6.0;

    for (int i = 0; i < totalBeads; i++) {
      final double angle = i * (2 * math.pi / totalBeads);
      final double beadX = center.dx + radius * math.cos(angle);
      final double beadY = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(beadX, beadY), beadRadius, beadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final crossPaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.45),
      Offset(centerX, centerY + size.height * 0.45),
      crossPaint,
    );

    canvas.drawLine(
      Offset(centerX - size.width * 0.35, centerY - size.height * 0.15),
      Offset(centerX + size.width * 0.35, centerY - size.height * 0.15),
      crossPaint,
    );

    final bodyFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final bodyLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double intersectionY = centerY - size.height * 0.15;

    final Offset headCenter =
        Offset(centerX, intersectionY - size.height * 0.12);
    canvas.drawCircle(headCenter, size.width * 0.05, bodyFillPaint);

    final torsoPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, intersectionY - size.height * 0.06),
      Offset(centerX, intersectionY + size.height * 0.14),
      torsoPaint,
    );

    final Path armsPath = Path()
      ..moveTo(centerX - size.width * 0.26, intersectionY - size.height * 0.02)
      ..quadraticBezierTo(
        centerX - size.width * 0.13,
        intersectionY + size.height * 0.01,
        centerX,
        intersectionY - size.height * 0.05,
      )
      ..quadraticBezierTo(
        centerX + size.width * 0.13,
        intersectionY + size.height * 0.01,
        centerX + size.width * 0.26,
        intersectionY - size.height * 0.02,
      );
    canvas.drawPath(armsPath, bodyLinePaint);

    final Path sashPath = Path()
      ..moveTo(centerX - 5, intersectionY + size.height * 0.13)
      ..quadraticBezierTo(
        centerX,
        intersectionY + size.height * 0.17,
        centerX + 5,
        intersectionY + size.height * 0.13,
      );
    final sashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(sashPath, sashPaint);

    final legsPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, intersectionY + size.height * 0.14),
      Offset(centerX, intersectionY + size.height * 0.33),
      legsPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
