// lib/models/prayer_models.dart

import 'package:flutter/material.dart';

// Model for a single piece of prayer content (e.g., one mystery of the rosary)
class PrayerContent {
  final String title;
  final String body;
  final String? imagePath;
  final String? prompt;

  PrayerContent({
    required this.title,
    required this.body,
    this.imagePath,
    this.prompt,
  });

  factory PrayerContent.fromMap(Map<String, dynamic> map) {
    final content = map['content'] as Map<String, dynamic>;
    return PrayerContent(
      title: content['title'] as String,
      body: content['body'] as String,
      imagePath: map['imagePath'] as String?,
      prompt: content['prompt'] as String?,
    );
  }

  // For saving/loading from JSON (used in favorites)
  factory PrayerContent.fromJson(Map<String, dynamic> json) {
    return PrayerContent(
      title: json['title'],
      body: json['body'],
      imagePath: json['imagePath'],
      prompt: json['prompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'imagePath': imagePath,
      'prompt': prompt,
    };
  }
}

// Model for a single prayer item in a list (e.g., "Joyful Mysteries")
class PrayerItem {
  final String id;
  final String title;
  final IconData icon;
  final String? subtitle;
  final bool isTabbed; // Does it open a view with tabs or a single page?
  final dynamic content; // Can be PrayerContent or List<PrayerContent>

  PrayerItem({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    required this.isTabbed,
    required this.content,
  });

  // For saving/loading from JSON (used in favorites)
  factory PrayerItem.fromJson(Map<String, dynamic> json) {
    dynamic contentData;
    if (json['isTabbed']) {
      contentData = (json['content'] as List)
          .map((c) => PrayerContent.fromJson(c as Map<String, dynamic>))
          .toList();
    } else {
      contentData = PrayerContent.fromJson(json['content'] as Map<String, dynamic>);
    }

    return PrayerItem(
      id: json['id'],
      title: json['title'],
      icon: IconData(json['icon_code'], fontFamily: 'MaterialIcons'),
      subtitle: json['subtitle'],
      isTabbed: json['isTabbed'],
      content: contentData,
    );
  }

  Map<String, dynamic> toJson() {
    dynamic contentJson;
    if (isTabbed) {
      contentJson = (content as List<PrayerContent>).map((c) => c.toJson()).toList();
    } else {
      contentJson = (content as PrayerContent).toJson();
    }

    return {
      'id': id,
      'title': title,
      'icon_code': icon.codePoint,
      'subtitle': subtitle,
      'isTabbed': isTabbed,
      'content': contentJson,
    };
  }
}