// lib/screens/saints_history_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:dmtsibereket/app_colors.dart';
import 'package:dmtsibereket/data/saints_history_data.dart';
import 'package:dmtsibereket/custom_page_route.dart';
import 'package:dmtsibereket/favorites_manager.dart';
import 'package:flutter/services.dart';

class SaintsHistoryScreen extends StatelessWidget {
  const SaintsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final List<String> saintNames = saintsHistoryContent.keys.toList();

    // <<< [ለውጢ] እቲ Scaffoldን AppBarን ተኣልዩ >>>
    // እቲ Widget ሕጂ ነቲ ትሕዝቶ ጥራይ እዩ ዝመልስ
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          itemCount: saintNames.length,
          itemBuilder: (context, index) {
            final saintName = saintNames[index];
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
                      leading: Image.asset(
                        'assets/icons/saint_history.png', 
                        width: 30, height: 30, 
                        color: Colors.brown.shade600,
                        errorBuilder: (c, e, s) => Icon(Icons.church_outlined, size: 30, color: Colors.brown.shade600),
                      ),
                      title: Text(
                        saintName,
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
                            builder: (context) => SaintTOCScreen(saintName: saintName),
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
    );
  }
}


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
      appBar: AppBar(
        title: Text(widget.saintName, style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: !_hasContent
            ? const Center(child: Text('ትሕዝቶ ኣይተረኽበን።'))
            : ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: _headings.length,
                itemBuilder: (context, index) {
                  final heading = _headings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(heading, style: theme.textTheme.titleMedium),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          SlowCupertinoPageRoute(
                            builder: (context) => SaintSectionViewerScreen(
                              saintName: widget.saintName,
                              allHeadings: _headings,
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

// =========================================================
// Screen 3: ንኽስሓብ ዝኽእል PageView ዝሓዘ ስክሪን
// =========================================================
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
  State<SaintSectionViewerScreen> createState() => _SaintSectionViewerScreenState();
}

class _SaintSectionViewerScreenState extends State<SaintSectionViewerScreen> {
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

    await _favoritesManager.toggleFavorite(favoriteItem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // === [ለውጢ] ን Favorites ዝኸውን ሎጂክ ===
    final currentHeading = widget.allHeadings[_currentIndex];
    final favoriteId = 'saintsHistory_${widget.saintName}_$currentHeading';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allHeadings[_currentIndex], 
          style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
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
                ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentIndex < widget.allHeadings.length - 1
                ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                : null,
          ),
        ],
      ),
      body: PageView.builder(
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
    );
  }
}

// =========================================================
// Screen 4: ሓደ ውልቀ-ገፅ ናይ ታሪኽ ዘርኢ Widget
// =========================================================
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
        final currentHeading = allBlocks.length == 1 && allBlocks.every((b) => b['type'] != 'heading') 
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionalBackgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6);
    final contentBlocks = _getSectionContent();

    return Container(
      color: professionalBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: contentBlocks.length,
        itemBuilder: (context, index) {
          final block = contentBlocks[index];
          if (index == 0 && block['type'] == 'heading') {
            return const SizedBox.shrink();
          }
          return _buildContentItem(context, block);
        },
      ),
    );
  }

  Widget _buildContentItem(BuildContext context, Map<String, dynamic> block) {
    final String type = block['type'] as String? ?? '';
    final String text = block['text'] as String? ?? '';
    final theme = Theme.of(context);

    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: GoogleFonts.notoSerifEthiopic(
                  fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Divider(color: theme.colorScheme.primary.withOpacity(0.3)),
            ],
          ),
        );
      case 'subsection_title':
        return Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
          child: Text(text, style: GoogleFonts.notoSansEthiopic(
              fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
        );
      case 'paragraph':
        return _buildRichTextParagraph(context, text);
      case 'list_item':
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7, fontWeight: FontWeight.bold)),
              Expanded(
                child: SelectableText(text,
                    style: GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7),
                    textAlign: TextAlign.justify),
              ),
            ],
          ),
        );
      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(block['path'] as String, fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Container(height: 200, color: Colors.grey[300],
                      child: Center(child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40))),
                ),
              ),
              if (block['caption'] != null && (block['caption'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(block['caption'],
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
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
    final baseStyle = GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

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