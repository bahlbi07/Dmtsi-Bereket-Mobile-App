// lib/screens/prayer_content_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:dmtsibereket/app_colors.dart';
import 'package:dmtsibereket/data/prayer_content_data.dart';
import 'package:dmtsibereket/custom_page_route.dart';
import 'package:dmtsibereket/favorites_manager.dart';

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
// Screen 1: Main list of prayer categories
// =======================================================================
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(prayerListItems);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(prayerListItems);
      } else {
        _filteredItems = prayerListItems.where((category) {
          final title = (category['title'] as String).toLowerCase();
          if (title.contains(query)) return true;
          final itemKeys = category['itemKeys'] as List<dynamic>? ?? [];
          return itemKeys.any((key) => key.toString().toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  Future<void> _handleLiturgyTap(BuildContext context, Map<String, dynamic> category) async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dayOfWeek = now.weekday;
    final hour = now.hour;
    
    // Sunday from 6:00 (12:00 morning Eth time) up to 10:59 (just before 5:00 morning Eth time)
    bool isLiturgyTime = (dayOfWeek == DateTime.sunday && hour >= 6 && hour < 11);

    if (isLiturgyTime) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('❤️ ምሕዝነታዊ ምኽሪ ❤️', style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
            content: Text(
              "ኣብዚ ናይ ቅዳሴ ሰዓት፡ ስርዓተ ቅዳሴ ብሞባይል ምኽትታል ንኣቓልቦኻን ንኣቓልቦ ካልኦት ምእመናንን ክዘርግ ይኽእል እዩ።\n\nምሉእ በረኸት ንምርካብ፡ በጃኻ ብኣካል፡ ብመፅሓፍ፡ ወይ በቲ ኣብ ቤተ-ክርስትያን ዝርከብ መሳርሒ ተጠቒምካ ተኸታተል።\n\nፍሉይ ምኽንያት እንተለካ ጥራይ 'ይቕፀል' ብምባል ክትጥቀመሉ ትኽእል ኢኻ።",
              style: GoogleFonts.notoSerifEthiopic(height: 1.6),
            ),
            actions: <Widget>[
              TextButton(child: const Text('ተረዲአ'), onPressed: () => Navigator.of(dialogContext).pop()),
              ElevatedButton(child: const Text('ይቐፅል'), onPressed: () { 
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

  void _navigateToLiturgyContent(BuildContext context, Map<String, dynamic> category) {
      HapticFeedback.lightImpact();
      final String categoryTitle = category['title'] as String;
      final List<String> prayerKeys = List<String>.from(category['itemKeys'] ?? []);
      
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
      appBar: AppBar(
        title: Text('ፀሎታት', style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ፀሎት ድለ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                        : null,
                  ),
                ),
              ),
            ),
            if (_searchController.text.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset('assets/images/prayers/prayer.jpg', height: 180, fit: BoxFit.cover),
                  ),
                ),
              ),
            _filteredItems.isEmpty
                ? SliverFillRemaining(child: Center(child: Text('"${_searchController.text}" ዝብል ፀሎት ኣይተረኽበን።', style: GoogleFonts.notoSansEthiopic())))
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 80.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = _filteredItems[index];
                          return _buildCategoryItem(context, category, index);
                        },
                        childCount: _filteredItems.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, dynamic> category, int index) {
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
              leading: Icon(
                category['icon'] as IconData? ?? Icons.church,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                category['title'] as String,
                style: GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                final String type = category['type'] as String;
                
                if (type == 'liturgy') {
                  _handleLiturgyTap(context, category);
                  return;
                }

                HapticFeedback.lightImpact();
                final String categoryTitle = category['title'] as String;
                final List<String> prayerKeys = List<String>.from(category['itemKeys'] ?? []);
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
            ),
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// Screen 2: Sub-category list
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
      appBar: AppBar(
        title: Text(categoryTitle, style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: CustomScrollView(
          slivers: [
            if (headerImagePath != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      headerImagePath!,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 80.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final prayerTitle = prayerKeys[index];
                    final isMystery = prayerTitle.contains("ምስጢር");

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        leading: isMystery ? Icon(Icons.brightness_5, color: theme.primaryColor) : CircleAvatar(child: Text('${index + 1}')),
                        title: Text(prayerTitle, style: GoogleFonts.notoSansEthiopic(fontSize: 16, fontWeight: FontWeight.w500)),
                        subtitle: prayerSubtitles.containsKey(prayerTitle)
                            ? Text(prayerSubtitles[prayerTitle]!, style: GoogleFonts.notoSansEthiopic())
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (isMystery) {
                            List<String> mysteryParts;
                            if (prayerTitle == 'ናይ ደስታ ምስጢር') {
                              mysteryParts = rosaryJoyfulPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
                            } else if (prayerTitle == 'ናይ ብርሃን ምስጢር') {
                              mysteryParts = rosaryLuminousPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
                            } else if (prayerTitle == 'ናይ ሕማም ምስጢር') {
                              mysteryParts = rosarySorrowfulPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
                            } else {
                              mysteryParts = rosaryGloriousPrayerContent.map((item) => _getSafeTitle(item)).whereType<String>().toList();
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
    );
  }
}

enum PrayerDisplayMode { tabs, pageView }

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

class _PrayerContentViewerState extends State<PrayerContentViewer> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  late int _currentIndex;
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _tabController = TabController(length: widget.prayerKeys.length, vsync: this, initialIndex: _currentIndex);
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _currentIndex) {
         updateIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  void updateIndex(int index) {
    if (_currentIndex != index && mounted) {
      setState(() {
        _currentIndex = index;
        if (widget.displayMode == PrayerDisplayMode.pageView) {
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      });
    }
  }

  Future<void> _toggleFavorite() async {
     // ... favorite logic ...
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (widget.prayerKeys.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(widget.categoryTitle)), body: const Center(child: Text("ትሕዝቶ የለን")));
    }

    final currentPrayerTitle = widget.prayerKeys[_currentIndex];
    final favoriteId = 'prayer_$currentPrayerTitle';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);
    
    final bool showNavigationArrows = widget.displayMode == PrayerDisplayMode.pageView && widget.prayerKeys.length > 1;
    final bool useTabs = widget.displayMode == PrayerDisplayMode.tabs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
        elevation: useTabs ? 0 : 2,
        title: Text(
          useTabs ? widget.categoryTitle : currentPrayerTitle,
          style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border),
            color: isCurrentlyFavorite ? Colors.red.shade400 : null,
            onPressed: _toggleFavorite,
          ),
          if (showNavigationArrows)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _currentIndex > 0 ? () => updateIndex(_currentIndex - 1) : null,
            ),
          if (showNavigationArrows)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _currentIndex < widget.prayerKeys.length - 1 ? () => updateIndex(_currentIndex + 1) : null,
            ),
        ],
        bottom: useTabs && widget.prayerKeys.length > 1
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Material(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelStyle: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.notoSansEthiopic(),
                  labelColor: primaryAppBarColor,
                  unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                  indicatorColor: primaryAppBarColor,
                  onTap: (index) => updateIndex(index),
                  tabs: widget.prayerKeys.map((key) => Tab(text: key)).toList(),
                ),
              ),
            )
          : null,
      ),
      body: useTabs
        ? TabBarView(
            controller: _tabController,
            children: widget.prayerKeys.map((key) {
              final contentKey = key == "መዛዘሚ ፀሎታት" ? "rosary_conclusion" : key;
              return PrayerDetailPage(contentBlocks: allPrayersContent[contentKey] ?? []);
            }).toList(),
          )
        : PageView.builder(
            controller: _pageController,
            itemCount: widget.prayerKeys.length,
            onPageChanged: (index) => updateIndex(index),
            itemBuilder: (context, index) {
              final key = widget.prayerKeys[index];
              return PrayerDetailPage(contentBlocks: allPrayersContent[key] ?? []);
            },
          ),
    );
  }
}


class PrayerDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> contentBlocks;

  const PrayerDetailPage({ super.key, required this.contentBlocks });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : const Color(0xFFFFFDF6);

    if (contentBlocks.isEmpty) {
      return Container(
        color: backgroundColor,
        child: Center(
          child: Text("ትሕዝቶ ኣይተረኽበን።", style: GoogleFonts.notoSerifEthiopic(fontSize: 18))
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
        itemCount: contentBlocks.length,
        itemBuilder: (context, index) {
          final block = contentBlocks[index];
          return _buildContentBlock(context, block);
        },
      ),
    );
  }

  Widget _buildContentBlock(BuildContext context, Map<String, dynamic> block) {
    final theme = Theme.of(context);
    final String type = block['type'] ?? 'paragraph';
    
    switch (type) {
      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 350,
                maxWidth: 500,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(block['path'] as String, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            block['text'].toString(),
            style: GoogleFonts.notoSerifEthiopic(fontSize: 26, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        );
      case 'subheading':
         return Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Text(
            block['text'].toString(),
            style: GoogleFonts.notoSansEthiopic(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
          ),
        );
      case 'prompt':
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                block['text'].toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(fontStyle: FontStyle.italic, color: theme.colorScheme.primary),
              ),
            ),
          ),
        );
      case 'separator':
        return const Divider(height: 48, thickness: 0.5, indent: 20, endIndent: 20);
      case 'paragraph':
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SelectableText.rich(
            TextSpan(children: _buildTextSpans(block['text'].toString(), context)),
            textAlign: TextAlign.start,
          ),
        );
    }
  }

   List<TextSpan> _buildTextSpans(String text, BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9));
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color);
    List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    for (final Match match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: baseStyle));
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