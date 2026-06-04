import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AnalyticsService {
  static const String scriptUrl =
      "https://script.google.com/macros/s/AKfycbyHykLbcEVjEKdw9sWm_0-743Wtdp4ag-bQ68aKPhOkivl-zQLV0xT2I5A0UYwK958/exec";

  static String? _userId;
  static String? _userCountry;
  static bool _isSending = false;
  static StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('meadi_tsega_user_id');
    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString('meadi_tsega_user_id', _userId!);
    }

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        trySendAnalyticsBatch();
      }
    });
  }

  static Future<String> _getCountryByIp() async {
    if (_userCountry != null) return _userCountry!;

    final prefs = await SharedPreferences.getInstance();
    _userCountry = prefs.getString('meadi_tsega_country');
    if (_userCountry != null) return _userCountry!;

    try {
      final response = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userCountry = data['country'] ?? "Unknown";
        await prefs.setString('meadi_tsega_country', _userCountry!);
        return _userCountry!;
      }
    } catch (_) {}
    return "Unknown";
  }

  static Future<void> track(
      String eventName, Map<String, dynamic> parameters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> events = prefs.getStringList('meadi_tsega_events') ?? [];

      final eventMap = {
        'eventId': const Uuid().v4(),
        'event': eventName,
        'params': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      };

      events.add(jsonEncode(eventMap));
      await prefs.setStringList('meadi_tsega_events', events);
      trySendAnalyticsBatch();
    } catch (_) {}
  }

  static Future<void> trySendAnalyticsBatch() async {
    if (_isSending) return;

    try {
      if (_userId == null) await init();

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) return;

      final prefs = await SharedPreferences.getInstance();
      List<String> rawEvents = prefs.getStringList('meadi_tsega_events') ?? [];
      if (rawEvents.isEmpty) return;

      _isSending = true;

      List<Map<String, dynamic>> batchToSend =
          rawEvents.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      List<String> batchIds =
          batchToSend.map((e) => e['eventId'].toString()).toList();

      String country = await _getCountryByIp();

      final payloadMap = {
        'userId': _userId,
        'country': country,
        'events': batchToSend,
      };

      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payloadMap),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        List<String> freshRawEvents =
            prefs.getStringList('meadi_tsega_events') ?? [];
        List<String> remainingEvents = freshRawEvents.where((e) {
          final decoded = jsonDecode(e) as Map<String, dynamic>;
          return !batchIds.contains(decoded['eventId'].toString());
        }).toList();

        await prefs.setStringList('meadi_tsega_events', remainingEvents);

        if (kDebugMode) {
          debugPrint("Analytics successfully sent instantly!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Analytics Send Error: $e");
      }
    } finally {
      _isSending = false;
    }
  }

  static void dispose() {
    _connectivitySubscription?.cancel();
  }
}
