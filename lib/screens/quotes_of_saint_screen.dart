// lib/screens/quotes_of_saint_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../app_colors.dart';
import '../custom_page_route.dart';
import '../favorites_manager.dart';
import '../data/quotes_of_saint_data.dart';

class QuotesOfSaintScreen extends StatelessWidget {
  const QuotesOfSaintScreen({super.key});

  final List<Map<String, dynamic>> _topics = const [
    {'title': 'መእተዊ', 'icon': Icons.info_outline_rounded},
    {'title': 'ብዛዕባ ቅዱሳት መፃሕፍቲ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ መንፈሳዊ ንባብ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ፅቡቕ ኣብነት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ትሕትና', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ኣጓጒል መንፈሳዊ ሕይወት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ጀሚርካ ዘይምግዳፍ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ሕማማት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ቅዳሴ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ቅዱስ ቊርባን', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ፀሎት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ፍርዲ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ መንነትካ ምፍላጥ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ሕይወት ቃልሲ ከም ዝኾነ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ሃረርታ ንዘልዓለማዊ ሕይወት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ንድሕነትካ ምግዳስ ከም ዝግባእ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ፍቕሪ ኣምላኽ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ፍቕሪ ብፃይ', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ሰይጣን', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ቅንኣት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ትዕቢት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ፈተና', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ሓጢኣት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ ሞት', 'icon': Icons.format_quote},
    {'title': 'ብዛዕባ እኖና ቅድስቲ ድንግል ማርያም', 'icon': Icons.format_quote},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // <<< [ለውጢ] እቲ Scaffoldን AppBarን ተኣልዩ >>>
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          itemCount: _topics.length,
          itemBuilder: (context, index) {
            final topic = _topics[index];
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
                        topic['icon'] as IconData,
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
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          SlowCupertinoPageRoute(
                            builder: (context) => QuotesViewerScreen(
                              allTopics: _topics.map((t) => t['title'] as String).toList(),
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
    );
  }
}

class QuotesViewerScreen extends StatefulWidget {
  final List<String> allTopics;
  final int initialIndex;

  const QuotesViewerScreen({
    super.key,
    required this.allTopics,
    required this.initialIndex,
  });

  @override
  State<QuotesViewerScreen> createState() => _QuotesViewerScreenState();
}

class _QuotesViewerScreenState extends State<QuotesViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.allTopics[_currentIndex],
          style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
        actions: [
          // === [ለውጢ] Next/Previous buttons ተወሲኹ ===
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
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _QuoteTopicPage(topic: widget.allTopics[index]);
        },
      ),
    );
  }
}


// === [ለውጢ] እዚ Widget ነቲ ናይ ቀደም TopicContentScreen ተኪእዎ ===
// ===============================================
// Screen 3: ሓደ ውልቀ-ገፅ ናይ ጥቕስታት ዘርኢ
// ===============================================
class _QuoteTopicPage extends StatelessWidget {
  final String topic;

  const _QuoteTopicPage({required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionalBackgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6);
    
    final dynamic data = quotesContentData[topic];
    if (data == null) {
      return Container(
        color: professionalBackgroundColor,
        child: const Center(child: Text('ትሕዝቶ ኣይተረኽበን።'))
      );
    }

    return Container(
      color: professionalBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
        child: topic == 'መእተዊ'
          ? _buildIntroductionContent(context, List<String>.from(data))
          : _buildQuotesList(context, List<Map<String, dynamic>>.from(data)),
      ),
    );
  }

  Widget _buildIntroductionContent(BuildContext context, List<String> paragraphs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          p,
          style: GoogleFonts.notoSerifEthiopic(fontSize: 18, height: 1.7),
          textAlign: TextAlign.justify,
        ),
      )).toList(),
    );
  }

  Widget _buildQuotesList(BuildContext context, List<Map<String, dynamic>> quotes) {
    return AnimationLimiter(
      child: Column(
        children: List.generate(quotes.length, (index) {
          final q = quotes[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _QuoteCard(
                  quote: q['quote'] as String,
                  author: q['author'] as String?,
                  topic: topic,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ===============================================
// ንሓደ ጥቕሲ ዝውክል Card Widget
// (እዚ ከም ዘለዎ ተዓቂቡ ኣሎ)
// ===============================================
class _QuoteCard extends StatefulWidget {
  final String quote;
  final String? author;
  final String topic;

  const _QuoteCard({required this.quote, this.author, required this.topic});

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  final FavoritesManager _favoritesManager = FavoritesManager();
  late bool _isFavorite;
  late String _favoriteId;

  @override
  void initState() {
    super.initState();
    _favoriteId = 'quote_${widget.topic}_${widget.quote.hashCode}'; // [ለውጢ] ID ንኽፈላለ ዝሓሸ ገይረዮ
    _isFavorite = _favoritesManager.isFavorite(_favoriteId);
    _favoritesManager.favoritesNotifier.addListener(_updateFavoriteStatus);
  }

  @override
  void dispose() {
    _favoritesManager.favoritesNotifier.removeListener(_updateFavoriteStatus);
    super.dispose();
  }

  void _updateFavoriteStatus() {
    if (mounted) {
      final newStatus = _favoritesManager.isFavorite(_favoriteId);
      if (newStatus != _isFavorite) {
        setState(() => _isFavorite = newStatus);
      }
    }
  }

  void _toggleFavorite() async {
    HapticFeedback.lightImpact();
    bool hasPermission = await _favoritesManager.checkAndShowPermissionDialog(context);
    if (hasPermission && mounted) {
      final item = FavoriteItem(
        id: _favoriteId,
        type: FavoriteType.quote,
        content: {'quote': widget.quote, 'author': widget.author ?? 'Unknown', 'topic': widget.topic},
        dateAdded: DateTime.now(),
      );
      await _favoritesManager.toggleFavorite(item);
    }
  }

  void _copyToClipboard() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: '"${widget.quote}"\n- ${widget.author ?? ''}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 8),
          Text('ጥቕሲ ተቐዲሑ ኣሎ!'),
        ]),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${widget.quote}"',
              style: GoogleFonts.notoSerifEthiopic(
                fontSize: 18, height: 1.7, fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.author != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '- ${widget.author}',
                  style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, color: theme.textTheme.bodySmall?.color),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                  color: _isFavorite ? Colors.red.shade400 : theme.iconTheme.color,
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite ? 'ካብ ንዋየ-ልበይ ኣውፅእ' : 'ናብ ንዋየ-ልበይ ኣእትው',
                ),
                IconButton(
                  icon: const Icon(Icons.copy_all_rounded),
                  onPressed: _copyToClipboard,
                  tooltip: 'Copy Quote',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}