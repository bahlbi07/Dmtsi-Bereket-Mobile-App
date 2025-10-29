// lib/screens/church_history_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:dmtsibereket/app_colors.dart';
import 'package:dmtsibereket/data/church_history_data.dart';
import 'package:dmtsibereket/custom_page_route.dart';
import 'package:dmtsibereket/favorites_manager.dart';

class ChurchHistoryScreen extends StatelessWidget {
  const ChurchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final allTopics = [...churchHistoryPartOne, ...churchHistoryPartTwo];

    return Scaffold(
      appBar: AppBar(
        title: Text('ታሪኽ ቤተ-ክርስትያን', style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
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
            itemCount: allTopics.length,
            itemBuilder: (context, index) {
              final topic = allTopics[index];
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
                          Icons.history_edu_rounded,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          topic['title'] as String,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            SlowCupertinoPageRoute(
                              builder: (context) => ChurchHistoryViewerScreen(
                                allTopics: allTopics,
                                initialIndex: index,
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

class ChurchHistoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allTopics;
  final int initialIndex;

  const ChurchHistoryViewerScreen({
    super.key,
    required this.allTopics,
    required this.initialIndex,
  });

  @override
  State<ChurchHistoryViewerScreen> createState() =>
      _ChurchHistoryViewerScreenState();
}

class _ChurchHistoryViewerScreenState extends State<ChurchHistoryViewerScreen> {
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
    final hasPermission = await _favoritesManager.checkAndShowPermissionDialog(context);
    if (!hasPermission || !mounted) return;
    
    final currentTopic = widget.allTopics[_currentIndex];
    final favoriteId = 'churchHistory_${currentTopic['title']}';

    final favoriteItem = FavoriteItem(
      id: favoriteId,
      type: FavoriteType.churchHistory,
      content: {
        'title': currentTopic['title'],
        'categoryTitle': 'ታሪኽ ቤተ-ክርስትያን',
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
    
    final currentTopic = widget.allTopics[_currentIndex];
    final favoriteId = 'churchHistory_${currentTopic['title']}';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.allTopics[_currentIndex]['title'] as String,
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _currentIndex > 0
                ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentIndex < widget.allTopics.length - 1
                ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                : null,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allTopics.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final topic = widget.allTopics[index];
          return _ChurchHistoryDetailPage(topicData: topic);
        },
      ),
    );
  }
}

class _ChurchHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> topicData;

  const _ChurchHistoryDetailPage({required this.topicData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionalBackgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6);

    final List<Map<String, dynamic>> contentList = [];
    
    if (topicData.containsKey('path') && topicData['path'] is String) {
      final imagePath = topicData['path'] as String;
      if (imagePath.trim().isNotEmpty) {
        contentList.insert(0, {'type': 'image', 'path': imagePath, 'caption': ''});
      }
    }

    if (topicData.containsKey('content') && topicData['content'] is String) {
      final textContent = topicData['content'] as String;
      if (textContent.trim().isNotEmpty) {
        contentList.add({'type': 'paragraph', 'text': textContent});
      }
    }
    
    if (contentList.isEmpty) {
      return Container(
        color: professionalBackgroundColor,
        child: const Center(child: Text('ትሕዝቶ ኣይተረኽበን።')),
      );
    }

    return Container(
      color: professionalBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: contentList.length,
        itemBuilder: (context, index) {
          final block = contentList[index];
          return _buildContentWidget(context, block);
        },
      ),
    );
  }

  // <<< [ለውጢ] እዚ Widget ተሓዲሱ >>>
  Widget _buildContentWidget(BuildContext context, Map<String, dynamic> block) {
    final theme = Theme.of(context);
    final String type = block['type'] as String? ?? 'paragraph';
    
    switch (type) {
      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(block['path'] as String, fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Container(height: 200, color: Colors.grey[300], child: Center(child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40)))),
                ),
              if (block['caption'] != null && (block['caption'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(block['caption'], style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                ),
            ],
          ),
        );
      case 'paragraph':
      default:
        // <<< [ለውጢ] እቲ ናይ Bold Text ሎጂክ ኣብዚ ተወሲኹ >>>
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SelectableText.rich(
            TextSpan(children: _buildTextSpans(block['text'], context)),
            textAlign: TextAlign.justify,
          ),
        );
    }
  }

  // <<< [ለውጢ] እዚ ሓድሽ ሓጋዚ Function እዩ >>>
  List<TextSpan> _buildTextSpans(String text, BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7, color: theme.textTheme.bodyLarge?.color);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary);
    
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