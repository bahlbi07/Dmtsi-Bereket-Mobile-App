// lib/favorites_manager.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dmtsibereket/data/saints_history_data.dart';
import 'package:dmtsibereket/data/church_history_data.dart';
import 'package:dmtsibereket/data/bible_tradition_data.dart';
import 'package:dmtsibereket/data/social_teaching_data.dart';
import 'package:dmtsibereket/data/spiritual_life_data.dart';
// === [ለውጢ] ን Doctrine ዝኸውን ዳታ ተወሲኹ ===
import 'package:dmtsibereket/data/doctrine_data.dart';

enum FavoriteType {
  hymn,
  prayer,
  quote,
  saintsHistory,
  churchHistory,
  doctrine,
  bibleTradition,
  socialTeaching,
  spiritualLife
}

class FavoriteItem {
  final String id;
  final FavoriteType type;
  final Map<String, dynamic> content;
  final DateTime dateAdded;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.content,
    required this.dateAdded,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      type: FavoriteType.values[json['type']],
      content: Map<String, dynamic>.from(json['content']),
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }
}

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  static const _favoritesKey = 'favorites_list_v2';
  static const _permissionKey = 'favorites_permission_granted';

  final ValueNotifier<List<FavoriteItem>> _favoritesNotifier = ValueNotifier([]);
  ValueNotifier<List<FavoriteItem>> get favoritesNotifier => _favoritesNotifier;

  Future<void> init() async {
    await _loadFavorites();
  }

  Future<bool> checkAndShowPermissionDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool? hasPermission = prefs.getBool(_permissionKey);

    if (hasPermission == true) {
      return true;
    }

    if (!context.mounted) return false;

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ፍቓድ መኽዘን', style: GoogleFonts.notoSerifEthiopic()),
          content: Text(
            "'ንዋየ-ልበይ' (Favorites) ዝበሃል ተግባር ንምጥቃም፡ እቲ እትፈትውዎ ትሕዝቶ ኣብዚ ስልኪ'ዚ ክንዕቅብ ፍቓድኩም ሃቡና። እዚ ምንም ዓይነት ውልቃዊ ሓበሬታ ኣይእክብን እዩ።",
            style: GoogleFonts.notoSerifEthiopic(height: 1.6),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ኣይፈቅድን'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('እፈቅድ እየ'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await prefs.setBool(_permissionKey, true);
      return true;
    }
    return false;
  }

  List<FavoriteItem> getFavorites(FavoriteType type) {
    final allItems = _favoritesNotifier.value;
    return allItems.where((item) => item.type == type).toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  bool isFavorite(String id) {
    return _favoritesNotifier.value.any((item) => item.id == id);
  }

  Future<void> toggleFavorite(FavoriteItem item) async {
    final currentFavorites = List<FavoriteItem>.from(_favoritesNotifier.value);
    if (isFavorite(item.id)) {
      currentFavorites.removeWhere((fav) => fav.id == item.id);
    } else {
      currentFavorites.add(item);
    }
    _favoritesNotifier.value = currentFavorites;
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = _favoritesNotifier.value
        .map((item) => json.encode(item.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesJson = prefs.getStringList(_favoritesKey);
    if (favoritesJson != null) {
      _favoritesNotifier.value = favoritesJson
          .map((item) {
              try {
                return FavoriteItem.fromJson(json.decode(item));
              } catch (e) {
                // Return a dummy/null item or handle the error gracefully
                debugPrint("Error decoding favorite item: $e");
                return null;
              }
            })
          .where((item) => item != null) // Filter out any nulls from decoding errors
          .cast<FavoriteItem>()
          .toList();
    }
  }

  static List<String>? getSaintHeadings(String saintName) {
    final content = saintsHistoryContent[saintName];
    if (content == null) {
      return null;
    }
    final headings = content
        .where((b) => b['type'] == 'heading')
        .map((b) => b['text'] as String)
        .toList();

    return headings.isNotEmpty ? headings : [saintName];
  }

  // === [ለውጢ] ንኹሉ Categories ዝምልስ ሓጋዚ function ===
  static List<Map<String, dynamic>> getTopicsForCategory(FavoriteType type) {
    switch (type) {
      case FavoriteType.churchHistory:
        return [...churchHistoryPartOne, ...churchHistoryPartTwo].map((c) {
          return {'title': c['title']!, 'content': [{'type': 'paragraph', 'text': c['content']!}]};
        }).toList();
      case FavoriteType.bibleTradition:
        return bibleTraditionTopics;
      case FavoriteType.socialTeaching:
        return socialTeachingTopics;
      case FavoriteType.spiritualLife:
        return spiritualLifeTopics;
      case FavoriteType.doctrine:
        // Doctrine has a nested structure, so we flatten it for this helper
        List<Map<String, dynamic>> allSubTopics = [];
        doctrineDetailsContent.forEach((key, value) {
          allSubTopics.addAll(value);
        });
        return allSubTopics;
      default:
        return [];
    }
  }
}