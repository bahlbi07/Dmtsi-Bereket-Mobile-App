import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meadi_tsga/app_colors.dart';
import 'package:meadi_tsga/data/church_history_data.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import 'package:meadi_tsga/favorites_manager.dart';

// =======================================================================
// Screen 1: Church History Topics List
// =======================================================================
class ChurchHistoryScreen extends StatelessWidget {
  const ChurchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allTopics = [...churchHistoryPartOne, ...churchHistoryPartTwo];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Appbar with 38.0 Padding
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
                  const Text(
                    'ታሪኽ ቤተ-ክርስትያን',
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 38.0, vertical: 8.0),
                  itemCount: allTopics.length,
                  itemBuilder: (context, index) {
                    final topic = allTopics[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
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
                                Navigator.push(
                                  context,
                                  SlowCupertinoPageRoute(
                                    builder: (context) =>
                                        ChurchHistoryViewerScreen(
                                      allTopics: allTopics,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
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
                                      child: const Center(
                                        child: Icon(
                                          Icons.history_edu_rounded,
                                          size: 28,
                                          color: Color(0xFFC61B1B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        topic['title'] as String,
                                        style: TextStyle(
                                          fontFamily: 'Nyala',
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
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
// Screen 2: Viewer Page View
// =======================================================================
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
    final hasPermission =
        await _favoritesManager.checkAndShowPermissionDialog(context);
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
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
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
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allTopics.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return _ChurchHistoryDetailPage(topicData: widget.allTopics[index]);
        },
      ),
    );
  }
}

// =======================================================================
// Screen 3: Church History Detail Content Page (Sequential Inline Rendering)
// =======================================================================
class _ChurchHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> topicData;
  const _ChurchHistoryDetailPage({required this.topicData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> sequenceBlocks = [];

    // 1. Safely extract image path first (if it exists in topicData)
    if (topicData.containsKey('path') && topicData['path'] is String) {
      final imagePath = topicData['path'] as String;
      if (imagePath.trim().isNotEmpty) {
        sequenceBlocks.add({'type': 'image', 'path': imagePath});
      }
    }

    // 2. Extract and parse text content
    final dynamic rawContent = topicData['content'] ??
        topicData['text'] ??
        topicData['description'] ??
        topicData['paragraphs'];

    if (rawContent != null) {
      if (rawContent is String) {
        if (rawContent.trim().isNotEmpty) {
          sequenceBlocks.add({'type': 'paragraph', 'text': rawContent});
        }
      } else if (rawContent is List) {
        for (final element in rawContent) {
          if (element != null) {
            final textStr = element.toString().trim();
            if (textStr.isNotEmpty) {
              sequenceBlocks.add({'type': 'paragraph', 'text': textStr});
            }
          }
        }
      }
    }

    // Show empty state if there is no content parsed
    if (sequenceBlocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'ዝርዝር ትሕዝቶ ኣይተረኽበን።',
                style: TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> sequentialWidgets = [];
    List<Map<String, dynamic>> currentTextGroup = [];

    // Loop through blocks and preserve their sequential order
    for (var block in sequenceBlocks) {
      final String type = block['type'] as String? ?? '';

      if (type == 'image') {
        // If there are accumulated text blocks, build them into a Text Card first
        if (currentTextGroup.isNotEmpty) {
          sequentialWidgets
              .add(_buildTextCard(context, currentTextGroup, isDark));
          sequentialWidgets.add(const SizedBox(height: 16));
          currentTextGroup = [];
        }
        // Build and append the Image block
        sequentialWidgets.add(_buildImageBlock(context, block));
        sequentialWidgets.add(const SizedBox(height: 16));
      } else {
        currentTextGroup.add(block);
      }
    }

    // Append any remaining text blocks at the end
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

  // Unified Text Card preserving the exact original container UI/UX styles
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
            .map((txtBlock) => _buildContentWidget(context, txtBlock))
            .toList(),
      ),
    );
  }

  Widget _buildImageBlock(BuildContext context, Map<String, dynamic> block) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 300,
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
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(
          block['path'] as String,
          fit: BoxFit.contain, // Allow full portrait rendering cleanly
          errorBuilder: (ctx, err, stack) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.broken_image, size: 40))),
        ),
      ),
    );
  }

  Widget _buildContentWidget(BuildContext context, Map<String, dynamic> block) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SelectableText.rich(
        TextSpan(children: _buildTextSpans(block['text'], context)),
        textAlign: TextAlign.justify,
      ),
    );
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
