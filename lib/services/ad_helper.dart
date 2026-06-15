import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // 🌟 ናይ Android ሓቀኛ Banner Ad Unit ID (ካብ AdMob Dashboard ዘውጻእካዮ)
  static const String _androidRealBannerUnitId =
      'ca-app-pub-9762926620435579/8961611167';

  // 🌟 ናይ iOS ሓቀኛ Banner Ad Unit ID (ካብ AdMob Dashboard ምስ ረኸብካዮ ኣብዚ ኣእትዎ)
  static const String _iosRealBannerUnitId =
      'ca-app-pub-9762926620435579/INSERT_YOUR_REAL_IOS_UNIT_ID';

  // 🌟 ወግዓዊ ናይ Google መፈተኒ (Test) Banner Ad Unit IDs
  static const String _androidTestBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  static String get bannerAdUnitId {
    if (kDebugMode) {
      // 💻 ኣብ እዋን ልምዓት (Debug)፡ ከም ስልክኻ ባዕሉ መፈተኒ Ad ID ይመርፅ
      if (Platform.isAndroid) {
        return _androidTestBannerUnitId;
      } else if (Platform.isIOS) {
        return _iosTestBannerUnitId;
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } else {
      // 🚀 ኣብ እዋን ዝርጋሐ (Release)፡ ትኽክለኛ Ad ID ይመርፅ
      if (Platform.isAndroid) {
        return _androidRealBannerUnitId;
      } else if (Platform.isIOS) {
        return _iosRealBannerUnitId;
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    }
  }
}
