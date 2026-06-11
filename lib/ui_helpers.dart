// lib/ui_helpers.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ንኹሎም ገጻት ዘገልግል ማእኸላይ ናይ ፎንት ዓቐን መቆጻጸሪ (Global Font Controller)
class FontSizeController {
  // እቲ ንቡር መበገሲ ዓቐን (1.0) እዩ። ካብ 0.8 ክሳብ 1.4 ክኸውን ይኽእል።
  static final ValueNotifier<double> multiplier = ValueNotifier<double>(1.0);

  static void increase() {
    if (multiplier.value < 1.4) {
      multiplier.value =
          double.parse((multiplier.value + 0.1).toStringAsFixed(1));
    }
  }

  static void decrease() {
    if (multiplier.value > 0.8) {
      multiplier.value =
          double.parse((multiplier.value - 0.1).toStringAsFixed(1));
    }
  }
}

Widget buildSectionTitle(BuildContext context, String title) {
  final textColor =
      CupertinoDynamicColor.resolve(CupertinoColors.label, context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
    child: Text(
      title,
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
    ),
  );
}

Widget buildSubSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, bottom: 6.0, top: 12.0),
    child: Text(
      title,
      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 18,
            decoration: TextDecoration.none,
          ),
    ),
  );
}

Widget buildParagraph(BuildContext context, String text) {
  final textColor =
      CupertinoDynamicColor.resolve(CupertinoColors.label, context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(
      text,
      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            height: 1.6,
            fontSize: 17,
            color: textColor,
            decoration: TextDecoration.none,
          ),
      textAlign: TextAlign.justify,
    ),
  );
}

Widget buildListItem(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.none,
              ),
        ),
        Expanded(
          child: Text(
            text,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  height: 1.6,
                  fontSize: 17,
                  decoration: TextDecoration.none,
                ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    ),
  );
}

Widget buildImageWithCaption({
  required String imagePath,
  String? caption,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final imageHeight = (screenWidth * 0.7).clamp(150.0, 400.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: screenWidth * 0.85,
            height: imageHeight,
            errorBuilder: (ctx, error, stackTrace) {
              return Container(
                height: imageHeight,
                color: Colors.grey[300],
                child: Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.grey[600], size: 40)),
              );
            },
          ),
        ),
      ),
      if (caption != null && caption.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(
              top: 0.0, bottom: 8.0, left: 4.0, right: 4.0),
          child: Text(
            caption,
            style:
                CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );
}

Widget buildSpacer() => const SizedBox(height: 16.0);

// =======================================================================
// SHARED UI COMPONENTS — used by all list screens
// =======================================================================

/// ዘመናዊ \u12e8\u130d\u1302 \u1204\u12f0\u122d \u12cd\u12b5\u1275 (\u12e8\u1290\u12d3 \u1302\u12ac\u1275 \u12e8\u1203\u120d\u12a9\u12f0\u1275)
Widget buildPageHeader(
  BuildContext context, {
  required String title,
  required bool isDark,
  List<Widget>? actions,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Back button — circular with red accent rim
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.maybePop(context);
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2A1515), const Color(0xFF1E1E1E)]
                        : [Colors.white, const Color(0xFFFFF5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFFC61B1B).withValues(alpha: 0.22),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC61B1B)
                          .withValues(alpha: isDark ? 0.18 : 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFFC61B1B),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFEEEEEE)
                      : const Color(0xFF1A1A1A),
                  height: 1.1,
                ),
              ),
            ),
            if (actions != null) ...actions,
          ],
        ),
        const SizedBox(height: 10),
        // Gradient accent underline
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFC61B1B),
                  const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                  const Color(0xFFC61B1B).withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    ),
  );
}

/// \u12e8\u1270\u12e8\u1290 Icon container \u12a0\u12dc\u1218\u12f3\u12ed (gradient background)
Widget buildIconContainer({
  required bool isDark,
  required Widget child,
  double size = 50,
  double radius = 15,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF2E1818), const Color(0xFF3A1F1F)]
            : [const Color(0xFFFFF3F3), const Color(0xFFFFE6E6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: const Color(0xFFC61B1B).withValues(alpha: isDark ? 0.2 : 0.13),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color:
              const Color(0xFFC61B1B).withValues(alpha: isDark ? 0.12 : 0.07),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Center(child: child),
  );
}

/// \u12e8\u1270\u12e8\u1290 chevron \u1265\u1271\u1295 (\u1296\u1228\u12f5 \u12ab\u122d\u12f5 \u12eb\u1208\u12cd)
Widget buildChevronButton() {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE52828), Color(0xFF9E0B0F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(11),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFC61B1B).withValues(alpha: 0.30),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const Center(
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: Colors.white,
      ),
    ),
  );
}

/// \u12e8\u1270\u12e8\u1290 premium list card \u12a0\u12dc\u1218\u12f3\u12ed
BoxDecoration buildCardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.06),
        blurRadius: 18,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: const Color(0xFFC61B1B).withValues(alpha: isDark ? 0.05 : 0.03),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
