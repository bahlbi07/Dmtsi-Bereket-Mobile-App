import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meadi_tsga/custom_page_route.dart';
import '../utils/analytics_service.dart'; // ሓዱሽ ሰርቪስ

// ናይ ዳታ ፋይላት እቱው ዝኾኑሉ
import 'package:meadi_tsga/data/prayer_content_data.dart';
import 'package:meadi_tsga/data/saints_history_data.dart';
import 'package:meadi_tsga/data/doctrine_data.dart';
import 'package:meadi_tsga/data/spiritual_life_data.dart';
import 'package:meadi_tsga/data/church_history_data.dart';

// ንመዛረቢ ዝጠቕሙ ስክሪናት
import 'prayer_content_screen.dart';
import 'saints_history_screen.dart';
import 'doctrine_screen.dart';
import 'spiritual_life_screen.dart';
import 'church_history_screen.dart';

// 🔥 ፍጥነት ንምሕላው ዝሕግዝ (Debouncer)
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String type; // prayer, saint, doctrine, spiritual, church
  final dynamic data;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.data,
  });
}

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  /// 🔥 ካብቲ ዳታ ሓደ ብራንደም ጥቅስ መሪጹ ዘጽርይ static ፈንክሽን
  static Map<String, String> getRandomQuote(Map<String, dynamic> quotesData) {
    try {
      final List<Map<String, String>> allQuotes = [];

      quotesData.forEach((category, list) {
        if (category != 'መእተዊ' && list is List) {
          for (var item in list) {
            if (item is Map) {
              String rawQuote = item['quote']?.toString() ?? '';

              // Regex cleanup
              rawQuote = rawQuote
                  .replaceAll(
                      RegExp(
                          r'^[\x27\x22\u201c\u201d]+|[\x27\x22\u201c\u201d]+$'),
                      '')
                  .trim();

              allQuotes.add({
                'quote': rawQuote,
                'author': item['author']?.toString() ?? 'Unknown',
              });
            }
          }
        }
      });

      if (allQuotes.isNotEmpty) {
        final random = math.Random();
        return allQuotes[random.nextInt(allQuotes.length)];
      }
    } catch (e) {
      // Failsafe
    }

    return {
      'quote':
          'ወትሩ ምስ እግዚኣብሔር ኪኸውን ዝደሊ ሰብ፡ ብዙሕ ጊዜ ኣብ ጸሎትን መንፈሳዊ ንባብን ኪጽመድ የድልዮ',
      'author': 'ቅዱስ ኣጐስጢኖስ',
    };
  }

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  List<SearchResult> _results = [];
  bool _isSearching = false;
  String? _suggestedWord;

  // ቃላት ንምእራም ንምሕጋዝ ዝእከቡ ቃላት (Search Dictionary)
  final Set<String> _searchDictionary = {};

  @override
  void initState() {
    super.initState();
    _buildDictionary();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _buildDictionary() {
    final Set<String> words = {};

    // 1. ጸሎታት
    for (var key in allPrayersContent.keys) {
      words.addAll(_extractWords(key));
    }
    // 2. ቅዱሳን
    for (var key in saintsHistoryContent.keys) {
      words.addAll(_extractWords(key));
    }
    // 3. ትምህርተ ሃይማኖት
    for (var subTopics in doctrineDetailsContent.values) {
      for (var sub in subTopics) {
        final title = sub['title'] as String? ?? '';
        words.addAll(_extractWords(title));
      }
    }
    // 4. መንፈሳዊ ህይወት
    for (var topic in spiritualLifeTopics) {
      final title = topic['title'] as String? ?? '';
      words.addAll(_extractWords(title));
    }
    // 5. ታሪኽ ቤተ-ክርስትያን
    final allChurch = [...churchHistoryPartOne, ...churchHistoryPartTwo];
    for (var topic in allChurch) {
      final title = topic['title'] ?? '';
      words.addAll(_extractWords(title));
    }

    _searchDictionary.addAll(words);
  }

  Set<String> _extractWords(String text) {
    return text
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w\u1200-\u137F]'), '').trim())
        .where((w) => w.length > 2)
        .toSet();
  }

  // =======================================================================
  // ሓያል ናይ ምድላይ ቴክኖሎጂ (Advanced Search Core Helper Functions)
  // =======================================================================

  static String _preProcessEnglish(String input) {
    String res = input.toLowerCase();
    Map<String, String> engMap = {
      'kurban': 'qurban',
      'eyesus': 'iyesus',
      'yesus': 'iyesus',
      'mariam': 'maryam',
      'mariyaam': 'maryam',
      'tsadkan': 'tsadqan',
      'medhanialem': 'medhanyalem'
    };
    engMap.forEach((key, value) {
      res = res.replaceAll(key, value);
    });
    return res;
  }

  static String _transliterateToGeez(String input) {
    String source = input.toLowerCase();
    final Map<String, List<String>> matrix = {
      'h': ['ሀ', 'ሁ', 'ሂ', 'ሃ', 'ሄ', 'ህ', 'ሆ'],
      'l': ['ለ', 'ሉ', 'ሊ', 'ላ', 'ሌ', 'ል', 'ሎ'],
      'm': ['መ', 'ሙ', 'ሚ', 'ማ', 'ሜ', 'ም', 'ሞ'],
      'r': ['ረ', 'ሩ', 'ሪ', 'ራ', 'ሬ', 'ር', 'ሮ'],
      's': ['ሰ', 'ሱ', 'ሲ', 'ሳ', 'ሴ', 'ስ', 'ሶ'],
      'sh': ['ሸ', 'ሹ', 'ሺ', 'ሻ', 'ሼ', 'ሽ', 'ሾ'],
      'q': ['ቀ', 'ቁ', 'ቂ', 'ቃ', 'ቄ', 'ቅ', 'ቆ'],
      'b': ['በ', 'ቡ', 'ቢ', 'ባ', 'ቤ', 'ብ', 'ቦ'],
      't': ['ተ', 'ቱ', 'ቲ', 'ታ', 'ቴ', 'ት', 'ቶ'],
      'ch': ['ቸ', 'ቹ', 'ቺ', 'ቻ', 'ቼ', 'ች', 'ቾ'],
      'n': ['ነ', 'ኑ', 'ኒ', 'ና', 'ኔ', 'ን', 'ኖ'],
      'gn': ['ኘ', 'ኙ', 'ኚ', 'ኛ', 'ኜ', 'ኝ', 'ኞ'],
      'a': ['አ', 'ኡ', 'ኢ', 'ኣ', 'ኤ', 'እ', 'ኦ'],
      'k': ['ከ', 'ኩ', 'ኪ', 'ካ', 'ኬ', 'ክ', 'ኮ'],
      'w': ['ወ', 'ው', 'ዊ', 'ዋ', 'ዌ', 'ው', 'ዎ'],
      'z': ['ዘ', 'ዙ', 'ዚ', 'ዛ', 'ዜ', 'ዝ', 'ዞ'],
      'zh': ['ዠ', 'ዡ', 'ዢ', 'ዣ', 'ዤ', 'ዥ', 'ዦ'],
      'y': ['የ', 'ዩ', 'ዪ', 'ያ', 'ዬ', 'ይ', 'ዮ'],
      'd': ['ደ', 'ዱ', 'ዲ', 'ዳ', 'ዴ', 'ድ', 'ዶ'],
      'j': ['ጀ', 'ጁ', 'ጂ', 'ጃ', 'ጄ', 'ጅ', 'ጆ'],
      'g': ['ገ', 'ጉ', 'ጊ', 'ጋ', 'ጌ', 'ግ', 'ጎ'],
      'ts': ['ጸ', 'ጸ', 'ጺ', 'ጻ', 'ጼ', 'ጽ', 'ጾ'],
      'f': ['ፈ', 'ፉ', 'ፊ', 'ፋ', 'ፌ', 'ፍ', 'ፎ'],
      'p': ['ፐ', 'ፑ', 'ፒ', 'ፓ', 'ፔ', 'ፕ', 'ፖ'],
      'v': ['ቨ', 'ቩ', 'ቪ', 'ቫ', 'ቬ', 'ቭ', 'ቮ'],
    };

    String result = "";
    int i = 0;
    while (i < source.length) {
      String char = source[i];
      String? nextChar = (i + 1 < source.length) ? source[i + 1] : null;
      String key = char;
      int step = 1;
      if (nextChar != null && matrix.containsKey("$char$nextChar")) {
        key = "$char$nextChar";
        step = 2;
      }
      if (matrix.containsKey(key)) {
        List<String> forms = matrix[key]!;
        String vowel = (i + step < source.length) ? source[i + step] : "";
        if (vowel == 'e') {
          result += forms[0];
          i += step + 1;
        } else if (vowel == 'u') {
          result += forms[1];
          i += step + 1;
        } else if (vowel == 'i') {
          result += forms[2];
          i += step + 1;
        } else if (vowel == 'a') {
          result += forms[3];
          i += step + 1;
        } else if (vowel == 'o') {
          result += forms[6];
          i += step + 1;
        } else {
          result += (key == 'a') ? forms[0] : forms[5];
          i += step;
        }
      } else {
        result += char;
        i++;
      }
    }
    return result;
  }

  static String _advancedNormalize(String input) {
    if (input.isEmpty) return input;
    String res = input.trim();
    Map<String, String> wordMap = {
      'እ/ር': 'እግዚኣብሔር',
      'እ/ሄር': 'እግዚኣብሔር',
      'ተ/ን': 'ተመስገን',
      'ብጊሓት': 'ብጉሓት',
      'ሸብሸባ': 'ሽብሸባ',
      'ዝተገነየ': 'ዝተረኸበ',
      'ማሪያም': 'ማርያም',
      'እየሱስ': 'ኢየሱስ',
      'የሱስ': 'ኢየሱስ',
      'ዝፋን': 'ዙፋን',
      "ሳላ'ቲ": 'ሳላ እቲ',
      "ሳላ`ቲ": 'ሳላ እቲ',
      'ሳላቲ': 'ሳላ እቲ',
      "'ዩ": 'እዩ',
      "`ዩ": 'እዩ',
      "’ዩ": 'እዩ',
      "'ቲ": 'እቲ',
      "`ቲ": 'እቲ',
      "’ቲ": 'እቲ',
    };
    wordMap.forEach((key, value) {
      res = res.replaceAll(key, value);
    });
    res = res
        .replaceAll(RegExp(r'[ጸ]'), 'ጸ')
        .replaceAll(RegExp(r'[ጹ]'), 'ጹ')
        .replaceAll(RegExp(r'[ጺ]'), 'ጺ')
        .replaceAll(RegExp(r'[ጻ]'), 'ጻ')
        .replaceAll(RegExp(r'[ጼ]'), 'ጼ')
        .replaceAll(RegExp(r'[ጽ]'), 'ጽ')
        .replaceAll(RegExp(r'[ፆ]'), 'ጾ')
        .replaceAll(RegExp(r'[ሠ]'), 'ሰ')
        .replaceAll(RegExp(r'[ሡ]'), 'ሱ')
        .replaceAll(RegExp(r'[ሢ]'), 'ሲ')
        .replaceAll(RegExp(r'[ሣ]'), 'ሳ')
        .replaceAll(RegExp(r'[ሤ]'), 'ሴ')
        .replaceAll(RegExp(r'[ሥ]'), 'ስ')
        .replaceAll(RegExp(r'[ሦ]'), 'ሶ')
        .replaceAll(RegExp(r'[ሐኈ]'), 'ሀ')
        .replaceAll(RegExp(r'[ሑኁ]'), 'ሁ')
        .replaceAll(RegExp(r'[ሒኂ]'), 'ሂ')
        .replaceAll(RegExp(r'[ሓኃ]'), 'ሃ')
        .replaceAll(RegExp(r'[ሔኄ]'), 'ሄ')
        .replaceAll(RegExp(r'[ሕኅ]'), 'ህ')
        .replaceAll(RegExp(r'[ሖኆ]'), 'ሆ')
        .replaceAll(RegExp(r'[ዐ]'), 'አ')
        .replaceAll(RegExp(r'[ዑ]'), 'ኡ')
        .replaceAll(RegExp(r'[ዒ]'), 'ኢ')
        .replaceAll(RegExp(r'[ዓ]'), 'ዓ')
        .replaceAll(RegExp(r'[ዔ]'), 'ኤ')
        .replaceAll(RegExp(r'[ዕ]'), 'እ')
        .replaceAll(RegExp(r'[ዖ]'), 'ኦ')
        .replaceAll(RegExp(r'[ቐ]'), 'ቀ')
        .replaceAll(RegExp(r'[ቑ]'), 'ቁ')
        .replaceAll(RegExp(r'[ቒ]'), 'ቂ')
        .replaceAll(RegExp(r'[ቓ]'), 'ቃ')
        .replaceAll(RegExp(r'[ቔ]'), 'ቄ')
        .replaceAll(RegExp(r'[ቕ]'), 'ቅ')
        .replaceAll(RegExp(r'[ቖ]'), 'ቆ')
        .replaceAll(RegExp(r'[ኸ]'), 'ከ')
        .replaceAll(RegExp(r'[ኹ]'), 'ኩ')
        .replaceAll(RegExp(r'[ኺ]'), 'ኪ')
        .replaceAll(RegExp(r'[ኻ]'), 'ካ')
        .replaceAll(RegExp(r'[ኼ]'), 'ኬ')
        .replaceAll(RegExp(r'[ኽ]'), 'ክ')
        .replaceAll(RegExp(r'[ኾ]'), 'ኮ');

    res = res.replaceAll(RegExp(r'[^\w\s\u1200-\u137F]'), '');
    return res.toLowerCase();
  }

  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);
    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }
    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = math.min(v1[j] + 1, math.min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  static String? _findSuggestion(String query, Set<String> dictionary) {
    if (query.isEmpty || query.length < 3) return null;
    String closestMatch = "";
    int minDistance = 999;
    for (String word in dictionary) {
      int dist = _levenshteinDistance(query, word);
      if (dist < minDistance && dist <= 2) {
        minDistance = dist;
        closestMatch = word;
      }
    }
    return (closestMatch.isNotEmpty && closestMatch != query)
        ? closestMatch
        : null;
  }

  void _onSearchChanged(String query) {
    setState(() => _isSearching = true);
    _debouncer.run(() {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _suggestedWord = null;
        _isSearching = false;
      });
      return;
    }

    // ሰርች ዝተገበሩ ቃላት ምምዝጋብ (ጠለብ 10)
    AnalyticsService.track('search_executed', {
      'query': query.trim(),
    });

    bool isEnglish = RegExp(r'[a-zA-Z]').hasMatch(query);
    String mappedQuery =
        isEnglish ? _transliterateToGeez(_preProcessEnglish(query)) : query;
    final q = _advancedNormalize(mappedQuery);

    List<SearchResult> temp = [];

    // 1. ጸሎታት
    allPrayersContent.forEach((key, blocks) {
      final normKey = _advancedNormalize(key);
      bool textMatch = false;
      for (var block in blocks) {
        if (block['text'] != null) {
          final normText = _advancedNormalize(block['text'].toString());
          if (normText.contains(q)) {
            textMatch = true;
            break;
          }
        }
      }
      if (normKey.contains(q) || textMatch) {
        temp.add(SearchResult(
          title: key,
          subtitle: 'ጸሎታት',
          type: 'prayer',
          data: key,
        ));
      }
    });

    // 2. ቅዱሳን
    saintsHistoryContent.forEach((saintName, blocks) {
      final normName = _advancedNormalize(saintName);
      bool textMatch = false;
      for (var block in blocks) {
        if (block['text'] != null) {
          final normText = _advancedNormalize(block['text'].toString());
          if (normText.contains(q)) {
            textMatch = true;
            break;
          }
        }
      }
      if (normName.contains(q) || textMatch) {
        temp.add(SearchResult(
          title: saintName,
          subtitle: 'ታሪኽ ቅዱሳን',
          type: 'saint',
          data: saintName,
        ));
      }
    });

    // 3. ትምህርተ ሃይማኖት
    doctrineDetailsContent.forEach((key, subTopics) {
      for (var subTopic in subTopics) {
        final title = subTopic['title'] as String;
        final normTitle = _advancedNormalize(title);
        bool textMatch = false;
        if (subTopic['content'] != null) {
          final content = subTopic['content'] as List<dynamic>;
          for (var block in content) {
            if (block['text'] != null) {
              final normText = _advancedNormalize(block['text'].toString());
              if (normText.contains(q)) {
                textMatch = true;
                break;
              }
            }
          }
        }
        if (normTitle.contains(q) || textMatch) {
          temp.add(SearchResult(
            title: title,
            subtitle: 'ትምህርተ ሃይማኖት',
            type: 'doctrine',
            data: {'subTopic': subTopic, 'mainTopicKey': key},
          ));
        }
      }
    });

    // 4. መንፈሳዊ ህይወት
    for (var topic in spiritualLifeTopics) {
      final title = topic['title'] as String;
      final normTitle = _advancedNormalize(title);
      bool textMatch = false;
      final content = topic['content'] as List<dynamic>;
      for (var block in content) {
        if (block['text'] != null) {
          final normText = _advancedNormalize(block['text'].toString());
          if (normText.contains(q)) {
            textMatch = true;
            break;
          }
        }
      }
      if (normTitle.contains(q) || textMatch) {
        temp.add(SearchResult(
          title: title,
          subtitle: 'መንፈሳዊ ህይወት',
          type: 'spiritual',
          data: topic,
        ));
      }
    }

    // 5. ታሪኽ ቤተ-ክርስትያን
    final allChurch = [...churchHistoryPartOne, ...churchHistoryPartTwo];
    for (var topic in allChurch) {
      final title = topic['title'] as String;
      final content = topic['content'] as String;
      final normTitle = _advancedNormalize(title);
      final normContent = _advancedNormalize(content);
      if (normTitle.contains(q) || normContent.contains(q)) {
        temp.add(SearchResult(
          title: title,
          subtitle: 'ታሪኽ ቤተ-ክርስትያን',
          type: 'church',
          data: topic,
        ));
      }
    }

    String? suggested;
    if (temp.isEmpty && q.isNotEmpty) {
      suggested = _findSuggestion(mappedQuery, _searchDictionary);
    }

    setState(() {
      _results = temp;
      _suggestedWord = suggested;
      _isSearching = false;
    });
  }

  void _navigateToResult(SearchResult result) {
    HapticFeedback.lightImpact();
    Widget? targetScreen;

    switch (result.type) {
      case 'prayer':
        targetScreen = PrayerContentViewer(
          categoryTitle: 'ጸሎታት',
          prayerKeys: [result.title],
          initialIndex: 0,
          displayMode: PrayerDisplayMode.pageView,
        );
        break;
      case 'saint':
        targetScreen = SaintTOCScreen(saintName: result.title);
        break;
      case 'doctrine':
        final mainTopicTitle = doctrineTopics.firstWhere(
            (t) => t['key'] == result.data['mainTopicKey'],
            orElse: () => {'title': 'ትምህርተ ሃይማኖት'})['title'] as String;
        targetScreen = DoctrineViewerScreen(
          mainTopicTitle: mainTopicTitle,
          subTopics: [result.data['subTopic']],
          initialIndex: 0,
        );
        break;
      case 'spiritual':
        targetScreen = SpiritualLifeViewerScreen(
          allTopics: [result.data],
          initialIndex: 0,
        );
        break;
      case 'church':
        targetScreen = ChurchHistoryViewerScreen(
          allTopics: [result.data],
          initialIndex: 0,
        );
        break;
    }

    if (targetScreen != null) {
      Navigator.push(
          context, SlowCupertinoPageRoute(builder: (context) => targetScreen!));
    }
  }

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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Text(
                    'ድለ',
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFEEEEEE)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC61B1B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // Modern search bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 18,
                      color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'ጸሎት፣ ታሪኽ፣ ትምህርቲ ድለ...',
                    hintStyle: TextStyle(
                      fontFamily: 'Nyala',
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Icon(Icons.search_rounded,
                          color: Colors.grey.shade400),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  color: Colors.grey.shade400),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildSearchBody(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBody(ThemeData theme) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC61B1B)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 38.0), // Strict 38.0
      physics: const BouncingScrollPhysics(),
      children: [
        if (_suggestedWord != null)
          GestureDetector(
            onTap: () {
              _searchController.text = _suggestedWord!;
              _performSearch(_suggestedWord!);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3))),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: Colors.orange, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Nyala',
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 16),
                          children: [
                            const TextSpan(text: "ምናልባት እዚ ደሊኹም ዲኹም? "),
                            TextSpan(
                                text: '$_suggestedWord',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 17)),
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ),
        _buildSearchResults(theme),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'ኣብ ምሉእ ኣፕሊኬሽን ድለ',
            style: TextStyle(
                fontFamily: 'Nyala', fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'ዝደለኻዮ ቃል ብምጽሓፍ ብቕልጡፍ ርኸብ',
            style: TextStyle(
                fontFamily: 'Nyala', fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            '"${_searchController.text}" ዝብል ጽሑፍ ኣይተረኸበን።',
            style: const TextStyle(
                fontFamily: 'Nyala', fontSize: 20, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final res = _results[index];
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
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _navigateToResult(res),
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
                        Icons.article_rounded,
                        size: 28,
                        color: Color(0xFFC61B1B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res.title,
                          style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 18.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          res.subtitle,
                          style: const TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 14,
                            color: Color(0xFFC61B1B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
    );
  }
}
