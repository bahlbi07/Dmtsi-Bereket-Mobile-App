// lib/screens/bible_tradition_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:dmtsibereket/app_colors.dart';
import 'package:dmtsibereket/data/bible_tradition_data.dart';
import 'package:dmtsibereket/custom_page_route.dart';
// === [ለውጢ] FavoritesManager ተወሲኹ ===
import 'package:dmtsibereket/favorites_manager.dart';

class BibleTraditionScreen extends StatelessWidget {
  const BibleTraditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'መፅሓፍ ቅዱስን ትውፊትን',
          style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
        elevation: 2.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            itemCount: bibleTraditionTopics.length,
            itemBuilder: (context, index) {
              final topic = bibleTraditionTopics[index];
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
                        // === [ለውጢ] Icon ካብ Home Page ዝመፅእ icon ክኸውን ===
                        leading: Icon(
                          topic['icon'] as IconData? ?? Icons.book_outlined,
                          size: 32,
                          color: Colors.green.shade700,
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
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            SlowCupertinoPageRoute(
                              builder: (context) => BibleTraditionViewerScreen(
                                allTopics: bibleTraditionTopics,
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

class BibleTraditionViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allTopics;
  final int initialIndex;

  const BibleTraditionViewerScreen({
    super.key,
    required this.allTopics,
    required this.initialIndex,
  });

  @override
  State<BibleTraditionViewerScreen> createState() =>
      _BibleTraditionViewerScreenState();
}

class _BibleTraditionViewerScreenState
    extends State<BibleTraditionViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  // === [ለውጢ] FavoritesManager ተወሲኹ ===
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

  // === [ለውጢ] ን Favorites ዝኸውን function ===
  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final hasPermission = await _favoritesManager.checkAndShowPermissionDialog(context);
    if (!hasPermission || !mounted) return;
    
    final currentTopic = widget.allTopics[_currentIndex];
    final favoriteId = 'bibleTradition_${currentTopic['title']}';

    final favoriteItem = FavoriteItem(
      id: favoriteId,
      type: FavoriteType.bibleTradition,
      content: {
        'title': currentTopic['title'],
        'categoryTitle': 'መፅሓፍ ቅዱስን ትውፊትን',
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

    // === [ለውጢ] ን Favorites ዝኸውን ሎጂክ ===
    final currentTopic = widget.allTopics[_currentIndex];
    final favoriteId = 'bibleTradition_${currentTopic['title']}';
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
        elevation: 2.0,
        actions: [
          // === [ለውጢ] Favoritesን Next/Previousን ዝሓዘ actions ===
          IconButton(
            icon: Icon(isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border),
            color: isCurrentlyFavorite ? Colors.red.shade400 : null,
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _currentIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentIndex < widget.allTopics.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allTopics.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final topic = widget.allTopics[index];
          return _BibleTraditionDetailPage(
            title: topic['title'] as String,
            content: topic['content'] as List<Map<String, String>>,
          );
        },
      ),
    );
  }
}

class _BibleTraditionDetailPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> content;

  const _BibleTraditionDetailPage({
    required this.title,
    required this.content,
  });

  List<TextSpan> _buildTextSpans(
      String text, TextStyle baseStyle, TextStyle boldStyle) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final Match match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
            TextSpan(text: text.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionalBackgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6);

    return Container(
      color: professionalBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.map((contentBlock) {
            final type = contentBlock['type']!;
            final text = contentBlock['text']!;
            switch (type) {
              case 'heading':
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.notoSerifEthiopic(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ],
                  ),
                );
              case 'subheading':
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    text,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                );
              case 'paragraph':
              default:
                final baseStyle = GoogleFonts.notoSerifEthiopic(
                  fontSize: 18,
                  height: 1.7,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                );
                final boldStyle = baseStyle.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: _buildTextSpans(text, baseStyle, boldStyle),
                    ),
                  ),
                );
            }
          }).toList(),
        ),
      ),
    );
  }
}