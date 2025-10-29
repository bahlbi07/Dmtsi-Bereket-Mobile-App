// lib/animation/custom_page_route.dart

import 'package:flutter/cupertino.dart';

/// ብ CupertinoPageRoute ተመሳሲሉ፡ ግና ቀስ ዝበለ ናይ ምቅይያር ስምዒት (transition) ዘለዎ ሩት።
/// እዚ ንተጠቃሚ ንፁርን ዘይሃንደበታውን ናይ ገፅ ለውጢ ይህቦ።
class SlowCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  SlowCupertinoPageRoute({
    required super.builder,
    super.title,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 800);
}