import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meadi_tsga/data/spiritual_life_data.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import 'package:meadi_tsga/favorites_manager.dart';
import 'package:meadi_tsga/premium_ui.dart';

// =======================================================================
// Screen 1: Spiritual Life Topics List
// =======================================================================
class SpiritualLifeScreen extends StatelessWidget {
  const SpiritualLifeScreen({super.key});

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
            buildPremiumPageHeader(context,
                title: 'መንፈሳዊ ህይወት', isDark: isDark),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  itemCount: spiritualLifeTopics.length,
                  itemBuilder: (context, index) {
                    final topic = spiritualLifeTopics[index];
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
                                HapticFeedback.lightImpact();
                                // ✅ ሩት ናቪጌተር ብምጥቃም ነቲ ታሕተዋይ ባር ንሓብኦ
                                Navigator.of(context, rootNavigator: true).push(
                                  SlowCupertinoPageRoute(
                                    builder: (context) =>
                                        SpiritualLifeViewerScreen(
                                      allTopics: spiritualLifeTopics,
                                      initialIndex: index,
                                    ),
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
                                      child: Icon(
                                        topic['icon'] as IconData? ??
                                            Icons.spa_rounded,
                                        size: 24,
                                        color: const Color(0xFFC61B1B),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        topic['title'] as String,
                                        style: TextStyle(
                                          fontFamily: 'Nyala',
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? const Color(0xFFEEEEEE)
                                              : Colors.black87,
                                        ),
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
// Screen 2: Viewer Screen
// =======================================================================
class SpiritualLifeViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allTopics;
  final int initialIndex;

  const SpiritualLifeViewerScreen({
    super.key,
    required this.allTopics,
    required this.initialIndex,
  });

  @override
  State<SpiritualLifeViewerScreen> createState() =>
      _SpiritualLifeViewerScreenState();
}

class _SpiritualLifeViewerScreenState extends State<SpiritualLifeViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  final FavoritesManager _favoritesManager = FavoritesManager();
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    SystemChrome.setEnabledSystemUIMode(
      _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final hasPermission =
        await _favoritesManager.checkAndShowPermissionDialog(context);
    if (!hasPermission || !mounted) return;

    final currentTopic = widget.allTopics[_currentIndex];
    final favoriteId = 'spiritualLife_${currentTopic['title']}';

    final favoriteItem = FavoriteItem(
      id: favoriteId,
      type: FavoriteType.spiritualLife,
      content: {
        'title': currentTopic['title'],
        'categoryTitle': 'መንፈሳዊ ህይወት',
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
    final favoriteId = 'spiritualLife_${currentTopic['title']}';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F2ED),
      appBar: _isFullscreen
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme:
                  IconThemeData(color: isDark ? Colors.white : Colors.black87),
              title: Text(
                widget.allTopics[_currentIndex]['title'] as String,
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
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, size: 22),
                  onPressed: _toggleFullscreen,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: _currentIndex > 0
                      ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: _currentIndex < widget.allTopics.length - 1
                      ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut)
                      : null,
                ),
                const SizedBox(width: 20),
              ],
            ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.allTopics.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final topic = widget.allTopics[index];
              return _SpiritualLifeDetailPage(
                title: topic['title'] as String,
                content: topic['content'] as List<Map<String, String>>,
              );
            },
          ),
          if (_isFullscreen)
            buildFullscreenOverlay(
              context: context,
              title: widget.allTopics[_currentIndex]['title'] as String,
              onExit: _toggleFullscreen,
            ),
        ],
      ),
    );
  }
}

// =======================================================================
// Screen 3: Spiritual Life Detailed Content Page
// =======================================================================
class _SpiritualLifeDetailPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> content;

  const _SpiritualLifeDetailPage({
    required this.title,
    required this.content,
  });

  List<TextSpan> _buildTextSpans(BuildContext context, String text) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(
      fontFamily: 'Nyala',
      fontSize: 18,
      height: 1.6,
      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: const Color(0xFFC61B1B),
    );

    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final Match match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start), style: baseStyle));
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
    final double safeBottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 38.0,
        right: 38.0,
        top: 20.0,
        bottom: safeBottomPadding > 0 ? safeBottomPadding + 20.0 : 40.0,
      ),
      child: Container(
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
          children: content.map((contentBlock) {
            final type = contentBlock['type']!;
            final text = contentBlock['text']!;

            switch (type) {
              case 'heading':
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC61B1B)),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFFC61B1B)),
                    ],
                  ),
                );
              case 'subheading':
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontFamily: 'Nyala',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                );
              case 'paragraph':
              default:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: _buildTextSpans(context, text),
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
