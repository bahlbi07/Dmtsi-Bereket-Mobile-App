// lib/screens/doctrine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:dmtsibereket/app_colors.dart';
import 'package:dmtsibereket/data/doctrine_data.dart';
import 'package:dmtsibereket/custom_page_route.dart';
import 'package:dmtsibereket/favorites_manager.dart';

class DoctrineScreen extends StatelessWidget {
  const DoctrineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('ትምህርተ ሃይማኖት', style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
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
            itemCount: doctrineTopics.length,
            itemBuilder: (context, index) {
              final topic = doctrineTopics[index];
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
                          topic['icon'] as IconData? ?? Icons.school_outlined,
                          size: 32,
                          color: Colors.deepPurple.shade600,
                        ),
                        title: Text(
                          topic['title'] as String,
                          style: GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final List<Map<String, dynamic>> subTopics = doctrineDetailsContent[topic['key'] as String] ?? [];
                          
                          // <<< [ለውጢ] ናብ SubTopic Screen ንመርሕ >>>
                          Navigator.push(
                            context,
                            SlowCupertinoPageRoute(
                              builder: (context) => DoctrineSubTopicScreen(
                                mainTopicTitle: topic['title'] as String,
                                subTopics: subTopics,
                              ),
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

// =======================================================================
// Screen 2: ንኡስ-ዝርዝር (ንኣብነት፡ ዝርዝር 7ተ ምስጢራት)
// እዚ ሓድሽ ስክሪን እዩ
// =======================================================================
class DoctrineSubTopicScreen extends StatelessWidget {
  final String mainTopicTitle;
  final List<Map<String, dynamic>> subTopics;

  const DoctrineSubTopicScreen({
    super.key,
    required this.mainTopicTitle,
    required this.subTopics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if there are sub-topics. If not, go directly to the viewer.
    if (subTopics.length == 1) {
      return DoctrineViewerScreen(
        mainTopicTitle: mainTopicTitle,
        subTopics: subTopics,
        initialIndex: 0,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(mainTopicTitle, style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: subTopics.length,
          itemBuilder: (context, index) {
            final subTopic = subTopics[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(subTopic['title'] as String, style: theme.textTheme.titleMedium),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    SlowCupertinoPageRoute(
                      builder: (context) => DoctrineViewerScreen(
                        mainTopicTitle: mainTopicTitle,
                        subTopics: subTopics,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// =======================================================================
// Screen 3: ንኡስ-ትሕዝቶ መርኣዪ (Sub-content Viewer)
// =======================================================================
class DoctrineViewerScreen extends StatefulWidget {
  final String mainTopicTitle;
  final List<Map<String, dynamic>> subTopics;
  final int initialIndex;

  const DoctrineViewerScreen({
    super.key,
    required this.mainTopicTitle,
    required this.subTopics,
    required this.initialIndex,
  });

  @override
  State<DoctrineViewerScreen> createState() => _DoctrineViewerScreenState();
}

class _DoctrineViewerScreenState extends State<DoctrineViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final hasPermission = await _favoritesManager.checkAndShowPermissionDialog(context);
    if (!hasPermission || !mounted) return;
    
    final currentSubTopic = widget.subTopics[_currentIndex];
    final favoriteId = 'doctrine_${widget.mainTopicTitle}_${currentSubTopic['title']}';

    final favoriteItem = FavoriteItem(
      id: favoriteId,
      type: FavoriteType.doctrine,
      content: {
        'title': currentSubTopic['title'],
        'mainTopicTitle': widget.mainTopicTitle,
        'contentData': currentSubTopic['content'],
        if (currentSubTopic.containsKey('pages'))
          'pages': currentSubTopic['pages'],
      },
      dateAdded: DateTime.now(),
    );

    await _favoritesManager.toggleFavorite(favoriteItem);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentSubTopic = widget.subTopics[_currentIndex];
    final favoriteId = 'doctrine_${widget.mainTopicTitle}_${currentSubTopic['title']}';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);

    // <<< [ለውጢ] Next/Previous ኣብዚ ጥራይ እዩ ዝርአ >>>
    final bool canGoNext = _currentIndex < widget.subTopics.length - 1;
    final bool canGoPrevious = _currentIndex > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentSubTopic['title'] as String,
          style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
        actions: [
          IconButton(
            icon: Icon(isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border),
            color: isCurrentlyFavorite ? Colors.red.shade400 : null,
            onPressed: _toggleFavorite,
          ),
          // <<< [ለውጢ] Next/Previous ኣብዚ ጥራይ እዩ ዝርአ >>>
          if (widget.subTopics.length > 1) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: canGoPrevious
                  ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: canGoNext
                  ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null,
            ),
          ]
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.subTopics.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return DoctrineDetailPage(subTopicData: widget.subTopics[index]);
        },
      ),
    );
  }
}

// =======================================================================
// Screen 4: ዝርዝራዊ ትሕዝቶ (ከም ዘለዎ ይቕፅል)
// =======================================================================
class DoctrineDetailPage extends StatelessWidget {
  final Map<String, dynamic> subTopicData;

  const DoctrineDetailPage({
    super.key,
    required this.subTopicData,
  });

  @override
  Widget build(BuildContext context) {
    if (subTopicData.containsKey('pages')) {
      return _buildTabbedPage(context);
    } 
    else {
      return _buildSinglePage(context);
    }
  }

  Widget _buildTabbedPage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pages = subTopicData['pages'] as List<Map<String, dynamic>>;
    
    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6),
        body: Column(
          children: [
            Container(
              color: theme.cardColor,
              child: TabBar(
                isScrollable: true,
                labelStyle: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.notoSansEthiopic(),
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.textTheme.bodySmall?.color,
                tabs: pages.map((page) => Tab(text: page['pageTitle'] as String)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: pages.map((page) {
                  final contentList = page['pageContent'] as List<Map<String, dynamic>>;
                  return _buildContentList(context, contentList);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentList = subTopicData['content'] as List<Map<String, dynamic>>;
    
    return Container(
      color: isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6),
      child: _buildContentList(context, contentList),
    );
  }

  Widget _buildContentList(BuildContext context, List<Map<String, dynamic>> contentList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentList.map((contentBlock) {
          final type = contentBlock['type'] as String;
          final text = contentBlock['text'] as String;
          return _buildContentWidget(context, type, text);
        }).toList(),
      ),
    );
  }
  
  Widget _buildContentWidget(BuildContext context, String type, String text) {
    final theme = Theme.of(context);
    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: GoogleFonts.notoSerifEthiopic(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Divider(color: theme.colorScheme.primary.withOpacity(0.3)),
            ],
          ),
        );
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(text, style: GoogleFonts.notoSansEthiopic(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        );
      case 'quote':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
          ),
          child: Text(text, style: GoogleFonts.notoSerifEthiopic(fontSize: 17, fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color)),
        );
      case 'paragraph':
      default:
        final baseStyle = GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9));
        final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(children: _buildTextSpans(text, baseStyle, boldStyle)),
          ),
        );
    }
  }

  List<TextSpan> _buildTextSpans(String text, TextStyle baseStyle, TextStyle boldStyle) {
    final List<TextSpan> spans = [];
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