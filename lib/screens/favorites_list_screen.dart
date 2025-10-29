// lib/screens/favorites_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dmtsibereket/app_colors.dart';
import 'package:dmtsibereket/custom_page_route.dart';
import 'package:dmtsibereket/favorites_manager.dart';

// Screens
import 'package:dmtsibereket/screens/lyrics_screen.dart';
import 'package:dmtsibereket/screens/prayer_content_screen.dart';
import 'package:dmtsibereket/screens/quotes_of_saint_screen.dart';
import 'package:dmtsibereket/screens/saints_history_screen.dart';
import 'package:dmtsibereket/screens/church_history_screen.dart';
import 'package:dmtsibereket/screens/doctrine_screen.dart';
import 'package:dmtsibereket/screens/bible_tradition_screen.dart';
import 'package:dmtsibereket/screens/social_teaching_screen.dart';
import 'package:dmtsibereket/screens/spiritual_life_screen.dart';

// Data and Models
import 'package:dmtsibereket/data/doctrine_data.dart';
import 'package:dmtsibereket/data/quotes_of_saint_data.dart';
import 'package:dmtsibereket/data/prayer_content_data.dart';

// Helper function needed for this file
String? _getSafeTitle(Map<dynamic, dynamic> item) {
  if (item['content'] is Map) {
    final content = item['content'] as Map;
    if (content['title'] is String) {
      return content['title'] as String;
    }
  }
  return null;
}

class FavoritesCategoryScreen extends StatelessWidget {
  const FavoritesCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> categories = [
      {'title': 'ዝተፈተዉ መዛሙር', 'icon': Icons.music_note_rounded, 'color': Colors.blue.shade700, 'type': FavoriteType.hymn},
      {'title': 'ዝተፈተዉ ፀሎታት', 'icon': Icons.church_rounded, 'color': Colors.teal.shade600, 'type': FavoriteType.prayer},
      {'title': 'ዝተፈተዉ ጥቕስታት', 'icon': Icons.format_quote_rounded, 'color': Colors.purple.shade600, 'type': FavoriteType.quote},
      {'title': 'ታሪኽ ቅዱሳን', 'icon': Icons.person_rounded, 'color': Colors.brown.shade600, 'type': FavoriteType.saintsHistory},
      {'title': 'ታሪኽ ቤተ-ክርስትያን', 'icon': Icons.auto_stories_rounded, 'color': Colors.indigo.shade600, 'type': FavoriteType.churchHistory},
      {'title': 'ትምህርተ ሃይማኖት', 'icon': Icons.school_rounded, 'color': Colors.deepPurple.shade600, 'type': FavoriteType.doctrine},
      {'title': 'መፅሓፍ ቅዱስን ትውፊትን', 'icon': Icons.menu_book_rounded, 'color': Colors.green.shade800, 'type': FavoriteType.bibleTradition},
      {'title': 'ማሕበራዊ ትምህርቲ', 'icon': Icons.groups_rounded, 'color': Colors.orange.shade800, 'type': FavoriteType.socialTeaching},
      {'title': 'መንፈሳዊ ህይወት', 'icon': Icons.spa_rounded, 'color': Colors.amber.shade700, 'type': FavoriteType.spiritualLife},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('ንዋየ-ልበይ (Favorites)', style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Icon(category['icon'], color: category['color'], size: 30),
                        title: Text(
                          category['title'],
                          style: GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            SlowCupertinoPageRoute(
                              builder: (context) => FavoritesListScreen(favoriteType: category['type']),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

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
      FavoriteType.hymn: 'ዝተፈተዉ መዛሙር',
      FavoriteType.prayer: 'ዝተፈተዉ ፀሎታት',
      FavoriteType.quote: 'ዝተፈተዉ ጥቕስታት',
      FavoriteType.saintsHistory: 'ታሪኽ ቅዱሳን',
      FavoriteType.churchHistory: 'ታሪኽ ቤተ-ክርስትያን',
      FavoriteType.doctrine: 'ትምህርተ ሃይማኖት',
      FavoriteType.bibleTradition: 'መፅሓፍ ቅዱስን ትውፊትን',
      FavoriteType.socialTeaching: 'ማሕበራዊ ትምህርቲ',
      FavoriteType.spiritualLife: 'መንፈሳዊ ህይወት',
    };
    return titles[widget.favoriteType] ?? 'ንዋየ-ልበይ';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'ዝተዓቀበ ንዋየ-ልቢ የለን',
            style: GoogleFonts.notoSerifEthiopic(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'ሓደ ነገር ንምዕቃብ፡ ኣብ ጎድኑ ዘላ\nምልክት ልቢ (❤️) ጠውቕ።',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifEthiopic(fontSize: 15, color: Colors.grey[500]),
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
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: _favoriteItems.isEmpty
            ? _buildEmptyState(context)
            : AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
    );
  }

  Widget _buildFavoriteTile(BuildContext context, FavoriteItem item) {
    final theme = Theme.of(context);
    String title = item.content['title'] ?? '...';
    String subtitle = '';
    Widget leadingIcon;
    Widget? detailScreen;

    switch (item.type) {
      case FavoriteType.hymn:
        subtitle = item.content['singer'] ?? '';
        leadingIcon = Icon(Icons.music_note_rounded, color: theme.primaryColor);
        detailScreen = LyricsScreen(hymn: item.content);
        break;

      case FavoriteType.prayer:
        subtitle = item.content['parentTitle'] ?? '';
        leadingIcon = Icon(Icons.church_rounded, color: theme.primaryColor);
        try {
          final String prayerTitle = item.content['title'];
          final String? categoryTitle = item.content['parentTitle'];

          List<String> prayerKeys;
          final bool isMysteryPart = (categoryTitle ?? '').contains('ምስጢር');

          if (isMysteryPart) {
            // Reconstruct the full list of 5 mystery parts + the conclusion
            if (categoryTitle == 'ናይ ደስታ ምስጢር') {
              prayerKeys = rosaryJoyfulPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
            } else if (categoryTitle == 'ናይ ብርሃን ምስጢር') {
              prayerKeys = rosaryLuminousPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
            } else if (categoryTitle == 'ናይ ሕማም ምስጢር') {
              prayerKeys = rosarySorrowfulPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
            } else { // 'ናይ ክብሪ ምስጢር'
              prayerKeys = rosaryGloriousPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
            }
            prayerKeys.add("መዛዘሚ ፀሎታት");
          } else {
             // Find the original list of keys for a normal category
            final categoryData = prayerListItems.firstWhere(
              (category) => category['title'] == categoryTitle,
              orElse: () => {},
            );
             prayerKeys = categoryData.isNotEmpty ? List<String>.from(categoryData['itemKeys']) : [prayerTitle];
          }
          
          final int initialIndex = prayerKeys.indexOf(prayerTitle);

          if (initialIndex != -1) {
            detailScreen = PrayerContentViewer(
              categoryTitle: categoryTitle ?? 'ፀሎታት',
              prayerKeys: prayerKeys,
              initialIndex: initialIndex,
              displayMode: isMysteryPart ? PrayerDisplayMode.tabs : PrayerDisplayMode.pageView,
            );
          }
        } catch (e) {
          debugPrint("Error reconstructing favorite prayer: $e");
          detailScreen = null;
        }
        break;

      case FavoriteType.quote:
        title = '"${(item.content['quote'] as String).substring(0, (item.content['quote'] as String).length > 30 ? 30 : (item.content['quote'] as String).length)}..."';
        subtitle = item.content['author'] ?? 'Unknown';
        leadingIcon = Icon(Icons.format_quote_rounded, color: theme.primaryColor);
        final List<String> allTopics = quotesContentData.keys.map((e) => e.toString()).toList();
        final initialIndex = allTopics.indexOf(item.content['topic']);
        if (initialIndex != -1) {
          detailScreen = QuotesViewerScreen(allTopics: allTopics, initialIndex: initialIndex);
        }
        break;

      case FavoriteType.saintsHistory:
        subtitle = 'ታሪኽ ቅዱሳን';
        leadingIcon = Icon(Icons.person_rounded, color: theme.primaryColor);
        final allHeadings = (FavoritesManager.getSaintHeadings(title) ?? [title]);
        final initialIndex = allHeadings.indexOf(item.content['heading'] ?? title);
        detailScreen = SaintSectionViewerScreen(
          saintName: title,
          allHeadings: allHeadings,
          initialIndex: initialIndex >= 0 ? initialIndex : 0,
        );
        break;

      case FavoriteType.doctrine:
        subtitle = item.content['mainTopicTitle'] ?? '';
        leadingIcon = Icon(Icons.school_outlined, color: theme.primaryColor);
        final mainTopicTitle = item.content['mainTopicTitle'] as String;
        final mainTopicKey = doctrineTopics.firstWhere((t) => t['title'] == mainTopicTitle, orElse: () => {})['key'];
        final allSubTopics = doctrineDetailsContent[mainTopicKey] ?? [];
        final initialIndex = allSubTopics.indexWhere((st) => st['title'] == title);
        if (initialIndex != -1) {
          detailScreen = DoctrineViewerScreen(
            mainTopicTitle: mainTopicTitle,
            subTopics: allSubTopics,
            initialIndex: initialIndex,
          );
        }
        break;
        
      case FavoriteType.churchHistory:
      case FavoriteType.bibleTradition:
      case FavoriteType.socialTeaching:
      case FavoriteType.spiritualLife:
        subtitle = item.content['categoryTitle'] ?? '...';
        leadingIcon = Icon(Icons.article_rounded, color: theme.primaryColor);
        final List<Map<String, dynamic>> allTopics = FavoritesManager.getTopicsForCategory(item.type);
        final int initialIndex = allTopics.indexWhere((topic) => (topic['title'] as String) == title);
        if (initialIndex != -1) {
          switch (item.type) {
            case FavoriteType.churchHistory:
              detailScreen = ChurchHistoryViewerScreen(allTopics: allTopics, initialIndex: initialIndex);
              break;
            case FavoriteType.bibleTradition:
              detailScreen = BibleTraditionViewerScreen(allTopics: allTopics, initialIndex: initialIndex);
              break;
            case FavoriteType.socialTeaching:
              detailScreen = SocialTeachingViewerScreen(allTopics: allTopics, initialIndex: initialIndex);
              break;
            case FavoriteType.spiritualLife:
              detailScreen = SpiritualLifeViewerScreen(allTopics: allTopics, initialIndex: initialIndex);
              break;
            default: detailScreen = null;
          }
        }
        break;

      default:
        leadingIcon = Icon(Icons.help_outline, color: theme.primaryColor);
        detailScreen = null;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: leadingIcon,
        title: Text(title, style: GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: () => _favoritesManager.toggleFavorite(item),
          tooltip: 'ካብ ንዋየ-ልበይ ኣውፅእ',
        ),
        onTap: () {
          if (detailScreen != null) {
            Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => detailScreen!));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ነዚ ንዋየ-ልቢ ክንከፍቶ ኣይከኣልናን።")));
          }
        },
      ),
    );
  }
}