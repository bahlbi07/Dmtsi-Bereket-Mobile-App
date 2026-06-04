import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../app_colors.dart';
import '../custom_page_route.dart';
import '../favorites_manager.dart';
import '../data/quotes_of_saint_data.dart';
import '../utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

// ነቲ ሓዱሽ ፖስተር ጀነሬተር ኢንጂን ኢምፖርት ንገብሮ
import '../utils/quote_poster_generator.dart';

// =======================================================================
// Screen 1: Quotes Topics Main List
// =======================================================================
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

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Back App Bar with 38.0 Padding
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
                    'ጥቅስታት ቅዱሳን',
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
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
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
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  SlowCupertinoPageRoute(
                                    builder: (context) => QuotesViewerScreen(
                                      allTopics: _topics
                                          .map((t) => t['title'] as String)
                                          .toList(),
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
                                          Icons.format_quote_rounded,
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
// Screen 2: Quotes Viewer Page Slider
// =======================================================================
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
  late DateTime _startTime; // ቆፀራ ግዘ ንምጅማር

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // ግዘ ምጅማር
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // ዝጸንሑሉ ሰኮንዶች ምዝገባ (Time Spent on Content)
    final int secondsSpent = DateTime.now().difference(_startTime).inSeconds;
    AnalyticsService.track('time_spent_on_detail', {
      'category': 'ጥቅስታት ቅዱሳን',
      'title': widget.allTopics[_currentIndex],
      'seconds': secondsSpent,
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          widget.allTopics[_currentIndex],
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
          // ሓድሽ ምዕራፍ ክቕየር ከሎ ነቲ ዝነበረ ግዘ መዝጊብና ሓድሽ ግዘ ንጅምር
          final int secondsSpent =
              DateTime.now().difference(_startTime).inSeconds;
          AnalyticsService.track('time_spent_on_detail', {
            'category': 'ጥቅስታት ቅዱሳን',
            'title': widget.allTopics[_currentIndex],
            'seconds': secondsSpent,
          });
          setState(() {
            _currentIndex = index;
            _startTime = DateTime.now(); // ሓድሽ ግዘ ምጅማር
          });
        },
        itemBuilder: (context, index) {
          return _QuoteTopicPage(topic: widget.allTopics[index]);
        },
      ),
    );
  }
}

// =======================================================================
// Screen 3: Individual Quote Page
// =======================================================================
class _QuoteTopicPage extends StatelessWidget {
  final String topic;
  const _QuoteTopicPage({required this.topic});

  @override
  Widget build(BuildContext context) {
    final dynamic data = quotesContentData[topic];
    if (data == null) {
      return const Center(
          child: Text('ትሕዝቶ ኣይተረኽበን።',
              style: TextStyle(fontFamily: 'Nyala', fontSize: 18)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 38.0, vertical: 20.0),
      child: topic == 'መእተዊ'
          ? _buildIntroductionContent(context, List<String>.from(data))
          : _buildQuotesList(context, List<Map<String, dynamic>>.from(data)),
    );
  }

  Widget _buildIntroductionContent(
      BuildContext context, List<String> paragraphs) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        children: paragraphs
            .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    p,
                    style: const TextStyle(
                        fontFamily: 'Nyala', fontSize: 18, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuotesList(
      BuildContext context, List<Map<String, dynamic>> quotes) {
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

// =======================================================================
// Screen 4: Polished Quote Card (ዝተመሓየሸ)
// =======================================================================
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
    _favoriteId = 'quote_${widget.topic}_${widget.quote.hashCode}';
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
    bool hasPermission =
        await _favoritesManager.checkAndShowPermissionDialog(context);
    if (hasPermission && mounted) {
      final item = FavoriteItem(
        id: _favoriteId,
        type: FavoriteType.quote,
        content: {
          'quote': widget.quote,
          'author': widget.author ?? 'Unknown',
          'topic': widget.topic
        },
        dateAdded: DateTime.now(),
      );

      // ቶፕ ዝተፈተዉ ምምዝጋብ (ጠለብ 6)
      if (!_isFavorite) {
        AnalyticsService.track('favorite_added', {
          'category': 'ጥቅስታት ቅዱሳን',
          'title': widget.topic,
        });
      }

      await _favoritesManager.toggleFavorite(item);
    }
  }

  void _copyToClipboard() {
    HapticFeedback.lightImpact();
    Clipboard.setData(
        ClipboardData(text: '"${widget.quote}"\n- ${widget.author ?? ''}'));

    // ኮፒ ጥቅስ ንጥፈት ምምዝጋብ
    AnalyticsService.track('copy_quote', {
      'topic': widget.topic,
      'author': widget.author ?? 'Unknown',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 8),
          Text('ጥቕሲ ተቐዲሑ ኣሎ!',
              style: TextStyle(fontFamily: 'Nyala', fontSize: 18)),
        ]),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // 🎨 ነቲ ሓዱሽ ናይ ምስሊ ፖስተር ጀነሬተር ዝፅውዕ ፈንክሽን
  void _shareAsPoster() {
    HapticFeedback.lightImpact();

    // ፖስተር ምስራሕ ንጥፈት ምምዝጋብ (ጠለብ 5)
    AnalyticsService.track('poster_generate_clicked', {
      'topic': widget.topic,
      'author': widget.author ?? 'Unknown',
    });

    QuotePosterGenerator.generateAndShare(
      context: context,
      quote: widget.quote,
      author: widget.author ?? 'Unknown',
      topic: widget.topic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${widget.quote}"',
              style: TextStyle(
                fontFamily: 'Nyala',
                fontSize: 18,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.author != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '- ${widget.author}',
                  style: const TextStyle(
                      fontFamily: 'Nyala',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFC61B1B)),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 1. ዝፈተኽዎም ምልክት
                IconButton(
                  icon: Icon(_isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded),
                  color: _isFavorite ? const Color(0xFFC61B1B) : null,
                  onPressed: _toggleFavorite,
                ),
                // 2. ኮፒ መግበሪ
                IconButton(
                  icon: const Icon(Icons.copy_all_rounded),
                  color: isDark ? Colors.white70 : Colors.black54,
                  onPressed: _copyToClipboard,
                ),
                // 3. 🎨 ናይ ፖስተር ምስሊ ጀነሬተርን ሼሪንግን (ሳልሳይ ሓዱሽ ኦፕሽን)
                IconButton(
                  icon: const Icon(Icons.palette_rounded),
                  color: const Color(0xFFC61B1B), // primary red
                  onPressed: _shareAsPoster,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
