import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meadi_tsga/data/doctrine_data.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import 'package:meadi_tsga/favorites_manager.dart';
import 'package:meadi_tsga/premium_ui.dart';

// =======================================================================
// Screen 1: Doctrine Topics List
// =======================================================================
class DoctrineScreen extends StatelessWidget {
  const DoctrineScreen({super.key});

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
                title: 'ትምህርተ ሃይማኖት', isDark: isDark),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  itemCount: doctrineTopics.length,
                  itemBuilder: (context, index) {
                    final topic = doctrineTopics[index];
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
                              borderRadius: BorderRadius.circular(22),
                              splashColor: const Color(0xFFC61B1B)
                                  .withValues(alpha: 0.05),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                final List<Map<String, dynamic>> subTopics =
                                    doctrineDetailsContent[
                                            topic['key'] as String] ??
                                        [];

                                // ✅ ሩት ናቪጌተር ብምጥቃም ነቲ ታሕተዋይ ባር ንሓብኦ
                                Navigator.of(context, rootNavigator: true).push(
                                  SlowCupertinoPageRoute(
                                    builder: (context) =>
                                        DoctrineSubTopicScreen(
                                      mainTopicTitle: topic['title'] as String,
                                      subTopics: subTopics,
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
                                            Icons.school_outlined,
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
// Screen 2: Doctrine SubTopics List with consistent spacing
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

    if (subTopics.length == 1) {
      return DoctrineViewerScreen(
        mainTopicTitle: mainTopicTitle,
        subTopics: subTopics,
        initialIndex: 0,
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F2ED),
      body: SafeArea(
        child: Column(
          children: [
            buildPremiumPageHeader(context,
                title: mainTopicTitle, isDark: isDark),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                itemCount: subTopics.length,
                itemBuilder: (context, index) {
                  final subTopic = subTopics[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    decoration: buildPremiumCardDecoration(isDark),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      splashColor:
                          const Color(0xFFC61B1B).withValues(alpha: 0.05),
                      onTap: () {
                        // ✅ ሩት ናቪጌተር ብምጥቃም ነቲ ታሕተዋይ ባር ንሓብኦ
                        Navigator.of(context, rootNavigator: true).push(
                          SlowCupertinoPageRoute(
                            builder: (context) => DoctrineViewerScreen(
                              mainTopicTitle: mainTopicTitle,
                              subTopics: subTopics,
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
                              child: Text(
                                '${index + 1 < 10 ? '0' : ''}${index + 1}',
                                style: const TextStyle(
                                  fontFamily: 'Nyala',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC61B1B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                subTopic['title'] as String,
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
// Screen 3: Doctrine Page Slider & Pill Tabs Controller
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

    final currentSubTopic = widget.subTopics[_currentIndex];
    final favoriteId =
        'doctrine_${widget.mainTopicTitle}_${currentSubTopic['title']}';

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
    final favoriteId =
        'doctrine_${widget.mainTopicTitle}_${currentSubTopic['title']}';
    final isCurrentlyFavorite = _favoritesManager.isFavorite(favoriteId);

    final bool canGoNext = _currentIndex < widget.subTopics.length - 1;
    final bool canGoPrevious = _currentIndex > 0;

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
                currentSubTopic['title'] as String,
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
                if (widget.subTopics.length > 1) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: canGoPrevious
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: canGoNext
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut)
                        : null,
                  ),
                ],
                const SizedBox(width: 20),
              ],
            ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.subTopics.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return DoctrineDetailPage(subTopicData: widget.subTopics[index]);
            },
          ),
          if (_isFullscreen)
            buildFullscreenOverlay(
              context: context,
              title: currentSubTopic['title'] as String,
              onExit: _toggleFullscreen,
            ),
        ],
      ),
    );
  }
}

// =======================================================================
// Screen 4: Detailed Doctrine Card Builder (supporting custom Pill Tabs)
// =======================================================================
class DoctrineDetailPage extends StatefulWidget {
  final Map<String, dynamic> subTopicData;

  const DoctrineDetailPage({super.key, required this.subTopicData});

  @override
  State<DoctrineDetailPage> createState() => _DoctrineDetailPageState();
}

class _DoctrineDetailPageState extends State<DoctrineDetailPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.subTopicData.containsKey('pages')) {
      final pages = widget.subTopicData['pages'] as List<dynamic>;
      _tabController = TabController(length: pages.length, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging ||
            _tabController!.index != _currentTabIndex) {
          setState(() {
            _currentTabIndex = _tabController!.index;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subTopicData.containsKey('pages')) {
      return _buildTabbedPage(context);
    } else {
      return _buildSinglePage(context);
    }
  }

  Widget _buildTabbedPage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pages = widget.subTopicData['pages'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Elegant Horizontal Custom Pill Scrollable Tabs
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                indicator: const BoxDecoration(),
                tabs: pages.map((page) {
                  final pageTitle = page['pageTitle'] as String;
                  final isSelected = pages.indexOf(page) == _currentTabIndex;
                  return Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFC61B1B)
                            : (isDark
                                ? Colors.grey.shade800
                                : const Color(0xFFE5E5E5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pageTitle,
                        style: TextStyle(
                          fontFamily: 'Nyala',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: pages.map((page) {
                final contentList = List<Map<String, dynamic>>.from(
                    page['pageContent'] as List<dynamic>);
                return _buildContentList(context, contentList);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePage(BuildContext context) {
    final contentList = List<Map<String, dynamic>>.from(
        widget.subTopicData['content'] as List<dynamic>);
    return _buildContentList(context, contentList);
  }

  Widget _buildContentList(
      BuildContext context, List<Map<String, dynamic>> contentList) {
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
          children: contentList.map((contentBlock) {
            final type = contentBlock['type'] as String;
            final text = contentBlock['text'] as String;
            return _buildContentWidget(context, type, text);
          }).toList(),
        ),
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
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        );
      case 'quote':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFC61B1B).withValues(alpha: 0.05),
            border: const Border(
                left: BorderSide(color: Color(0xFFC61B1B), width: 4)),
          ),
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 18,
                  fontStyle: FontStyle.italic)),
        );
      case 'paragraph':
      default:
        final baseStyle = TextStyle(
            fontFamily: 'Nyala',
            fontSize: 18,
            height: 1.6,
            color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9));
        final boldStyle = baseStyle.copyWith(
            fontWeight: FontWeight.bold, color: const Color(0xFFC61B1B));
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RichText(
            textAlign: TextAlign.start,
            text:
                TextSpan(children: _buildTextSpans(text, baseStyle, boldStyle)),
          ),
        );
    }
  }

  List<TextSpan> _buildTextSpans(
      String text, TextStyle baseStyle, TextStyle boldStyle) {
    final List<TextSpan> spans = [];
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
