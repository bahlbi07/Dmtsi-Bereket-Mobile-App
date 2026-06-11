import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meadi_tsga/data/saints_history_data.dart';
import 'package:meadi_tsga/data/church_history_data.dart';
import 'package:meadi_tsga/data/spiritual_life_data.dart';
import 'package:meadi_tsga/data/doctrine_data.dart';

// <<< መዛሙር፣ መጽሓፍ ቅዱስን ማሕበራዊ ትምህርትን ካብዚ ጠፊኦም ኣለዉ >>>
enum FavoriteType {
  prayer,
  quote,
  saintsHistory,
  churchHistory,
  doctrine,
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

  final ValueNotifier<List<FavoriteItem>> _favoritesNotifier =
      ValueNotifier([]);
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
          title: const Text('ፍቓድ መኽዘን',
              style:
                  TextStyle(fontFamily: 'Nyala', fontWeight: FontWeight.bold)),
          content: const Text(
            "'ዝፈተኽዎም' (Favorites) ዝበሃል ተግባር ንምጥቃም፡ እቲ እትፈትውዎ ትሕዝቶ ኣብዚ ስልኪ'ዚ ክንዕቀብ ፍቃድ ሃቡና።",
            style: TextStyle(fontFamily: 'Nyala', fontSize: 18, height: 1.6),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ኣይፈቅድን',
                  style: TextStyle(fontFamily: 'Nyala', fontSize: 18)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('እፈቅድ እየ',
                  style: TextStyle(fontFamily: 'Nyala', fontSize: 18)),
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
              return null;
            }
          })
          .where((item) => item != null)
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

  static List<Map<String, dynamic>> getTopicsForCategory(FavoriteType type) {
    switch (type) {
      case FavoriteType.churchHistory:
        return [...churchHistoryPartOne, ...churchHistoryPartTwo].map((c) {
          return {
            'title': c['title']!,
            'content': [
              {'type': 'paragraph', 'text': c['content']!}
            ]
          };
        }).toList();
      case FavoriteType.spiritualLife:
        return spiritualLifeTopics;
      case FavoriteType.doctrine:
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
