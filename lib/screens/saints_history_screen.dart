import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meadi_tsga/data/saints_history_data.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import 'package:meadi_tsga/favorites_manager.dart';
import 'package:meadi_tsga/premium_ui.dart';
import '../utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

// =======================================================================
// Screen 1: Saints History Main List
// =======================================================================
class SaintsHistoryScreen extends StatelessWidget {
  const SaintsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> saintNames = saintsHistoryContent.keys.toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F2ED),
      body: SafeArea(
        child: Column(
          children: [
            buildPremiumPageHeader(context, title: 'ታሪኽ ቅዱሳን', isDark: isDark),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  itemCount: saintNames.length,
                  itemBuilder: (context, index) {
                    final saintName = saintNames[index];
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
                                        SaintTOCScreen(saintName: saintName),
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
                                      child: Image.asset(
                                        'assets/icons/saint_history.png',
                                        width: 24,
                                        height: 24,
                                        color: const Color(0xFFC61B1B),
                                        errorBuilder: (c, e, s) => const Icon(
                                            Icons.menu_book,
                                            size: 24,
                                            color: Color(0xFFC61B1B)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        saintName,
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
// Screen 2: Table of Contents for a Saint
// =======================================================================
class SaintTOCScreen extends StatefulWidget {
  final String saintName;
  const SaintTOCScreen({super.key, required this.saintName});

  @override
  State<SaintTOCScreen> createState() => _SaintTOCScreenState();
}

class _SaintTOCScreenState extends State<SaintTOCScreen> {
  List<String> _headings = [];
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _processContent();
  }

  void _processContent() {
    final contentBlocks = saintsHistoryContent[widget.saintName];
    if (contentBlocks == null || contentBlocks.isEmpty) {
      setState(() => _hasContent = false);
      return;
    }

    final List<String> extractedHeadings = [];
    for (final block in contentBlocks) {
      if (block['type'] == 'heading') {
        extractedHeadings.add(block['text'] as String);
      }
    }

    if (extractedHeadings.isEmpty && contentBlocks.isNotEmpty) {
      extractedHeadings.add(widget.saintName);
    }

    setState(() {
      _headings = extractedHeadings;
      _hasContent = true;
    });
  }

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

            // Custom Back Chevron Appbar
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
                      Navigator.maybePop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.saintName,
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
              child: !_hasContent
                  ? const Center(
                      child: Text('ትሕዝቶ ኣይተረኽበን።',
                          style: TextStyle(fontFamily: 'Nyala', fontSize: 18)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 38.0, vertical: 8.0),
                      itemCount: _headings.length,
                      itemBuilder: (context, index) {
                        final heading = _headings[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                              // ✅ ሩት ናቪጌተር ብምጥቃም ነቲ ታሕተዋይ ባር ንሓብኦ
                              Navigator.of(context, rootNavigator: true).push(
                                SlowCupertinoPageRoute(
                                  builder: (context) =>
                                      SaintSectionViewerScreen(
                                    saintName: widget.saintName,
                                    allHeadings: _headings,
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
                                    child: Center(
                                      child: Text(
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
                                    child: Text(
                                      heading,
                                      style: TextStyle(
                                        fontFamily: 'Nyala',
                                        fontSize: 18,
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// Screen 3: Saints History Viewer
// =======================================================================
class SaintSectionViewerScreen extends StatefulWidget {
  final String saintName;
  final List<String> allHeadings;
  final int initialIndex;

  const SaintSectionViewerScreen({
    super.key,
    required this.saintName,
    required this.allHeadings,
    required this.initialIndex,
  });

  @override
  State<SaintSectionViewerScreen> createState() =>
      _SaintSectionViewerScreenState();
}

class _SaintSectionViewerScreenState extends State<SaintSectionViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  final FavoritesManager _favoritesManager = FavoritesManager();
  late DateTime _startTime; // ቆጸራ ግዘ
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // ግዘ ምጅማር
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // 🌟 ገጽ ኣብ ዝተኸፈተሉ ቕጽበት እቨንት ምምዝጋብ (ጠለብ 4)
    _trackViewDetail(_currentIndex);
  }

  void _trackViewDetail(int index) {
    AnalyticsService.track('view_detail', {
      'category': 'ታሪኽ ቅዱሳን',
      'title': '${widget.saintName} - ${widget.allHeadings[index]}',
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    // ዝጸንሑሉ ሰኮንዶች ምዝገባ (Time Spent on Content)
    final int secondsSpent = DateTime.now().difference(_startTime).inSeconds;
    AnalyticsService.track('time_spent_on_detail', {
      'category': 'ታሪኽ ቅዱሳን',
      'title': '${widget.saintName} - ${widget.allHeadings[_currentIndex]}',
      'seconds': secondsSpent,
    });
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

    final currentHeading = widget.allHeadings[_currentIndex];
    final favoriteId = 'saintsHistory_${widget.saintName}_$currentHeading';

    final favoriteItem = FavoriteItem(
      id: favoriteId,
      type: FavoriteType.saintsHistory,
      content: {
        'title': widget.saintName,
        'heading': currentHeading,
      },
      dateAdded: DateTime.now(),
    );

    // ቶፕ ዝተፈተዉ ምምዝጋብ (ጠለብ 6)
    if (!_favoritesManager.isFavorite(favoriteId)) {
      AnalyticsService.track('favorite_added', {
        'category': 'ታሪኽ ቅዱሳን',
        'title': '${widget.saintName} - $currentHeading',
      });
    }

    await _favoritesManager.toggleFavorite(favoriteItem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentHeading = widget.allHeadings[_currentIndex];
    final favoriteId = 'saintsHistory_${widget.saintName}_$currentHeading';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: _isFullscreen
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme:
                  IconThemeData(color: isDark ? Colors.white : Colors.black87),
              title: Text(
                widget.allHeadings[_currentIndex],
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
                      ? () {
                          // ሓድሽ ምዕራፍ ክቕየር ከሎ ነቲ ዝነበረ ግዘ መዝጊብና ሓድሽ ግዘ ንጅምር
                          final int secondsSpent =
                              DateTime.now().difference(_startTime).inSeconds;
                          AnalyticsService.track('time_spent_on_detail', {
                            'category': 'ታሪኽ ቅዱሳን',
                            'title':
                                '${widget.saintName} - ${widget.allHeadings[_currentIndex]}',
                            'seconds': secondsSpent,
                          });
                          _startTime = DateTime.now(); // ሓድሽ ግዘ

                          // 🌟 ሓዱሽ እቨንት ምምዝጋብ
                          _trackViewDetail(_currentIndex - 1);

                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: _currentIndex < widget.allHeadings.length - 1
                      ? () {
                          // ሓድሽ ምዕራፍ ክቕየር ከሎ ነቲ ዝነበረ ግዘ መዝጊብና ሓድሽ ግዘ ንጅምር
                          final int secondsSpent =
                              DateTime.now().difference(_startTime).inSeconds;
                          AnalyticsService.track('time_spent_on_detail', {
                            'category': 'ታሪኽ ቅዱሳን',
                            'title':
                                '${widget.saintName} - ${widget.allHeadings[_currentIndex]}',
                            'seconds': secondsSpent,
                          });
                          _startTime = DateTime.now(); // ሓድሽ ግዘ

                          // 🌟 ሓዱሽ እቨንት ምምዝጋብ
                          _trackViewDetail(_currentIndex + 1);

                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      : null,
                ),
                const SizedBox(width: 20),
              ],
            ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.allHeadings.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _SaintSectionPage(
                saintName: widget.saintName,
                heading: widget.allHeadings[index],
              );
            },
          ),
          if (_isFullscreen)
            buildFullscreenOverlay(
              context: context,
              title: widget.allHeadings[_currentIndex],
              onExit: _toggleFullscreen,
            ),
        ],
      ),
    );
  }
}

// =======================================================================
// Screen 4: Saints Section Page Content Viewer
// =======================================================================
class _SaintSectionPage extends StatelessWidget {
  final String saintName;
  final String heading;

  const _SaintSectionPage({required this.saintName, required this.heading});

  List<Map<String, dynamic>> _getSectionContent() {
    final allBlocks = saintsHistoryContent[saintName];
    if (allBlocks == null) return [];

    if (allBlocks.every((block) => block['type'] != 'heading')) {
      return allBlocks;
    }

    final List<Map<String, dynamic>> sectionBlocks = [];
    bool isTargetSection = false;

    for (final block in allBlocks) {
      if (block['type'] == 'heading') {
        final currentHeading = allBlocks.length == 1 &&
                allBlocks.every((b) => b['type'] != 'heading')
            ? saintName
            : block['text'];

        if (currentHeading == heading) {
          isTargetSection = true;
        } else if (isTargetSection) {
          break;
        }
      }
      if (isTargetSection) {
        sectionBlocks.add(block);
      }
    }
    return sectionBlocks;
  }

  @override
  Widget build(BuildContext context) {
    final contentBlocks = _getSectionContent();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (contentBlocks.isEmpty) {
      return const Center(
          child: Text("ትሕዝቶ ኣይተረኽበን።",
              style: TextStyle(fontFamily: 'Nyala', fontSize: 20)));
    }

    final List<Widget> sequentialWidgets = [];
    List<Map<String, dynamic>> currentTextGroup = [];

    // Process blocks in their original database order
    for (var block in contentBlocks) {
      final String type = block['type'] as String? ?? '';

      if (type == 'image') {
        // First, if there are accumulated text blocks, build them into a Text Card
        if (currentTextGroup.isNotEmpty) {
          sequentialWidgets
              .add(_buildTextCard(context, currentTextGroup, isDark));
          sequentialWidgets.add(const SizedBox(height: 16));
          currentTextGroup = [];
        }
        // Then build and insert the image card in its correct position
        sequentialWidgets.add(_buildImageBlock(context, block));
        sequentialWidgets.add(const SizedBox(height: 16));
      } else {
        // Skip first block if it's the heading matching the section title
        if (type == 'heading' && block['text'] == heading) {
          continue;
        }
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

    final double safeBottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 38.0,
        right: 38.0,
        top: 20.0,
        bottom: safeBottomPadding > 0 ? safeBottomPadding + 20.0 : 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...sequentialWidgets,
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Unified Text container matching the exact original design
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
            .map((txtBlock) => _buildContentItem(context, txtBlock))
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
          fit: BoxFit.contain, // Allow full portrait rendering safely
          errorBuilder: (ctx, err, stack) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                  child:
                      Icon(Icons.broken_image, color: Colors.grey, size: 40))),
        ),
      ),
    );
  }

  Widget _buildContentItem(BuildContext context, Map<String, dynamic> block) {
    final String type = block['type'] as String? ?? '';
    final String text = block['text'] as String? ?? '';

    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: const TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC61B1B))),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFC61B1B)),
            ],
          ),
        );
      case 'subsection_title':
        return Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC61B1B))),
        );
      case 'paragraph':
        return _buildRichTextParagraph(context, text);
      case 'list_item':
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ',
                  style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: SelectableText(text,
                    style: const TextStyle(
                        fontFamily: 'Nyala', fontSize: 18, height: 1.6),
                    textAlign: TextAlign.justify),
              ),
            ],
          ),
        );
      case 'spacer':
        return const SizedBox(height: 24.0);
      default:
        return _buildRichTextParagraph(context, text);
    }
  }

  Widget _buildRichTextParagraph(BuildContext context, String text) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(
        fontFamily: 'Nyala',
        fontSize: 18,
        height: 1.6,
        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9));
    final boldStyle = baseStyle.copyWith(
        fontWeight: FontWeight.bold, color: const Color(0xFFC61B1B));

    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final Match match in boldRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SelectableText.rich(
        TextSpan(
          style: baseStyle,
          children: spans,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
