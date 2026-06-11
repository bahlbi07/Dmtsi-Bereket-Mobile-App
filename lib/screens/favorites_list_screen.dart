import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import 'package:meadi_tsga/favorites_manager.dart';
import 'package:meadi_tsga/premium_ui.dart';

// Screens
import 'package:meadi_tsga/screens/prayer_content_screen.dart';
import 'package:meadi_tsga/screens/quotes_of_saint_screen.dart';
import 'package:meadi_tsga/screens/saints_history_screen.dart';
import 'package:meadi_tsga/screens/church_history_screen.dart';
import 'package:meadi_tsga/screens/doctrine_screen.dart';
import 'package:meadi_tsga/screens/spiritual_life_screen.dart';

import 'package:meadi_tsga/data/quotes_of_saint_data.dart';
import 'package:meadi_tsga/data/prayer_content_data.dart';
import '../data/doctrine_data.dart';

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
// Screen 1: Favorites Category List (ዝተመሓየሸ)
// =======================================================================
class FavoritesCategoryScreen extends StatelessWidget {
  const FavoritesCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // እቶም ምስቲ ሆም ፔጅ ተመሳሰልቲ ዝተገበሩ ናይ ምስሊ ኣይኮናት
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'ዝተፈተዉ ጸሎታት',
        'imagePath': 'assets/icons/All_Prayer.jpg',
        'type': FavoriteType.prayer
      },
      {
        'title': 'ዝተፈተዉ ጥቕስታት',
        'imagePath': 'assets/icons/quotes.jpg',
        'type': FavoriteType.quote
      },
      {
        'title': 'ታሪኽ ቅዱሳን',
        'imagePath': 'assets/icons/sainthistory.jpg',
        'type': FavoriteType.saintsHistory
      },
      {
        'title': 'ታሪኽ ቤተ-ክርስትያን',
        'imagePath': 'assets/icons/Churchhistory.jpg',
        'type': FavoriteType.churchHistory
      },
      {
        'title': 'ትምህርተ ሃይማኖት',
        'imagePath': 'assets/icons/doctrine.png',
        'type': FavoriteType.doctrine
      },
      {
        'title': 'መንፈሳዊ ህይወት',
        'imagePath': 'assets/icons/spirituallife.png',
        'type': FavoriteType.spiritualLife
      },
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F2ED),
      body: SafeArea(
        child: Column(
          children: [
            buildPremiumPageHeader(context,
                title: 'ዝፈተኽዎም (Favorites)',
                isDark: isDark,
                showBackButton: false), // 🌟 ሓዱሽ ዝተወሰኸ
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            decoration: buildPremiumCardDecoration(isDark),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              splashColor: const Color(0xFFC61B1B)
                                  .withValues(alpha: 0.05),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlowCupertinoPageRoute(
                                    builder: (context) => FavoritesListScreen(
                                        favoriteType: category['type']),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 14.0),
                                child: Row(
                                  children: [
                                    buildPremiumIconContainer(
                                      isDark: isDark,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          category['imagePath'],
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        category['title'],
                                        style: TextStyle(
                                            fontFamily: 'Nyala',
                                            fontSize: 17.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? const Color(0xFFEEEEEE)
                                                : Colors.black87),
                                      ),
                                    ),
                                    buildPremiumChevronButton(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
// Screen 2: Detailed Favorites Category List Items (ዝተመሓየሸ)
// =======================================================================
class FavoritesListScreen extends StatefulWidget {
  final FavoriteType favoriteType;
  const FavoritesListScreen({super.key, required this.favoriteType});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  late List<FavoriteItem> _favoriteItems;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _favoritesManager.favoritesNotifier.addListener(_loadFavorites);
  }

  @override
  void dispose() {
    _favoritesManager.favoritesNotifier.removeListener(_loadFavorites);
    super.dispose();
  }

  void _loadFavorites() {
    if (mounted) {
      setState(() {
        _favoriteItems = _favoritesManager.getFavorites(widget.favoriteType);
      });
    }
  }

  String _getAppBarTitle() {
    const titles = {
      FavoriteType.prayer: 'ዝተፈተዉ ጸሎታት',
      FavoriteType.quote: 'ዝተፈተዉ ጥቕስታት',
      FavoriteType.saintsHistory: 'ታሪኽ ቅዱሳን',
      FavoriteType.churchHistory: 'ታሪኽ ቤተ-ክርስትያን',
      FavoriteType.doctrine: 'ትምህርተ ሃይማኖት',
      FavoriteType.spiritualLife: 'መንፈሳዊ ህይወት',
    };
    return titles[widget.favoriteType] ?? 'ዝፈተኽዎም';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F2ED),
      body: SafeArea(
        child: Column(
          children: [
            buildPremiumPageHeader(
              context,
              title: _getAppBarTitle(),
              isDark: isDark,
            ),
            Expanded(
              child: _favoriteItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('ኣብዚ ዝተመዝገበ የለን',
                              style:
                                  TextStyle(fontFamily: 'Nyala', fontSize: 20)),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                        itemCount: _favoriteItems.length,
                        itemBuilder: (context, index) {
                          final item = _favoriteItems[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildFavoriteTile(context, item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteTile(BuildContext context, FavoriteItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String title = item.content['title'] ?? '...';
    String subtitle = '';
    Widget? detailScreen;

    // ንነፍሲ ወከፍ ዓውዲ ምስቲ ሆም ፔጅ ዘተሓሳስብ ናይ ምስሊ ኣይኮን ፓዝ (Path)
    final Map<FavoriteType, String> categoryImages = {
      FavoriteType.prayer: 'assets/icons/All_Prayer.jpg',
      FavoriteType.quote: 'assets/icons/quotes.jpg',
      FavoriteType.saintsHistory: 'assets/icons/sainthistory.jpg',
      FavoriteType.churchHistory: 'assets/icons/Churchhistory.jpg',
      FavoriteType.doctrine: 'assets/icons/doctrine.png',
      FavoriteType.spiritualLife: 'assets/icons/spirituallife.png',
    };

    final String imagePath =
        categoryImages[item.type] ?? 'assets/images/others/jesus.jpg';

    switch (item.type) {
      case FavoriteType.prayer:
        subtitle = item.content['parentTitle'] ?? '';
        try {
          final String prayerTitle = item.content['title'];
          final String? categoryTitle = item.content['parentTitle'];

          List<String> prayerKeys;
          final bool isMysteryPart = (categoryTitle ?? '').contains('ምስጢር');

          if (isMysteryPart) {
            if (categoryTitle == 'ናይ ደስታ ምስጢር') {
              prayerKeys = rosaryJoyfulPrayerContent
                  .map((item) => _getSafeTitle(item))
                  .whereType<String>()
                  .toList();
            } else if (categoryTitle == 'ናይ ብርሃን ምስጢር') {
              prayerKeys = rosaryLuminousPrayerContent
                  .map((item) => _getSafeTitle(item))
                  .whereType<String>()
                  .toList();
            } else if (categoryTitle == 'ናይ ሕማም ምስጢር') {
              prayerKeys = rosarySorrowfulPrayerContent
                  .map((item) => _getSafeTitle(item))
                  .whereType<String>()
                  .toList();
            } else {
              prayerKeys = rosaryGloriousPrayerContent
                  .map((item) => _getSafeTitle(item))
                  .whereType<String>()
                  .toList();
            }
            prayerKeys.add("መዛዘሚ ጸሎታት");
          } else {
            final categoryData = prayerListItems.firstWhere(
              (category) => category['title'] == categoryTitle,
              orElse: () => {},
            );
            prayerKeys = categoryData.isNotEmpty
                ? List<String>.from(categoryData['itemKeys'])
                : [prayerTitle];
          }

          final int initialIndex = prayerKeys.indexOf(prayerTitle);

          if (initialIndex != -1) {
            detailScreen = PrayerContentViewer(
              categoryTitle: categoryTitle ?? 'ጸሎታት',
              prayerKeys: prayerKeys,
              initialIndex: initialIndex,
              displayMode: isMysteryPart
                  ? PrayerDisplayMode.tabs
                  : PrayerDisplayMode.pageView,
            );
          }
        } catch (e) {
          detailScreen = null;
        }
        break;

      case FavoriteType.quote:
        title =
            '"${(item.content['quote'] as String).substring(0, (item.content['quote'] as String).length > 30 ? 30 : (item.content['quote'] as String).length)}..."';
        subtitle = item.content['author'] ?? 'Unknown';
        final List<String> allTopics =
            quotesContentData.keys.map((e) => e.toString()).toList();
        final initialIndex = allTopics.indexOf(item.content['topic']);
        if (initialIndex != -1) {
          detailScreen = QuotesViewerScreen(
              allTopics: allTopics, initialIndex: initialIndex);
        }
        break;

      case FavoriteType.saintsHistory:
        subtitle = 'ታሪኽ ቅዱሳን';
        final allHeadings =
            (FavoritesManager.getSaintHeadings(title) ?? [title]);
        final initialIndex =
            allHeadings.indexOf(item.content['heading'] ?? title);
        detailScreen = SaintSectionViewerScreen(
          saintName: title,
          allHeadings: allHeadings,
          initialIndex: initialIndex >= 0 ? initialIndex : 0,
        );
        break;

      case FavoriteType.doctrine:
        subtitle = 'ትምህርተ ሃይማኖት';
        final mainTopicTitle = item.content['mainTopicTitle'] as String;
        final mainTopicKey = doctrineTopics.firstWhere(
            (t) => t['title'] == mainTopicTitle,
            orElse: () => {})['key'];
        final allSubTopics = doctrineDetailsContent[mainTopicKey] ?? [];
        final initialIndex =
            allSubTopics.indexWhere((st) => st['title'] == title);
        if (initialIndex != -1) {
          detailScreen = DoctrineViewerScreen(
            mainTopicTitle: mainTopicTitle,
            subTopics: allSubTopics,
            initialIndex: initialIndex,
          );
        }
        break;

      case FavoriteType.churchHistory:
      case FavoriteType.spiritualLife:
        subtitle = item.content['categoryTitle'] ?? '...';
        final List<Map<String, dynamic>> allTopics =
            FavoritesManager.getTopicsForCategory(item.type);
        final int initialIndex = allTopics
            .indexWhere((topic) => (topic['title'] as String) == title);
        if (initialIndex != -1) {
          if (item.type == FavoriteType.churchHistory) {
            detailScreen = ChurchHistoryViewerScreen(
                allTopics: allTopics, initialIndex: initialIndex);
          } else {
            detailScreen = SpiritualLifeViewerScreen(
                allTopics: allTopics, initialIndex: initialIndex);
          }
        }
        break;
    }

    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(title,
            style: TextStyle(
                fontFamily: 'Nyala',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle,
                style: const TextStyle(
                    fontFamily: 'Nyala',
                    fontSize: 14,
                    color: Color(0xFFC61B1B)))
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: Colors.red, size: 22),
          onPressed: () => _favoritesManager.toggleFavorite(item),
        ),
        onTap: () {
          if (detailScreen != null) {
            Navigator.push(context,
                SlowCupertinoPageRoute(builder: (context) => detailScreen!));
          }
        },
      ),
    );
  }
}
