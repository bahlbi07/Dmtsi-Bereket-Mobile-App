import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color premiumRed = Color(0xFFC61B1B);
const Color premiumGold = Color(0xFFE8B15A);
const Color premiumInk = Color(0xFF1A1A1A);
const Color premiumParchment = Color(0xFFFFFCF8);
const Color premiumDarkSurface = Color(0xFF171313);

// ── Fullscreen overlay bar (placed inside a Stack, Positioned at top) ──
// Call _toggleFullscreen() to toggle; pass as onExit.
Positioned buildFullscreenOverlay({
  required BuildContext context,
  required String title,
  required VoidCallback onExit,
}) {
  return Positioned(
    top: MediaQuery.of(context).padding.top + 10,
    left: 14,
    right: 14,
    child: Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
              color: Colors.white,
              onPressed: () {
                onExit();
                Navigator.maybePop(context);
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nyala',
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.fullscreen_exit_rounded, size: 24),
              color: Colors.white,
              onPressed: onExit,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              tooltip: 'Exit fullscreen',
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildPremiumPageHeader(
  BuildContext context, {
  required String title,
  required bool isDark,
  bool showBackButton = true, // 🌟 እዚ መስመር እዚ ጥራይ ወስኸሉ
  List<Widget>? actions,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        // 🌟 ሓዱሽ ዝተወሰኸ፡ እቲ መመለሲ በተን ምስ 'showBackButton' ተኣሳሲሩ ጥራይ ንኽሰርሕ
        if (showBackButton && Navigator.canPop(context)) ...[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? premiumDarkSurface : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: premiumRed.withValues(alpha: isDark ? 0.18 : 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: premiumRed,
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.maybePop(context);
              },
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 26,
                  height: 1.05,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF2EEE9) : premiumInk,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [premiumRed, premiumGold],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: premiumGold.withValues(alpha: 0.90),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (actions != null) ...actions,
      ],
    ),
  );
}

Widget buildPremiumIconContainer({
  required bool isDark,
  required Widget child,
  double size = 52,
  double radius = 16,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF371717), const Color(0xFF21110F)]
            : [const Color(0xFFFFF4EC), const Color(0xFFFFE4E4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: premiumRed.withValues(alpha: isDark ? 0.18 : 0.10),
      ),
      boxShadow: [
        BoxShadow(
          color: premiumRed.withValues(alpha: isDark ? 0.18 : 0.10),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Center(child: child),
  );
}

Widget buildPremiumChevronButton() {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          premiumRed.withValues(alpha: 0.12),
          premiumGold.withValues(alpha: 0.12),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: premiumRed.withValues(alpha: 0.12)),
    ),
    child: const Center(
      child: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: premiumRed),
    ),
  );
}

BoxDecoration buildPremiumCardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? premiumDarkSurface : premiumParchment,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : premiumRed.withValues(alpha: 0.06),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.08),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: premiumRed.withValues(alpha: isDark ? 0.06 : 0.035),
        blurRadius: 18,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
