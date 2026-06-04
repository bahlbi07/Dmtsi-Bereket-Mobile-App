import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meadi_tsga/data/prayer_content_data.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import 'package:meadi_tsga/favorites_manager.dart';
import '../app_colors.dart';
import '../utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

// Helper function needed in this file
String? _getSafeTitle(Map<dynamic, dynamic> item) {
  if (item['content'] is Map) {
    final content = item['content'] as Map;
    if (content['title'] is String) {
      return content['title'] as String;
    }
  }
  return null;
}

// =======================================================================
// Screen 1: Main list of prayer categories with New UI/UX (Search replaced with image)
// =======================================================================
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  // ንእንግሊዘኛ ንኡስ ፅሑፋት (Subtitles) ዝጠቅም ማእኸላይ መዛመዲ (Mapping Map)
  final Map<String, String> _categorySubtitles = {
    'መባእታ ናይ ትምህርተ ክርስቶስ': '',
    'ፀሎት መቑፀርያ': '',
    'ፍኖተ መስቀል': '',
    'ፀሎት መቑፀርያ መንፈስ ቅዱስ': '',
    'ፀሎት ናብ መለኮታዊ ምሕረት': '',
    'ፀሎት ናብ ልቢ እየሱስ': '',
    'መቑፀርያ ቅዱስ ልቢ': '',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleLiturgyTap(
      BuildContext context, Map<String, dynamic> category) async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dayOfWeek = now.weekday;
    final hour = now.hour;

    // Sunday from 6:00 (12:00 morning Eth time) up to 10:59 (just before 5:00 morning Eth time)
    bool isLiturgyTime =
        (dayOfWeek == DateTime.sunday && hour >= 6 && hour < 11);

    if (isLiturgyTime) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('❤️ ምሕዝነታዊ ምኽሪ ❤️',
                style: TextStyle(
                    fontFamily: 'Nyala',
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            content: const Text(
              "ኣብዚ ናይ ቅዳሴ ሰዓት፡ ስርዓተ ቅዳሴ ብሞባይል ምኽትታል ንኣቓልቦኻን ንኣቓልቦ ካልኦት ምእመናንን ክዘርግ ይኽእል እዩ。\n\nምሉእ በረኸት ንምርካብ፡ በጃኻ ብኣካል፡ ብመፅሓፍ፡ ወይ በቲ ኣብ ቤተ-ክርስትያን ዝርከብ መሳርሒ ተጠቒምካ ተኸታተለ。\n\nፍሉይ ምኽንያት እንተለካ ጥራይ 'ይቕፀል' ብምባል ክትጥቀመሉ ትኽእል ኢኻ።",
              style: TextStyle(fontFamily: 'Nyala', fontSize: 18, height: 1.6),
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('ተረዲአ',
                      style: TextStyle(fontFamily: 'Nyala', fontSize: 18)),
                  onPressed: () => Navigator.of(dialogContext).pop()),
              ElevatedButton(
                  child: const Text('ይቐፅል',
                      style: TextStyle(fontFamily: 'Nyala', fontSize: 18)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToLiturgyContent(context, category);
                  }),
            ],
          );
        },
      );
    } else {
      _navigateToLiturgyContent(context, category);
    }
  }

  void _navigateToLiturgyContent(
      BuildContext context, Map<String, dynamic> category) {
    HapticFeedback.lightImpact();
    final String categoryTitle = category['title'] as String;
    final List<String> prayerKeys =
        List<String>.from(category['itemKeys'] ?? []);

    Navigator.push(
      context,
      SlowCupertinoPageRoute(
        builder: (context) => PrayerContentViewer(
          categoryTitle: categoryTitle,
          prayerKeys: prayerKeys,
          initialIndex: 0,
          displayMode: PrayerDisplayMode.pageView,
        ),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. ናይ ላዕሊ ኣፕባር (AppBar with back chevron with 38.0 Padding)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      'ጸሎት መቑፀርያ',
                      style: TextStyle(
                        fontFamily: 'Nyala',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. እታ "prayer" ዝስማ ምስሊ ዝሓዘት ሓዳስ ፃዕዳ ካርድ (Replaced search bar)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 38.0, vertical: 10.0),
                child: Container(
                  height: 200, // Elegant landscape image container height
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12), // Border Padding
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/prayers/prayer.jpg', // Main asset target
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Nested Fallback logic if asset is .jpg instead of .png
                        return Image.asset(
                          'assets/images/prayers/prayer.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.church_rounded,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. እቶም ናይ ጸሎታት ካርዳት (List of Prayer Cards with 38.0 Padding)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
                itemCount: prayerListItems.length,
                itemBuilder: (context, index) {
                  final category = prayerListItems[index];
                  return _buildCategoryItem(context, category, index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, Map<String, dynamic> category, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ንእንግሊዘኛ ንኡስ ፅሑፍ ካብቲ ማፕ ይወስድ
    final subtitle = _categorySubtitles[category['title']] ?? '';

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                final String type = category['type'] as String;

                if (type == 'liturgy') {
                  _handleLiturgyTap(context, category);
                  return;
                }

                HapticFeedback.lightImpact();
                final String categoryTitle = category['title'] as String;
                final List<String> prayerKeys =
                    List<String>.from(category['itemKeys'] ?? []);
                final String? headerImage = category['headerImage'] as String?;

                if (type == 'swipeable_page') {
                  Navigator.push(
                    context,
                    SlowCupertinoPageRoute(
                      builder: (context) => PrayerContentViewer(
                        categoryTitle: categoryTitle,
                        prayerKeys: prayerKeys,
                        initialIndex: 0,
                        displayMode: PrayerDisplayMode.tabs,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    SlowCupertinoPageRoute(
                      builder: (context) => PrayerSubCategoryScreen(
                        categoryTitle: categoryTitle,
                        prayerKeys: prayerKeys,
                        headerImagePath: headerImage,
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : const Color(0xFFF0F0F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          category['icon'] as IconData? ?? Icons.church,
                          size: 28,
                          color: const Color(0xFFC61B1B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['title']!,
                            style: TextStyle(
                              fontFamily: 'Nyala',
                              fontSize: 18.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC61B1B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
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

// =======================================================================
// Screen 2: Sub-category list with dynamic uncropped header image
// =======================================================================
class PrayerSubCategoryScreen extends StatelessWidget {
  final String categoryTitle;
  final List<String> prayerKeys;
  final String? headerImagePath;

  const PrayerSubCategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.prayerKeys,
    this.headerImagePath,
  });

  static const Map<String, String> prayerSubtitles = {
    'ናይ ደስታ ምስጢር': '(ሰኑይን ቀዳምን)',
    'ናይ ብርሃን ምስጢር': '(ሓሙስ)',
    'ናይ ሕማም ምስጢር': '(ሰሉስን ዓርብን)',
    'ናይ ክብሪ ምስጢር': '(ረቡዕን ሰንበትን)',
  };

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

            // 1. ናይ ላዕሊ ኣፕባር (Custom Header with 38.0 Margins)
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
                  Expanded(
                    child: Text(
                      categoryTitle,
                      style: const TextStyle(
                        fontFamily: 'Nyala',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  // 2. Full Header Image Box (Height 300, BoxFit.contain to prevent cropping)
                  if (headerImagePath != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 38.0, vertical: 10.0),
                        child: Container(
                          height: 300, // Taller image box
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(
                              16), // Padding to safely render portrait images inside
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              headerImagePath!,
                              fit: BoxFit.contain, // Fits entire image cleanly
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 3. Subcategory List Cards
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(38.0, 10.0, 38.0, 80.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final prayerTitle = prayerKeys[index];
                          final isMystery = prayerTitle.contains("ምስጢር");
                          final subtitle = prayerSubtitles[prayerTitle] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                if (isMystery) {
                                  List<String> mysteryParts;
                                  if (prayerTitle == 'ናይ ደስታ ምስጢር') {
                                    mysteryParts = rosaryJoyfulPrayerContent
                                        .map((item) => _getSafeTitle(item))
                                        .whereType<String>()
                                        .toList();
                                  } else if (prayerTitle == 'ናይ ብርሃን ምስጢር') {
                                    mysteryParts = rosaryLuminousPrayerContent
                                        .map((item) => _getSafeTitle(item))
                                        .whereType<String>()
                                        .toList();
                                  } else if (prayerTitle == 'ናይ ሕማም ምስጢር') {
                                    mysteryParts = rosarySorrowfulPrayerContent
                                        .map((item) => _getSafeTitle(item))
                                        .whereType<String>()
                                        .toList();
                                  } else {
                                    mysteryParts = rosaryGloriousPrayerContent
                                        .map((item) => _getSafeTitle(item))
                                        .whereType<String>()
                                        .toList();
                                  }

                                  mysteryParts.add("መዛዘሚ ፀሎታት");

                                  Navigator.push(
                                    context,
                                    SlowCupertinoPageRoute(
                                      builder: (context) => PrayerContentViewer(
                                        categoryTitle: prayerTitle,
                                        prayerKeys: mysteryParts,
                                        initialIndex: 0,
                                        displayMode: PrayerDisplayMode.tabs,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    SlowCupertinoPageRoute(
                                      builder: (context) => PrayerContentViewer(
                                        categoryTitle: categoryTitle,
                                        prayerKeys: prayerKeys,
                                        initialIndex: index,
                                        displayMode: PrayerDisplayMode.pageView,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey.shade800
                                            : const Color(0xFFF0F0F2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: isMystery
                                            ? const Icon(Icons.brightness_5,
                                                color: Color(0xFFC61B1B),
                                                size: 24)
                                            : Text(
                                                '0${index + 1}',
                                                style: const TextStyle(
                                                  fontFamily: 'Nyala',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFC61B1B),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prayerTitle,
                                            style: TextStyle(
                                              fontFamily: 'Nyala',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitle,
                                            style: const TextStyle(
                                              fontFamily: 'Nyala',
                                              fontSize: 14,
                                              color: Color(0xFFC61B1B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: prayerKeys.length,
                      ),
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

enum PrayerDisplayMode { tabs, pageView }

// =======================================================================
// Screen 3: Viewer with Custom Horizontal Pill Tabs
// =======================================================================
class PrayerContentViewer extends StatefulWidget {
  final String categoryTitle;
  final List<String> prayerKeys;
  final int initialIndex;
  final PrayerDisplayMode displayMode;

  const PrayerContentViewer({
    super.key,
    required this.categoryTitle,
    required this.prayerKeys,
    required this.initialIndex,
    required this.displayMode,
  });

  @override
  State<PrayerContentViewer> createState() => _PrayerContentViewerState();
}

class _PrayerContentViewerState extends State<PrayerContentViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  late int _currentIndex;
  final FavoritesManager _favoritesManager = FavoritesManager();
  late DateTime _startTime; // ቆፀራ ግዘ

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // ግዘ ምጅማር
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _tabController = TabController(
        length: widget.prayerKeys.length,
        vsync: this,
        initialIndex: _currentIndex);

    // 🌟 ዜሮ ቆፀራ ጸገም ንምፍታሕ፦ ገጽ ኣብ ዝተኸፈተሉ ቕጽበት እቨንት ምምዝጋብ
    _trackViewDetail(_currentIndex);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _currentIndex) {
        updateIndex(_tabController.index);
      }
    });
  }

  void _trackViewDetail(int index) {
    AnalyticsService.track('view_detail', {
      'category': 'ዝተፈላለዩ ፀሎታት',
      'title': widget.prayerKeys[index],
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();

    // ጸሎት ዝጸንሑሉ ሰኮንዶች ምዝገባ (Time Spent on Content)
    final int secondsSpent = DateTime.now().difference(_startTime).inSeconds;
    AnalyticsService.track('time_spent_on_detail', {
      'category': 'ዝተፈላለዩ ፀሎታት',
      'title': widget.prayerKeys[_currentIndex],
      'seconds': secondsSpent,
    });

    super.dispose();
  }

  void updateIndex(int index) {
    if (_currentIndex != index && mounted) {
      // ሓድሽ ጸሎት ክቕየር ከሎ ነቲ ዝነበረ ግዘ መዝጊብና ሓድሽ ግዘ ንጅምር
      final int secondsSpent = DateTime.now().difference(_startTime).inSeconds;
      AnalyticsService.track('time_spent_on_detail', {
        'category': 'ዝተፈላለዩ ፀሎታት',
        'title': widget.prayerKeys[_currentIndex],
        'seconds': secondsSpent,
      });

      setState(() {
        _currentIndex = index;
        _startTime = DateTime.now(); // ሓድሽ ግዘ ምጅማር
        _tabController.animateTo(index);

        // 🌟 ገጽ ክቕየር ከሎ ሓዱሽ እቨንት ምዝገባ
        _trackViewDetail(index);

        if (widget.displayMode == PrayerDisplayMode.pageView) {
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        }
      });
    }
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final hasPermission =
        await _favoritesManager.checkAndShowPermissionDialog(context);
    if (!hasPermission || !mounted) return;

    final currentPrayerTitle = widget.prayerKeys[_currentIndex];
    final favoriteId = 'prayer_$currentPrayerTitle';

    final favoriteItem = FavoriteItem(
      id: favoriteId,
      type: FavoriteType.prayer,
      content: {
        'title': currentPrayerTitle,
        'parentTitle': widget.categoryTitle,
      },
      dateAdded: DateTime.now(),
    );

    // ቶፕ ዝተፈተዉ ምምዝጋብ
    if (!_favoritesManager.isFavorite(favoriteId)) {
      AnalyticsService.track('favorite_added', {
        'category': 'ዝተፈላለዩ ፀሎታት',
        'title': currentPrayerTitle,
      });
    }

    await _favoritesManager.toggleFavorite(favoriteItem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.prayerKeys.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.categoryTitle)),
          body: const Center(
              child: Text("ትሕዝቶ የለን",
                  style: TextStyle(fontFamily: 'Nyala', fontSize: 18))));
    }

    final currentPrayerTitle = widget.prayerKeys[_currentIndex];
    final favoriteId = 'prayer_$currentPrayerTitle';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);

    final bool showNavigationArrows =
        widget.displayMode == PrayerDisplayMode.pageView &&
            widget.prayerKeys.length > 1;
    final bool useTabs = widget.displayMode == PrayerDisplayMode.tabs;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        centerTitle: false,
        title: Text(
          useTabs ? widget.categoryTitle : currentPrayerTitle,
          style: TextStyle(
            fontFamily: 'Nyala',
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
                isCurrentlyFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 26),
            color: isCurrentlyFavorite
                ? const Color(0xFFC61B1B)
                : (isDark ? Colors.white70 : Colors.black54),
            onPressed: _toggleFavorite,
          ),
          if (showNavigationArrows)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: _currentIndex > 0
                  ? () => updateIndex(_currentIndex - 1)
                  : null,
            ),
          if (showNavigationArrows)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              onPressed: _currentIndex < widget.prayerKeys.length - 1
                  ? () => updateIndex(_currentIndex + 1)
                  : null,
            ),
          const SizedBox(width: 20),
        ],
        bottom: useTabs && widget.prayerKeys.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      indicator: const BoxDecoration(),
                      onTap: (index) => updateIndex(index),
                      tabs: widget.prayerKeys.map((key) {
                        final isSelected =
                            widget.prayerKeys[_currentIndex] == key;
                        return Tab(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFC61B1B)
                                  : (isDark
                                      ? Colors.grey.shade800
                                      : const Color(0xFFE5E5E5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              key,
                              style: TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: useTabs
          ? TabBarView(
              controller: _tabController,
              children: widget.prayerKeys.map((key) {
                final contentKey =
                    key == "መዛዘሚ ፀሎታት" ? "rosary_conclusion" : key;
                return PrayerDetailPage(
                    contentBlocks: allPrayersContent[contentKey] ?? []);
              }).toList(),
            )
          : PageView.builder(
              controller: _pageController,
              itemCount: widget.prayerKeys.length,
              onPageChanged: (index) => updateIndex(index),
              itemBuilder: (context, index) {
                final key = widget.prayerKeys[index];
                return PrayerDetailPage(
                    contentBlocks: allPrayersContent[key] ?? []);
              },
            ),
    );
  }
}

// =======================================================================
// Screen 4: Detail screen with expanded uncropped portrait-safe images (Sequential Inline Rendering)
// =======================================================================
class PrayerDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> contentBlocks;

  const PrayerDetailPage({super.key, required this.contentBlocks});

  @override
  Widget build(BuildContext context) {
    if (contentBlocks.isEmpty) {
      return const Center(
          child: Text("ትሕዝቶ ኣይተረኽበን።",
              style: TextStyle(fontFamily: 'Nyala', fontSize: 20)));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> sequentialWidgets = [];
    List<Map<String, dynamic>> currentTextGroup = [];

    // Loop through blocks sequentially to preserve database structure
    for (var block in contentBlocks) {
      final String type = block['type'] ?? 'paragraph';

      if (type == 'image') {
        // If there are accumulated text blocks, render them in a clean Text Card first
        if (currentTextGroup.isNotEmpty) {
          sequentialWidgets
              .add(_buildTextCard(context, currentTextGroup, isDark));
          sequentialWidgets.add(const SizedBox(height: 16));
          currentTextGroup = [];
        }
        // Build and append the inline image container
        sequentialWidgets.add(_buildImageBlock(context, block));
        sequentialWidgets.add(const SizedBox(height: 16));
      } else {
        currentTextGroup.add(block);
      }
    }

    // Append any remaining text blocks
    if (currentTextGroup.isNotEmpty) {
      sequentialWidgets.add(_buildTextCard(context, currentTextGroup, isDark));
    }

    // Clean up trailing vertical spacing
    if (sequentialWidgets.isNotEmpty && sequentialWidgets.last is SizedBox) {
      sequentialWidgets.removeLast();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 38.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...sequentialWidgets,
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Unified Text Container Card preserving the exact original container UI/UX styles
  Widget _buildTextCard(BuildContext context,
      List<Map<String, dynamic>> textBlocks, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: textBlocks
            .map((txtBlock) => _buildContentBlock(context, txtBlock))
            .toList(),
      ),
    );
  }

  // Expanded Container with BoxFit.contain to fully display portrait/landscape images safely
  Widget _buildImageBlock(BuildContext context, Map<String, dynamic> block) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height:
          300, // Slightly taller height to accommodate vertical aspect ratios
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(
          16), // Padding to safely border the portrait bounds within the card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(
          block['path'] as String,
          fit: BoxFit
              .contain, // Renders the complete, uncropped portrait photo freely
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image_not_supported_rounded,
                color: Colors.grey.shade400,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentBlock(BuildContext context, Map<String, dynamic> block) {
    final String type = block['type'] ?? 'paragraph';

    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
          child: Text(
            block['text'].toString(),
            style: const TextStyle(
                fontFamily: 'Nyala',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC61B1B)),
          ),
        );
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Text(
            block['text'].toString(),
            style: const TextStyle(
                fontFamily: 'Nyala', fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      case 'prompt':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFC61B1B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                block['text'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Nyala',
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFC61B1B),
                    fontSize: 17),
              ),
            ),
          ),
        );
      case 'separator':
        return const Divider(
            height: 36, thickness: 0.5, indent: 10, endIndent: 10);
      case 'paragraph':
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SelectableText.rich(
            TextSpan(
                children: _buildTextSpans(block['text'].toString(), context)),
            textAlign: TextAlign.start,
          ),
        );
    }
  }

  List<TextSpan> _buildTextSpans(String text, BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(
        fontFamily: 'Nyala',
        fontSize: 18,
        height: 1.6,
        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9));
    final boldStyle = baseStyle.copyWith(
        fontWeight: FontWeight.bold, color: const Color(0xFFC61B1B));
    List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    for (final Match match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      final group = match.group(1);
      if (group != null) {
        spans.add(TextSpan(text: group, style: boldStyle));
      }
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }
    return spans;
  }
}
