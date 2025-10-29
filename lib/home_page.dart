// lib/home_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'custom_page_route.dart';
import 'data/hymn_data.dart';
import 'screens/prayer_content_screen.dart';
import 'screens/saints_history_screen.dart';
import 'app_colors.dart';
import 'constants.dart' as app_constants;
import 'screens/lyrics_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/favorites_list_screen.dart';
import 'screens/singer_screen.dart';
import 'screens/quotes_of_saint_screen.dart';
import 'screens/church_history_screen.dart';
import 'screens/doctrine_screen.dart';
import 'screens/spiritual_life_screen.dart';
import 'screens/bible_tradition_screen.dart';
import 'screens/social_teaching_screen.dart';

enum _AppMode { home, hymns, saints }

class DmtsiBereketHomePage extends StatefulWidget {
  const DmtsiBereketHomePage({super.key});
  @override
  State<DmtsiBereketHomePage> createState() => _DmtsiBereketHomePageState();
}

class _DmtsiBereketHomePageState extends State<DmtsiBereketHomePage> {
  late PageController _pageController;
  int _selectedIndex = 0;
  _AppMode _currentMode = _AppMode.home;

  final TextEditingController _searchHymnsController = TextEditingController();
  final TextEditingController _searchSingersController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _searchSingersFocusNode = FocusNode();
  bool _isSearchFocused = false;

  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _allHymns = [];
  List<String> _allSingers = [];
  List<Map<String, dynamic>> _filteredHymns = [];
  List<String> _filteredSingers = [];

  bool _isLoading = true;
  bool? _isVerifiedInstall; 
  List<String> _dynamicCategories = [];
  static const String _internalAllHymnsKey = 'All Hymns';

  String _selectedCategory = _internalAllHymnsKey;
  DateTime? _lastBackPressed;
  String _currentAppBarTitle = 'ገዛ';

  static const String hymnsSectionKey = 'Hymns';
  
  final List<String> _homeImagePaths = [
    'assets/images/home/jesus1.jpg','assets/images/home/jesus2.jpg',
    'assets/images/home/jesus3.jpg','assets/images/home/jesus4.jpg',
    'assets/images/home/jesus5.jpg','assets/images/home/jesus6.jpg',
    'assets/images/home/jesus7.jpg','assets/images/home/jesus8.jpg',
    'assets/images/home/jesus9.jpg','assets/images/home/jesus10.jpg',
    'assets/images/home/jesus11.jpg','assets/images/home/jesus12.jpg',
    'assets/images/home/jesus13.jpg','assets/images/home/jesus14.jpg',
    'assets/images/home/jesus15.jpg','assets/images/home/jesus16.jpg',
  ];

  final Map<String, List<dynamic>> _drawerSubCategories = {
    hymnsSectionKey: [
      _internalAllHymnsKey, 'ኣምልኾ', 'መንፈስ ቅዱስ', 'ምስጋና',
      {'በዓላት': ['ልደት', 'ጥምቀት', 'ሆሳዕና', 'ትንሳኤ', 'ሓድሽ ዓመት']},
      'ቅዱስ ቁርባን', 'ማርያም', 'ቅዱሳን', 'ልመና', 'ንስሓ', 'ሕማማት', 'ፀዋዕታ',
      'መዓልቲ ምውታን', 'ምፅኣት', 'ወረብ', 'ቃልኪዳን', 'ቅድስት ስድራ', 'ዝተፈላለዩ',
    ],
  };

  final Map<String, String> _hymnCategoryImages = {
    'All Hymns': 'assets/icons/all_hymns_icon.png', 'ኣምልኾ': 'assets/images/category/worship.jpg',
    'መንፈስ ቅዱስ': 'assets/images/category/holyspirit.jpg', 'ምስጋና': 'assets/images/category/praise1.jpg',
    'በዓላት': 'assets/images/category/holiday.jpg', 'ቅዱስ ቁርባን': 'assets/images/category/holycommunion.jpg',
    'ማርያም': 'assets/images/category/mary.jpg', 'ቅዱሳን': 'assets/images/category/saints.jpg',
    'ልመና': 'assets/images/category/begging.jpg', 'ንስሓ': 'assets/images/category/begging1.jpg',
    'ሕማማት': 'assets/images/category/hmamat.jpg', 'ፀዋዕታ': 'assets/images/category/tsewaeta.jpg',
    'መዓልቲ ምውታን': 'assets/images/category/mealtimutan.jpg', 'ምፅኣት': 'assets/images/category/maranatha.jpg',
    'ቃልኪዳን': 'assets/images/category/kalkidan.jpg', 'ቅድስት ስድራ': 'assets/images/category/holyfamily.jpg',
    'ዝተፈላለዩ': 'assets/images/category/praise.jpg', 'ልደት': 'assets/images/category/nativityofjesuschrist.jpg',
    'ጥምቀት': 'assets/images/category/jesusbuptism.jpg', 'ሆሳዕና': 'assets/images/category/hossana2.jpg',
    'ትንሳኤ': 'assets/images/category/jesusrisen.jpg', 'ሓድሽ ዓመት': 'assets/images/category/nativityofjesuschrist1.jpg',
    'ወረብ': 'assets/images/category/Wereb.jpg',
  };

  final List<BottomNavigationBarItem> _homeNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home, size: 24), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.menu, size: 24), label: 'Menu'),
  ];
  final List<BottomNavigationBarItem> _hymnsNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.library_music, size: 24), label: 'መዛሙር'),
    BottomNavigationBarItem(icon: Icon(Icons.mic, size: 24), label: 'ዘማርያን'),
  ];
  final List<BottomNavigationBarItem> _saintsNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.person_search, size: 24), label: 'ታሪኽ ቕዱሳን'),
    BottomNavigationBarItem(icon: Icon(Icons.history_edu, size: 24), label: 'ጥቅስታት'),
  ];
 
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeAppData();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _searchHymnsController.addListener(_handleSearchControllerChange);
  }

  void _initializeAppData() async {
    await _verifyInstallationSource();
    
    if (_isVerifiedInstall ?? false) {
      await _loadSearchHistory();
      _loadData(); 
      _triggerInAppReview();
      _checkForUpdate();
    } else {
       if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyInstallationSource() async {
    if (kDebugMode) {
      if (mounted) setState(() => _isVerifiedInstall = true);
      return;
    }
    
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final installerStore = packageInfo.installerStore;
      
      // 'com.android.vending' is the official identifier for the Google Play Store
      if (installerStore == 'com.android.vending') {
        if (mounted) setState(() => _isVerifiedInstall = true);
      } else {
        if (mounted) setState(() => _isVerifiedInstall = false);
      }
    } catch (e) {
      debugPrint("Error verifying installer: $e");
      if (mounted) setState(() => _isVerifiedInstall = false);
    }
  }

  Future<void> _checkForUpdate() async {
    if (!kReleaseMode) {
      debugPrint("In-app update check skipped in debug mode.");
      return;
    }
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
        InAppUpdate.installUpdateListener.listen((status) {
          if (status == InstallStatus.downloaded) {
             if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('ሓድሽ ስሪት ተዳልዩ ኣሎ!'),
                    action: SnackBarAction(
                      label: 'INSTALL',
                      onPressed: () {
                        InAppUpdate.completeFlexibleUpdate();
                      },
                    ),
                    duration: const Duration(days: 1),
                  ),
                );
              }
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to check for in-app update: $e');
    }
  }

  Future<void> _triggerInAppReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final InAppReview inAppReview = InAppReview.instance;

      if (!await inAppReview.isAvailable()) {
        return;
      }

      const String installDateKey = 'firstInstallDate';
      const String launchCountKey = 'launchCount';

      int launchCount = prefs.getInt(launchCountKey) ?? 0;
      await prefs.setInt(launchCountKey, launchCount + 1);

      final int? firstInstallMillis = prefs.getInt(installDateKey);

      if (firstInstallMillis == null) {
        await prefs.setInt(installDateKey, DateTime.now().millisecondsSinceEpoch);
        return;
      }

      final firstInstallDate = DateTime.fromMillisecondsSinceEpoch(firstInstallMillis);
      final daysSinceInstall = DateTime.now().difference(firstInstallDate).inDays;

      if (daysSinceInstall >= 3 && launchCount >= 5) {
        final bool alreadyRated = prefs.getBool('hasRequestedReview') ?? false;
        if (!alreadyRated) {
          inAppReview.requestReview();
          await prefs.setBool('hasRequestedReview', true);
        }
      }
    } catch (e) {
      debugPrint('Error triggering in-app review: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchHymnsController.removeListener(_handleSearchControllerChange);
    _searchHymnsController.dispose();
    _searchSingersController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchSingersFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (mounted) setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
  }

  void _handleSearchControllerChange() {
    if (_currentMode == _AppMode.hymns && mounted) {
      _performHymnSearch(_searchHymnsController.text);
    }
  }

  void _loadData() {
    if (!mounted) return;
    if (_isLoading) {
       setState(() => _isLoading = true);
    }
    
    List<Map<String, dynamic>> loadedHymns = [];
    Set<String> uniqueSingers = {};
    Set<String> uniqueDynamicCategoriesFromData = {};
    
    allSingerAlbums.forEach((singer, albums) {
      uniqueSingers.add(singer);
      for (var albumData in albums) {
        final songs = albumData['songs'] as List<dynamic>? ?? [];
        for (var songData in songs) {
          if (songData is Map<String, dynamic>) {
            final String? title = songData['title'];
            final String? lyrics = songData['lyrics'];
            final String? category = songData['category'];
            if (title != null && lyrics != null && title.isNotEmpty && lyrics.isNotEmpty) {
              loadedHymns.add({
                'title': title,
                'singer': singer,
                'lyrics': lyrics,
                'albumTitle': albumData['albumTitle'] ?? 'Untitled Album',
                'category': category ?? 'Uncategorized',
                'albumImagePath': albumData['albumImagePath'],
              });

              if (category != null && category.isNotEmpty && category != 'Uncategorized') {
                final hymnsList = _drawerSubCategories[hymnsSectionKey] ?? [];
                bool isPredefined = hymnsList.any((item) {
                  if (item is String) return item == category;
                  if (item is Map) {
                    final dynamic value = item.values.first;
                    if (value is List) return value.contains(category);
                  }
                  return false;
                });
                if (!isPredefined) {
                  uniqueDynamicCategoriesFromData.add(category);
                }
              }
            }
          }
        }
      }
    });

    loadedHymns.sort((a, b) => (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase()));

    if (mounted) {
      setState(() {
        _allHymns = loadedHymns;
        _allSingers = uniqueSingers.toList()..sort();
        _dynamicCategories = uniqueDynamicCategoriesFromData.toList()..sort();
        _selectedCategory = _internalAllHymnsKey;
        _filteredHymns = List.from(_allHymns);
        _filteredSingers = List.from(_allSingers);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() => _searchHistory = prefs.getStringList('searchHistory') ?? []);
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('searchHistory', _searchHistory);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  void _addSearchToHistory(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    if (mounted) {
      setState(() {
        _searchHistory.remove(trimmedQuery);
        _searchHistory.insert(0, trimmedQuery);
        if (_searchHistory.length > 13) {
          _searchHistory.removeLast();
        }
      });
      _saveSearchHistory();
    }
  }

  void _clearSearchHistory() {
    if (mounted) setState(() => _searchHistory.clear());
    _saveSearchHistory();
  }

  List<Map<String, dynamic>> _getHymnsForCategory(String categoryKey) {
    if (categoryKey == _internalAllHymnsKey) {
      return List.from(_allHymns);
    }
    return _allHymns.where((hymn) => hymn['category'] == categoryKey).toList();
  }

  List<Map<String, dynamic>> _getHymnsForSearch(String query) {
    final lowerCaseQuery = query.toLowerCase().trim();
    if (lowerCaseQuery.isEmpty) return [];
    return _allHymns.where((hymn) {
      final title = hymn['title']?.toString().toLowerCase() ?? '';
      final singer = hymn['singer']?.toString().toLowerCase() ?? '';
      final lyrics = hymn['lyrics']?.toString().toLowerCase() ?? '';
      return title.contains(lowerCaseQuery) ||
          singer.contains(lowerCaseQuery) ||
          lyrics.contains(lowerCaseQuery);
    }).toList();
  }

  void _performHymnSearch(String query) {
    if (mounted) {
      setState(() {
        _filteredHymns = query.trim().isEmpty 
            ? _getHymnsForCategory(_selectedCategory) 
            : _getHymnsForSearch(query);
      });
    }
  }

  void _handleSearchSubmit(String query) {
    if (_currentMode == _AppMode.hymns) {
      _addSearchToHistory(query);
      _performHymnSearch(query);
      _searchFocusNode.unfocus();
    }
  }

  void _filterSingers(String query) {
    final lowerCaseQuery = query.toLowerCase().trim();
    if (mounted) {
      setState(() {
        if (lowerCaseQuery.isEmpty) {
          _filteredSingers = List.from(_allSingers);
        } else {
          _filteredSingers = _allSingers
              .where((s) => s.toLowerCase().contains(lowerCaseQuery))
              .toList();
        }
      });
    }
  }

  void _switchMode(_AppMode newMode, {String? newSelectedCategory, String? newAppBarTitle}) {
    if (_currentMode == newMode) {
      if (_pageController.hasClients && _pageController.page?.round() != 0) {
        _pageController.jumpToPage(0);
        if (mounted) setState(() => _selectedIndex = 0);
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }
    if (mounted) {
      setState(() {
        _currentMode = newMode;
        _selectedIndex = 0;
        
        _currentAppBarTitle = newAppBarTitle ?? _getDefaultAppBarTitle(newMode);

        if (newMode != _AppMode.hymns) {
          _searchHymnsController.clear();
          _searchSingersController.clear();
          if (_searchFocusNode.hasFocus) {
            _searchFocusNode.unfocus();
          }
        }
        
        _selectedCategory = newSelectedCategory ?? _internalAllHymnsKey;
        _performHymnSearch('');
        _filterSingers('');

        if (_pageController.hasClients && _pageController.page?.round() != 0) {
          _pageController.jumpToPage(0);
        }
      });
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  String _getDefaultAppBarTitle(_AppMode mode, {int tabIndex = 0}) {
    const String baseTitle = 'መኣዲ ፀጋ';
    switch (mode) {
      case _AppMode.home:
        return baseTitle;
      case _AppMode.hymns:
        return '$baseTitle - መዛሙር';
      case _AppMode.saints:
        return tabIndex == 0 ? 'ታሪኽ ቅዱሳን' : 'ጥቕስታት ቅዱሳን';
    }
  }
  
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDrawerHymnCategorySelected(String categoryKey) {
    if (_currentMode != _AppMode.hymns) {
      _switchMode(_AppMode.hymns, newSelectedCategory: categoryKey);
    } else {
      setState(() {
        _selectedCategory = categoryKey;
        _searchHymnsController.clear();
        _performHymnSearch('');
        if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
        if (_pageController.hasClients && _pageController.page?.round() != 0) {
          _pageController.jumpToPage(0);
        }
        _selectedIndex = 0;
      });
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }
  
  void _showAboutAppDialog(BuildContext context) {
    final theme = Theme.of(context);
    const String appDisplayName = 'መኣዲ ፀጋ';
    final String currentYear = DateTime.now().year.toString();
    final String versionNumber = '1.1.0';
    showAboutDialog(
      context: context,
      applicationName: appDisplayName,
      applicationVersion: versionNumber,
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Image.asset('assets/images/others/jesus.jpg', width: 45, height: 45),
      ),
      applicationLegalese: '© $currentYear $appDisplayName',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'መወዳእታ ዝተመሓየሸሉ ዕለት፦ July 24, 2025',
                  style: GoogleFonts.notoSerifEthiopic(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color,
                      height: 1.5),
                ),
                const SizedBox(height: 10),
                Text(
                  "እንኳዕ ናብ መኣዲ ፀጋ ብደሓን መፃእኩም። እዛ ኣፕሊኬሽን እዚኣ ብ ባህልቢ ሃይለ ኣባል መዘምራን ካቶሊካዊት ልደታ ማርያም መቐለ ዝተዳለወት ኮይና፡ ቀንዲ ዕላማኣ ድማ ንዓኹም፡ ምእመናን፡ ዝተፈላለዩ ናይ ትግርኛ ካቶሊካውያን መዛሙር ምስ ስእሊ ናይ ቁምስናታት፡ ታሪኽ ህይወትን ጥቕስታትን ካቶሊካውያን ቅዱሳን፡ ከምኡ'ውን ብዙሓት ኣገደስቲ ፀሎታት (ንኣብነት \"ፀሎት መቑፀርያ ፣ መባእታ ትምህርቲ ክርስቶስ\") ብቐሊሉ ኣብ ኢድኩም ንምእታው እያ። ትሕዝቶ እዛ ኣፕሊኬሽንን ብቐፃሊ ክመሓየሽን ሓድሽ ነገራት ክውሰኾን እዩ።",
                  style: GoogleFonts.notoSerifEthiopic(
                      color: theme.textTheme.bodyMedium?.color, height: 1.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'መኣዲ ፀጋ ብቐንዱ ብዘይ ምትእስሳር መрበብ ሓበሬታ (ኦፍላይን) ንኽሰርሕ ተባሂላ ዝተነደፈት እያ።',
                  style: GoogleFonts.notoSerifEthiopic(
                      color: theme.textTheme.bodyMedium?.color, height: 1.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'ቀንዲ ፍሉይ ባህርያት፦',
                  style: GoogleFonts.notoSerifEthiopic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color ??
                          theme.textTheme.bodyLarge?.color,
                      height: 1.5),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• መዛሙር ካቶሊክ ብትግርኛ፦',
                          style: GoogleFonts.notoSerifEthiopic(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.6)),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 4.0, bottom: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '  ◦ ብዘመርቲ/ብቁምስና፦ ነቲ እትደልይዎ መዝሙር፡ በቲ ሽም ናይ መዘምራን ጉጅለ ወይ ቁምስና ብምምራፅ፡ ካብቲ ዝቐርበልኩም ዝርዝር ኣልበማት ክትረኽብዎ ትኽእሉ።',
                                style: GoogleFonts.notoSerifEthiopic(
                                    color: theme.textTheme.bodyMedium?.color,
                                    height: 1.6)),
                            const SizedBox(height: 4),
                            Text(
                                '  ◦ ብዓይነት (ካታጎሪ)፦ መዛሙር ከም በዓላት፡ ኣምልኾ፡ ምስጋና፡ ማርያም፡ ቅዱሳን፡ ልመና፡ ወዘተ ተባሂሎም ንቐሊል ኣጠቃቕማ ተጠርኒፎም ኣለዉ።',
                                style: GoogleFonts.notoSerifEthiopic(
                                    color: theme.textTheme.bodyMedium?.color,
                                    height: 1.6)),
                            const SizedBox(height: 4),
                            Text(
                                '  ◦ ብምድላይ (ሰርች)፦ ብኣርእስቲ መዝሙር፡ ብውሑዳት ቃላት ካብ ግጥሚ፡ ወይ ብሽም ዘማሪ ብምፅሓፍ ብቕልጡፍ ክትረኽቡ ትኽእሉ።',
                                style: GoogleFonts.notoSerifEthiopic(
                                    color: theme.textTheme.bodyMedium?.color,
                                    height: 1.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          "• ዝተፈላለዩ ፀሎታት፦ ከም መቑፀርያታት (ናይ ልቢ ኢየሱስ፡ ናይ መንፈስ ቅዱስ)፡ ፀሎት ናብ ልቢ ኢየሱስ፡ ከምኡ'ውን ካብ ህፃናት ጀሚሩ ንኹሉ ዕድመ ዝኸውን \"መባእታ ትምህርቲ ክርስቶስ\" ዝሓዘ እዩ።",
                          style: GoogleFonts.notoSansEthiopic(
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.6)),
                      const SizedBox(height: 4),
                      Text(
                          "• ታሪኽ ቅዱሳን፦ ሓፂр ታሪኽ ህይወት፡ ኣገደስቲ ፍፃሜታት፡ ከምኡ'ውን ጥቕስታት ናይ ካቶሊካውያን ቅዱሳን የቕрብ።",
                          style: GoogleFonts.notoSansEthiopic(
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.6)),
                      const SizedBox(height: 4),
                      Text(
                          '• ቐፃሊ ምምሕያሽ፦ እዛ ኣፕሊኬሽን በብግዜኡ ሓድሽ ትሕዝቶን መመሓየሽታትን እናተገብረላ ክትከይድ እያ።',
                          style: GoogleFonts.notoSansEthiopic(
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'መበገሲ፦',
                  style: GoogleFonts.notoSerifEthiopic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color ??
                          theme.textTheme.bodyLarge?.color,
                      height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'ነዛ ኣፕሊኬሽን ንኽትስራሕ ቀንዲ ዘለዓዓለኒ፡ ምእመናን ንመዛሙር፡ ፀሎታትን ታሪኽ ቅዱሳንን ብቐሊሉ ንኽረኽብዎም ንምሕጋዝን፡ ብፍላይ ሓደሽቲ መዛሙር ክወፁ ከለዉ ብቕልጡፍ ናብ ኢዶም ንምብፃሕን ዝነበረኒ ድሌት እዩ።',
                  style: GoogleFonts.notoSerifEthiopic(
                      color: theme.textTheme.bodyMedium?.color, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final ScaffoldState? scaffoldState = Scaffold.maybeOf(context);
        if (scaffoldState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return false;
        }
        if (_currentMode == _AppMode.hymns &&
            (_searchFocusNode.hasFocus || _searchSingersFocusNode.hasFocus)) {
          if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
          if (_searchSingersFocusNode.hasFocus) {
            _searchSingersFocusNode.unfocus();
          }
          return false;
        }
        if (_selectedIndex != 0) {
          _onItemTapped(0);
          return false;
        }
        if (_currentMode != _AppMode.home) {
          _switchMode(_AppMode.home,
              newAppBarTitle: _getDefaultAppBarTitle(_AppMode.home));
          return false;
        }
        final now = DateTime.now();
        final timeSinceLastBack = _lastBackPressed == null
            ? const Duration(seconds: 3)
            : now.difference(_lastBackPressed!);
        if (timeSinceLastBack > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          if (mounted) {
            final snackBarTextColor = isDark ? Colors.black87 : Colors.white;
            final snackBarBgColor = isDark ? Colors.grey.shade300 : Colors.grey[800];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'ንድሕሪት እንደገና ብምጥዋቕ ካብዚ ውፃእ',
                  style:
                      GoogleFonts.notoSerifEthiopic(color: snackBarTextColor),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: snackBarBgColor,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
          return false;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
          return true;
        }
      },
      child: Scaffold(
        drawer: _buildAppDrawer(),
        appBar: AppBar(
          backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
          foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
          leading: _currentMode == _AppMode.home
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: 'Open Menu & Categories',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to Home',
                  onPressed: () => _switchMode(_AppMode.home),
                ),
          title: Text(
            _currentAppBarTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? theme.colorScheme.onSurface : Colors.white,
            ),
          ),
          elevation: 4.0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: isDark ? null : const BoxDecoration(
            gradient: refinedPastelGradient,
          ),
          child: Builder(
            builder: (context) {
              if (_isLoading || _isVerifiedInstall == null) {
                return _buildLoadingScreen(context);
              }
              if (!(_isVerifiedInstall!)) {
                return _buildInvalidInstallScreen(context);
              }
              return _buildMainContent();
            },
          ),
        ),
        bottomNavigationBar: (_isLoading || !(_isVerifiedInstall ?? false))
            ? null
            : _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildMainContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: _getCurrentPages(),
      onPageChanged: (index) {
        if (mounted && _selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
            _currentAppBarTitle = _getDefaultAppBarTitle(_currentMode, tabIndex: index);

            if (_currentMode == _AppMode.hymns && index != 1 && _searchSingersController.text.isNotEmpty) {
              _searchSingersController.clear();
              _filterSingers('');
            }
            if (_currentMode == _AppMode.hymns && index != 0 && _isSearchFocused) {
              _searchFocusNode.unfocus();
            }
          });
        }
      },
    );
  }

  List<Widget> _getCurrentPages() {
    switch (_currentMode) {
      case _AppMode.home:
        return [ _buildHomeScreen(context), const MenuScreen(), ];
      case _AppMode.hymns:
        return [ _buildSongsScreen(context), _buildSingersScreen(context), ];
      case _AppMode.saints:
        return [ const SaintsHistoryScreen(), const QuotesOfSaintScreen(), ];
    }
  }

  Widget _buildBottomNavBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    List<BottomNavigationBarItem> items;
    switch (_currentMode) {
      case _AppMode.home: items = _homeNavItems; break;
      case _AppMode.hymns: items = _hymnsNavItems; break;
      case _AppMode.saints: items = _saintsNavItems; break;
      default: return const SizedBox.shrink();
    }
    
    return BottomNavigationBar(
      items: items,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? theme.colorScheme.surface.withOpacity(0.95) : primaryAppBarColor,
      selectedItemColor: isDark ? theme.colorScheme.primary : Colors.white,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.white.withOpacity(0.7),
      selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
      unselectedLabelStyle: theme.bottomNavigationBarTheme.unselectedLabelStyle,
      elevation: 8.0,
    );
  }

  Drawer _buildAppDrawer() {
    final theme = Theme.of(context);
    const String appDisplayName = 'መኣዲ ፀጋ';
    final Color defaultIconColor = theme.colorScheme.primary;
    final Color drawerTextColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final Color drawerSubTextColor = theme.textTheme.titleSmall?.color ?? Colors.grey[700]!;
    final Color drawerSelectedTextColor = theme.colorScheme.primary;
    final drawerBackgroundColor = theme.colorScheme.surface;
    final screenHeight = MediaQuery.of(context).size.height;

    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: screenHeight * 0.25,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/maryam_ms_weda.jpg'), fit: BoxFit.cover,),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [ Colors.transparent, Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7), ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(appDisplayName, style: GoogleFonts.notoSerifEthiopic(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                      shadows: [ Shadow(blurRadius: 3.0, color: Colors.black.withOpacity(0.8), offset: const Offset(1, 1),) ],
                    )),
                  const SizedBox(height: 4),
                  Text('Menu & Categories', style: GoogleFonts.notoSerifEthiopic(
                      color: Colors.white.withOpacity(0.9), fontSize: 16,
                      shadows: [ Shadow(blurRadius: 3.0, color: Colors.black.withOpacity(0.8), offset: const Offset(1, 1),) ],
                    )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Hymn Categories',
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: drawerSubTextColor.withOpacity(0.7)),
            ),
          ),
          
          ExpansionTile(
            key: const PageStorageKey<String>(hymnsSectionKey),
            leading: Icon(Icons.library_music_outlined, color: _currentMode == _AppMode.hymns ? drawerSelectedTextColor : defaultIconColor),
            title: Text('መዛሙር', style: theme.textTheme.titleMedium?.copyWith(
              color: _currentMode == _AppMode.hymns ? drawerSelectedTextColor : drawerTextColor,
            )),
            initiallyExpanded: _currentMode == _AppMode.hymns,
            children: [
              ...(_drawerSubCategories[hymnsSectionKey] ?? []).map<Widget>((item) {
                if(item is Map<String, List<String>>) {
                  String groupTitle = item.keys.first;
                  List<String> subItems = item.values.first;
                  return ExpansionTile(
                    leading: Icon(Icons.celebration_outlined, color: drawerSubTextColor.withOpacity(0.7), size: 20),
                    title: Text(groupTitle, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15, color: drawerSubTextColor)),
                    initiallyExpanded: false,
                    children: subItems.map((sub) => ListTile(
                      title: Text(sub, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15, color: _selectedCategory == sub ? drawerSelectedTextColor : drawerSubTextColor)),
                      selected: _selectedCategory == sub,
                      onTap: () => _onDrawerHymnCategorySelected(sub),
                    )).toList(),
                  );
                }
                return ListTile(
                  title: Text((item as String) == _internalAllHymnsKey ? 'ኩሎም መዛሙር' : item, 
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15, color: _selectedCategory == item ? drawerSelectedTextColor : drawerSubTextColor)),
                  selected: _selectedCategory == item,
                  onTap: () => _onDrawerHymnCategorySelected(item),
                );
              }),
            ],
          ),
          
          const Divider(height: 32),
          ListTile(
            leading: Icon(Icons.favorite_border, color: defaultIconColor),
            title: Text('ንዋየ-ልበይ (Favorites)', style: theme.textTheme.titleMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                SlowCupertinoPageRoute(builder: (context) => const FavoritesCategoryScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: defaultIconColor),
            title: Text('ብዛዕባ`ዚ ኣፕሊኬሽን', style: theme.textTheme.titleMedium),
            onTap: () {
              Navigator.pop(context);
              _showAboutAppDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: defaultIconColor),
            title: Text('Privacy Policy', style: theme.textTheme.titleMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                SlowCupertinoPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeScreen(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buildHomeGridItem({
      required String title,
      required Widget iconWidget,
      VoidCallback? onTap,
    }) {
      final borderRadius = theme.cardTheme.shape is RoundedRectangleBorder
          ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
          : BorderRadius.circular(15.0);

      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius as BorderRadius?,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4.0,
              shadowColor: Colors.black.withOpacity(0.3),
              child: carousel.CarouselSlider.builder(
                itemCount: _homeImagePaths.length,
                itemBuilder: (context, index, realIndex) {
                  final imagePath = _homeImagePaths[index];
                  return Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[600],
                          size: 50,
                        ),
                      );
                    },
                  );
                },
                options: carousel.CarouselOptions(
                  height: 220,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 8),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1200),
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.2,
              children: [
                buildHomeGridItem(
                  title: 'መዛሙር',
                  iconWidget: Icon(Icons.library_music_outlined, size: 40, color: homeGridIconColor),
                  onTap: () => _switchMode(_AppMode.hymns, newAppBarTitle: _getDefaultAppBarTitle(_AppMode.hymns)),
                ),
                buildHomeGridItem(
                  title: 'ፀሎታት',
                  iconWidget: Image.asset('assets/icons/my_prayer_icon.png', width: 40, height: 40, color: Colors.teal.shade600, errorBuilder: (c, e, s) => Icon(Icons.self_improvement_outlined, size: 40, color: Colors.teal.shade600)),
                  onTap: () => Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => const PrayerScreen())),
                ),
                buildHomeGridItem(
                  title: 'ትምህርተ ሃይማኖት',
                  iconWidget: Icon(Icons.school_outlined, size: 40, color: Colors.deepPurple.shade600),
                  onTap: () {
                    Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => const DoctrineScreen()));
                  },
                ),
                buildHomeGridItem(
                  title: 'መንፈሳዊ ህይወት',
                  iconWidget: Icon(Icons.lightbulb_outline, size: 40, color: Colors.amber.shade700),
                  onTap: () {
                    Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => const SpiritualLifeScreen()));
                  },
                ),
                buildHomeGridItem(
                  title: 'መፅሓፍ ቅዱስን ትውፊትን',
                  iconWidget: Icon(Icons.auto_stories_outlined, size: 40, color: Colors.green.shade700),
                  onTap: () {
                    Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => const BibleTraditionScreen()));
                  },
                ),
                buildHomeGridItem(
                  title: 'ማሕበራዊ ትምህርቲ',
                  iconWidget: Icon(Icons.groups_outlined, size: 40, color: Colors.orange.shade800),
                  onTap: () {
                    Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => const SocialTeachingScreen()));
                  },
                ),
                buildHomeGridItem(
                  title: 'ታሪኽ ቅዱሳን',
                  iconWidget: Image.asset('assets/icons/saint_history.png', width: 40, height: 40, color: Colors.brown.shade600, errorBuilder: (c, e, s) => Icon(Icons.church_outlined, size: 40, color: Colors.brown.shade600)),
                  onTap: () => _switchMode(_AppMode.saints, newAppBarTitle: _getDefaultAppBarTitle(_AppMode.saints)),
                ),
                buildHomeGridItem(
                  title: 'ታሪኽ ቤተክርስትያን',
                  iconWidget: Icon(Icons.history_edu_outlined, size: 40, color: Colors.indigo.shade600),
                  onTap: () {
                    Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => const ChurchHistoryScreen()));
                  },
                ),
                buildHomeGridItem(
                  title: 'ተወሳኺ ትሕዝቶ',
                  iconWidget: Icon(Icons.hourglass_empty_rounded, size: 40, color: Colors.grey.shade600),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('እዚ ክፍል ገና ኣብ ምስራሕ እዩ ዝርከብ።', style: GoogleFonts.notoSerifEthiopic()),
                      backgroundColor: Colors.grey[800],
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSongsScreen(BuildContext context) {
     final theme = Theme.of(context);
     final isDark = theme.brightness == Brightness.dark;
    final bool isSearching = _searchHymnsController.text.isNotEmpty;
    final bool showHistory =
        _isSearchFocused && !isSearching && _searchHistory.isNotEmpty;
    final bool showCategoryContent = !isSearching && !showHistory && !_isLoading;
    final bool isSpecificCategorySelected =
        _selectedCategory != _internalAllHymnsKey;
    final String? categoryBannerPath = showCategoryContent &&
            isSpecificCategorySelected
        ? _hymnCategoryImages[_selectedCategory]
        : null;
    final categoryTitleStyle = theme.textTheme.headlineSmall
        ?.copyWith(color: theme.textTheme.bodyMedium?.color, fontSize: 19);

    return GestureDetector(
      onTap: () {
        if (_isSearchFocused) _searchFocusNode.unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: TextField(
              controller: _searchHymnsController,
              focusNode: _searchFocusNode,
              onSubmitted: _handleSearchSubmit,
              onChanged: _performHymnSearch,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                hintText: 'መዝሙር፣ ዘማሪ ወይ ግጥሚ ድለ...',
                hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.6)),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7),
                ),
                suffixIcon: _searchHymnsController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7),
                        ),
                        tooltip: 'Clear Search',
                        onPressed: () {
                          _searchHymnsController.clear();
                          _performHymnSearch('');
                          if (_searchFocusNode.hasFocus) {
                            _searchFocusNode.unfocus();
                          }
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (categoryBannerPath != null)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 250.0,
                      margin: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          categoryBannerPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250.0,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(Icons.broken_image_outlined,
                                  color: Colors.grey.shade600, size: 40),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                if (showCategoryContent && isSpecificCategorySelected)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: categoryBannerPath != null ? 8.0 : 4.0),
                      child: Text(
                        _selectedCategory,
                        style: categoryTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                _buildSliverContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverContent(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSearching = _searchHymnsController.text.isNotEmpty;
    final bool showHistory =
        _isSearchFocused && !isSearching && _searchHistory.isNotEmpty;
    if (_isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
            key: const ValueKey('loading'),
            child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    } else if (showHistory) {
      return _buildSliverSearchHistoryList(context);
    } else {
      return _buildSliverHymnList(context, _filteredHymns, isSearching);
    }
  }

  Widget _buildSliverSearchHistoryList(BuildContext context) {
    final theme = Theme.of(context);
    final historyTitleStyle = theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7));
    final clearButtonStyle =
        TextStyle(color: theme.colorScheme.error.withOpacity(0.8), fontSize: 12);
    final historyItemStyle = theme.textTheme.bodyMedium;
    final historyIconColor = Colors.grey[600];
    return SliverList(
      key: const ValueKey('history_sliver'),
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Search History', style: historyTitleStyle),
              if (_searchHistory.isNotEmpty)
                TextButton(
                  onPressed: _clearSearchHistory,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30)),
                  child: Text('Clear All', style: clearButtonStyle),
                ),
            ],
          ),
        ),
        ..._searchHistory.map((historyTerm) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                  leading: Icon(Icons.history, color: historyIconColor, size: 20),
                  title: Text(historyTerm, style: historyItemStyle),
                  onTap: () {
                    _searchHymnsController.text = historyTerm;
                    _searchHymnsController.selection =
                        TextSelection.fromPosition(
                            TextPosition(offset: historyTerm.length));
                    _handleSearchSubmit(historyTerm);
                  },
                  dense: true,
                )),
        const SizedBox(height: 80.0),
      ]),
    );
  }

  Widget _buildSliverHymnList(BuildContext context,
      List<Map<String, dynamic>> hymns, bool isSearching) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final subtitleStyle = theme.textTheme.titleSmall;
    final emptyMessageStyle =
        theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontSize: 16);
    final iconColor = theme.listTileTheme.iconColor;
    final trailingIconColor = Colors.grey;

    if (hymns.isEmpty && !_isLoading) {
      String message;
      String displayCategory = (_selectedCategory == _internalAllHymnsKey)
          ? 'All Hymns'
          : _selectedCategory;
      if (isSearching) {
        message = '"${_searchHymnsController.text}" ዝብል ቃል ዝሓዘ መዝሙр ኣይተረኽበን።';
      } else if (_selectedCategory == _internalAllHymnsKey &&
          _allHymns.isEmpty) {
        message = 'ዝተፃዕነ መዝሙр የለን። ነቲ ናይ ዳта ምንጪ መрмр።';
      } else if (_selectedCategory != _internalAllHymnsKey) {
        message = '"$displayCategory" ኣብ тሕти እዚ ኣрእስти መзሙр የለን።';
      } else {
        message = 'зрከብ መзሙр የለን።';
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
            key: ValueKey(
                'empty_hymn_sliver_${isSearching ? _searchHymnsController.text : _selectedCategory}'),
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(message,
                    textAlign: TextAlign.center, style: emptyMessageStyle))),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 80.0, left: 4.0, right: 4.0, top: 4.0),
      sliver: SliverList(
        key: ValueKey(
            'hymn_sliver_${isSearching ? _searchHymnsController.text : _selectedCategory}'),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final hymn = hymns[index];
            final title = hymn['title'] as String? ?? 'Untitled Song';
            final singer = hymn['singer'] as String? ?? 'Unknown Singer';
            return Card(
              child: ListTile(
                leading:
                    Icon(Icons.music_note_outlined, color: iconColor, size: 24),
                title: Text(title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(singer, style: subtitleStyle),
                trailing:
                    Icon(Icons.arrow_forward_ios, size: 14, color: trailingIconColor),
                onTap: () {
                  if (isSearching) {
                    _addSearchToHistory(_searchHymnsController.text);
                  }
                  Navigator.push(
                    context,
                    SlowCupertinoPageRoute(
                      builder: (context) => LyricsScreen(hymn: hymn),
                    ),
                  );
                },
              ),
            );
          },
          childCount: hymns.length,
        ),
      ),
    );
  }

  Widget _buildSingersScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }
    if (_allSingers.isEmpty) {
      return Center(
          child: Text('No singers found.', style: theme.textTheme.bodyMedium));
    }

    final titleStyle = theme.textTheme.titleMedium;
    final trailingIconColor = Colors.grey;
    return GestureDetector(
      onTap: () {
        if (_searchSingersFocusNode.hasFocus) _searchSingersFocusNode.unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: TextField(
              controller: _searchSingersController,
              focusNode: _searchSingersFocusNode,
              onChanged: _filterSingers,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                hintText: 'ሽም ዘማሪ ድለ...',
                hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.6)),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7),
                ),
                suffixIcon: _searchSingersController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                           color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7),
                        ),
                        tooltip: 'Clear Search',
                        onPressed: () {
                          _searchSingersController.clear();
                          _filterSingers('');
                          if (_searchSingersFocusNode.hasFocus) {
                            _searchSingersFocusNode.unfocus();
                          }
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80.0, left: 4.0, right: 4.0),
              itemCount: _filteredSingers.length,
              itemBuilder: (context, index) {
                final singer = _filteredSingers[index];
                final dynamic singerAlbumData = allSingerAlbums[singer];
                final List<Map<String, dynamic>> singerAlbums =
                    (singerAlbumData is List)
                        ? singerAlbumData.whereType<Map<String, dynamic>>().toList()
                        : [];
                final String? imagePath = app_constants.singerImagePaths[singer];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Material(
                      type: MaterialType.transparency,
                      child: Hero(
                        tag: 'singer_image_$singer',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: (imagePath != null && imagePath.isNotEmpty) 
                              ? AssetImage(imagePath) 
                              : null,
                          child: (imagePath == null || imagePath.isEmpty) 
                              ? const Icon(Icons.person, size: 28) 
                              : null,
                        ),
                      ),
                    ),
                    title: Text(singer, style: titleStyle?.copyWith(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: trailingIconColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlowCupertinoPageRoute(
                          builder: (context) => SingerScreen(
                            singer: singer,
                            albums: singerAlbums,
                            imagePath: imagePath,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              'assets/images/others/jesus.jpg',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  size: 80,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 15),
          Text(
            'ትሕዝቶ ይፅዓን ኣሎ...',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidInstallScreen(BuildContext context) {
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.meaditsega.BHLabs';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.security, color: Colors.red.shade700, size: 80),
            const SizedBox(height: 24),
            Text(
              'ዘይወግዓዊ ስሪት',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifEthiopic(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "ነዛ ኣፕሊኬሽን ካብ ዘይተፈቕደ ምንጪ ስለ ዘውረድኩምዋ፡ ክትሰርሕ ኣይትኽእልን እያ። በጃኹም፡ ነዛ ናይ ሓሶት ስሪት ኣልጊስኩም፡ ነታ ወግዓዊት ካብ Google Play Store ጥራይ ኣውርድዋ።",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifEthiopic(
                fontSize: 16,
                height: 1.6,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.shop),
              label: Text('ካብ Play Store ኣውርድ', style: GoogleFonts.notoSansEthiopic()),
              onPressed: () async {
                final uri = Uri.parse(playStoreUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, 
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}