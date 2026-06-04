import 'dart:async'; // ን ስላይድ ማኒፑሌት ንምግባር
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
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
  bool _isLoading = true; // ንሎዲንግ ስክሪን መቆፃፀሪ

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  // ን 3 ካልኢት ዝፀንሕ ናይ ሎዲንግ/ስፕላሽ ግዜ (Splash Timing)
  void _loadAppData() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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

    // ጥቅሲ ዝፈተኽዎም ታብ ብዝሒ ዝተጠቐመ ምምዝጋብ
    if (index == 2) {
      AnalyticsService.track('favorites_tab_clicked', {});
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. መጀመርታ ሎዲንግ/ስፕላሽ ስክሪን የርኢ
    if (_isLoading) {
      return _buildLoadingScreen(context);
    }

    // 2. ድሕሪኡ እቲ ናይ 4 ታባት ዋና ገፅ የርኢ
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      // 45% ዶሚናንት ብዝኾነ ኣኒሜሽን ዝሰርሕ ዘመናዊ ታሕተዋይ ባር
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ናይቲ ስክሪን ሙሉእ ንጡፍ ስፍሓት ንረክብ
                final double totalWidth = constraints.maxWidth;

                // 45% ስፍሓት ንዝተመርፀ ታብ
                final double selectedWidth = totalWidth * 0.45;

                // ዝተረፈ 55% ስፍሓት ንሰለስቲኦም ዘይተመርፁ ታባት (ነፍሲ ወከፍ ኣስታት 18.3%)
                final double unselectedWidth = (totalWidth * 0.55) / 3;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAnimatedNavItem(0, 'ገዛ', 'assets/icons/home.png',
                        isDark, selectedWidth, unselectedWidth),
                    _buildAnimatedNavItem(1, 'ድለ', 'assets/icons/search.png',
                        isDark, selectedWidth, unselectedWidth),
                    _buildAnimatedNavItem(
                        2,
                        'ዝፈተኽዎም',
                        'assets/icons/bookmark.png',
                        isDark,
                        selectedWidth,
                        unselectedWidth),
                    _buildAnimatedNavItem(3, 'ዝርዝር', 'assets/icons/app.png',
                        isDark, selectedWidth, unselectedWidth),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 45% ዶሚናንት ስፍሓት ሒዙ ኣኒሜት ዝገብር ናይ ታብ ዊጀት
  Widget _buildAnimatedNavItem(
    int index,
    String label,
    String assetPath,
    bool isDark,
    double selectedWidth,
    double unselectedWidth,
  ) {
    final isSelected = _selectedIndex == index;
    // ዝተመረፀ እንተኾይኑ 45% ስፍሓት፣ እንተዘይኮይኑ 18.3% ይወስድ
    final double targetWidth = isSelected ? selectedWidth : unselectedWidth;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic, // ንስልጡን ምንቅስቓስ ዝጠቅም ኩርቭ
        width: targetWidth,
        height: 48, // ቋሚ ቁመት ንምግባር
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC61B1B) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown, // እቲ ፅሑፍ ካብቲ ስፍሓት ወፃኢ ንከይፈስስ ይከላኸል
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage(assetPath),
                  size: 24,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Nyala',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // እቲ ዝተመሓየሸ ናይ ሎዲንግ/ስፕላሽ ስክሪን ዊጀት
  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // እቲ ዝሽከርከር መቑፀርያ ምስቲ ኣብ ማእኸሉ ዘሎ መስቀል
                const RotatingRosarySpinner(
                  size: 150,
                  color: Color(0xFFC61B1B), // primaryRed
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
            ),
          ),
        ],
      ),
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
  Map<String, String>? _randomQuote; // ብራንደም ዝሳሓብ ጥቅሲ

  // ቆፀራ ግዘ ሆም ስክሪን ንምክትታል
  late DateTime _homeStartTime;

  // እቶም 5 ሰሌክት ጥራይ ዝተገበሩ ምስልታት (Landscape)
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
    _homeStartTime = DateTime.now(); // ምጅማር ሰዓት ሆም ስክሪን
    _selectRandomQuote(); // ጥቅሲ ካብቲ ሓድሽ search_engine.dart ብራንደም ይመርፅ

    _slideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _homeImages.length;
        });
      }
    });
  }

  // ካብቲ ዳታ ሓደ ብራንደም ጥቅስ ዝመርፅ ፈንክሽን
  void _selectRandomQuote() {
    setState(() {
      // ብቐጥታ ካብቲ ዝተፈለየ GlobalSearchEngine ጥቅሲ ይሓፍስ
      _randomQuote = GlobalSearchScreen.getRandomQuote(quotesContentData);
    });
  }

  @override
  void dispose() {
    _slideTimer.cancel();
    // ተጠቃሚ ኣብ ሆም ስክሪን ዝፀንሓሉ ሰኮንዶች ይመዝግብ
    final int secondsSpent =
        DateTime.now().difference(_homeStartTime).inSeconds;
    AnalyticsService.track('time_spent_on_home', {
      'seconds': secondsSpent,
    });
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
          const SizedBox(height: 16),
          // 1. Top Red Banner (መኣዲ ጸጋ ምስ Sliding Background & Theme Toggle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: double.infinity,
                height: 150,
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
                              const Color(0xFFC61B1B),
                              const Color(0xFFC61B1B).withValues(alpha: 0.70),
                              const Color(0xFFC61B1B).withValues(alpha: 0.50),
                              const Color(0xFFC61B1B).withValues(alpha: 0.15),
                            ],
                            stops: const [0.0, 0.3, 0.55, 0.8],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'መኣዲ',
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              color: Colors.white,
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              height: 0.38,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 28.0),
                            child: Text(
                              'ጸጋ',
                              style: TextStyle(
                                fontFamily: 'Nyala',
                                color: Colors.white,
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                height: 0.75,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: const Color(0xFFC61B1B),
                              size: 24,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              final nextMode =
                                  isDark ? ThemeMode.light : ThemeMode.dark;
                              themeNotifier.value = nextMode;

                              // ናይ ዳርክ ሞድ ምቕያር ንጥፈት ምምዝጋብ
                              AnalyticsService.track('dark_mode_toggled', {
                                'is_dark_mode': nextMode == ThemeMode.dark,
                                'source': 'home_screen_banner'
                              });
                            },
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

          // 2. Promo/Quote Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 38.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC61B1B).withValues(alpha: 0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF1E1E1E),
                                  const Color(0xFF1F1213),
                                ]
                              : [
                                  const Color(0xFFFFFDF9),
                                  const Color(0xFFF9F4EE),
                                ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -15,
                    top: -15,
                    child: Icon(
                      Icons.format_quote_rounded,
                      size: 140,
                      color: const Color(0xFFC61B1B)
                          .withValues(alpha: isDark ? 0.025 : 0.05),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _randomQuote != null
                              ? '"${_randomQuote!['quote']}"'
                              : 'ትሕዝቶ ይፅዓን ኣሎ...',
                          style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 19.5,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color
                                ?.withOpacity(0.95),
                            height: 1.25,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 1.5,
                              color: const Color(0xFFC61B1B)
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _randomQuote?['author'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'Nyala',
                                  fontSize: 15.5,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Grid View (6 Items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 35,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildGridItem(context, 'ዝተፈላለዩ ፀሎታት', const PrayerScreen()),
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
    final Map<String, String> gridIcons = {
      'ዝተፈላለዩ ፀሎታት': 'assets/icons/All_Prayer.jpg',
      'ታሪኽ ቅዱሳን': 'assets/icons/sainthistory.jpg',
      'ጥቅስታት ቅዱሳን': 'assets/icons/quotes.jpg',
      'ትምህርተ ሃይማኖት': 'assets/icons/doctrine.png',
      'ታሪኽ ቤተክርስትያን': 'assets/icons/Churchhistory.jpg',
      'መንፈሳዊ ህይወት': 'assets/icons/spirituallife.png',
    };

    final imageAssetPath = gridIcons[title] ?? 'assets/images/others/jesus.jpg';

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();

        // ቆፀራ ናይቶም 6 ዋናታት ዓውድታት (Category clicks) ምምዝጋብ
        AnalyticsService.track('category_clicked', {
          'category_name': title,
        });

        Navigator.push(context,
            SlowCupertinoPageRoute(builder: (context) => destinationPage));
      },
      borderRadius: BorderRadius.circular(45), // ነቲ ክቢ ቅርፂ (Round design) ንምምፃእ
      child: Container(
        clipBehavior: Clip
            .antiAlias, // ነቲ ባር ኣብ ውሽጢ እቲ ዝተኮርነተ ዙርያ ጥራይ ንምዕቃብ (Anti-aliasing)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          image: DecorationImage(
            image: AssetImage(imageAssetPath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // እታ ኣብ ታሕተዋይ ክፋል ጋድም ኢላ እትርከብ ቀይሕ ባር (Low-opacity RED overlay bar)
            Positioned(
              bottom: 12, // ምስቲ ስእሊ ብልክዕ ዝሰማማዕ ኣቀማምጣ
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E)
                      .withOpacity(0.45), // ትሑት ኦፓሲቲ ዘለዎ ቀይሕ ሕብሪ (55%)
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nyala',
                    fontSize: 16.5, // ፅፉፍን ሚዛናውን ዝኾነ ፎንት ሳይዝ
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// Rotating Rosary Spinner
// =======================================================================
class RotatingRosarySpinner extends StatefulWidget {
  final double size;
  final Color color;
  final bool showCross;

  const RotatingRosarySpinner({
    super.key,
    this.size = 150,
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

    // 1. እቲ መስቀል ዝያዳ ገፊሕ ንክኸውን (Stroke: 6.0)
    final crossPaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;

    // ቀጥታዊ መስመር (Vertical bar)
    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.45),
      Offset(centerX, centerY + size.height * 0.45),
      crossPaint,
    );

    // ጋድም መስመር (Horizontal bar)
    canvas.drawLine(
      Offset(centerX - size.width * 0.35, centerY - size.height * 0.15),
      Offset(centerX + size.width * 0.35, centerY - size.height * 0.15),
      crossPaint,
    );

    // 2. ስእሊ ክርስቶስ ኣብ ልዕሊ እቲ መስቀል (Crucifix figure in white)
    final bodyFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final bodyLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double intersectionY = centerY - size.height * 0.15;

    // ሀ. ርእሲ ክርስቶስ (Head)
    final Offset headCenter =
        Offset(centerX, intersectionY - size.height * 0.12);
    canvas.drawCircle(headCenter, size.width * 0.05, bodyFillPaint);

    // ለ. ሰብነት/ደረት (Torso)
    final torsoPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, intersectionY - size.height * 0.06),
      Offset(centerX, intersectionY + size.height * 0.14),
      torsoPaint,
    );

    // ሐ. ዝተዘርግሑ ኣእዳው (Stretched Arms)
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

    // መ. ልስሉስ ቐስቲ ዝኾነ መዓጠብ ጨርቂ (Elegant curved loincloth sash wrapping around hips)
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

    // ረ. ኣእጋር (Legs - slightly tapered)
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
