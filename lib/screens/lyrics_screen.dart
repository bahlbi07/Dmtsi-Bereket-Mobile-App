// lib/screens/lyrics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../favorites_manager.dart';

class LyricsScreen extends StatefulWidget {
  final Map<String, dynamic> hymn;
  const LyricsScreen({super.key, required this.hymn});
  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  // =======================================================
  // All your state variables and logic are kept unchanged.
  // =======================================================
  double _currentScale = 1.0;
  late TransformationController _transformationController;
  final double _minScale = 0.8;
  final double _maxScale = 4.0;
  bool _showControls = true;
  bool _isLockedToLandscape = false;
  bool _isLockedToPortrait = false;

  final FavoritesManager _favoritesManager = FavoritesManager();
  late bool _isFavorite;
  late String _favoriteId;

  // --- initState, dispose, and other methods remain the same ---
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController(Matrix4.identity()..scale(_currentScale));
    _transformationController.addListener(_onControllerChange);
    _setOrientation(allowBoth: true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _favoriteId = "${widget.hymn['title']}_${widget.hymn['singer']}";
    _isFavorite = _favoritesManager.isFavorite(_favoriteId);
    _favoritesManager.favoritesNotifier.addListener(_updateFavoriteStatus);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _transformationController.removeListener(_onControllerChange);
    _transformationController.dispose();
    _favoritesManager.favoritesNotifier.removeListener(_updateFavoriteStatus);
    super.dispose();
  }

  void _updateFavoriteStatus() {
    if (mounted) {
      final newStatus = _favoritesManager.isFavorite(_favoriteId);
      if (newStatus != _isFavorite) {
        setState(() => _isFavorite = newStatus);
      }
    }
  }

  void _toggleFavorite() async {
    HapticFeedback.lightImpact();
    bool hasPermission = await _favoritesManager.checkAndShowPermissionDialog(context);
    if (!hasPermission) return;
    
    final item = FavoriteItem(
      id: _favoriteId,
      type: FavoriteType.hymn,
      content: widget.hymn,
      dateAdded: DateTime.now(),
    );
    await _favoritesManager.toggleFavorite(item);
  }

  void _onControllerChange() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      if (mounted) setState(() => _currentScale = scale.clamp(_minScale, _maxScale));
    }
  }

  void _updateScaleFromSlider(double value) {
    if (mounted) {
      setState(() => _currentScale = value);
      final currentMatrix = _transformationController.value;
      final currentTranslation = currentMatrix.getTranslation();
      _transformationController.value = Matrix4.identity()
        ..translate(currentTranslation.x, currentTranslation.y)
        ..scale(value);
    }
  }

  void _setOrientation({bool portraitOnly = false, bool landscapeOnly = false, bool allowBoth = false}) {
    List<DeviceOrientation> orientations;
    if (portraitOnly) {
      orientations = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
    } else if (landscapeOnly) {
      orientations = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
    } else {
      orientations = [
        DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight,
      ];
    }
    SystemChrome.setPreferredOrientations(orientations);
  }

  void _toggleOrientationLock() {
    HapticFeedback.lightImpact();
    final currentOrientation = MediaQuery.of(context).orientation;
    bool nextPortraitLock = false, nextLandscapeLock = false, nextAllowBoth = false;
    if (_isLockedToPortrait) {
      nextLandscapeLock = true;
    } else if (_isLockedToLandscape) {
      nextAllowBoth = true;
    } else {
      nextPortraitLock = true;
    }
    setState(() {
      _isLockedToPortrait = nextPortraitLock;
      _isLockedToLandscape = nextLandscapeLock;
    });
    if (nextPortraitLock) {
      _setOrientation(portraitOnly: true);
      if (currentOrientation == Orientation.landscape) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        Future.delayed(const Duration(milliseconds: 100), () { if (mounted) _setOrientation(portraitOnly: true); });
      }
    } else if (nextLandscapeLock) {
      _setOrientation(landscapeOnly: true);
      if (currentOrientation == Orientation.portrait) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
        Future.delayed(const Duration(milliseconds: 100), () { if (mounted) _setOrientation(landscapeOnly: true); });
      }
    } else {
      _setOrientation(allowBoth: true);
    }
  }

  IconData _getLockIcon() {
    if (_isLockedToPortrait) return Icons.screen_lock_portrait_rounded;
    if (_isLockedToLandscape) return Icons.screen_lock_landscape_rounded;
    return Icons.screen_rotation_rounded;
  }

  String _getLockTooltip() {
    if (_isLockedToPortrait) return 'Unlock Orientation';
    if (_isLockedToLandscape) return 'Allow All Orientations';
    return 'Lock to Portrait';
  }

  void _toggleControlsVisibility() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
        SystemChrome.setEnabledSystemUIMode(_showControls ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky);
      });
    }
  }

  void _copyLyricsToClipboard() {
    HapticFeedback.lightImpact();
    final lyrics = widget.hymn['lyrics'] as String? ?? 'No lyrics available.';
    Clipboard.setData(ClipboardData(text: lyrics));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('ግጥሚ ተቐዲሑ ኣሎ'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final title = widget.hymn['title'] as String? ?? 'Lyrics';
    final lyrics = widget.hymn['lyrics'] as String? ?? 'No lyrics available.';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lyricsBackgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFDF6);

    return Scaffold(
      backgroundColor: lyricsBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: AppBar(
            backgroundColor: isDark ? theme.colorScheme.surface.withOpacity(0.85) : primaryAppBarColor,
            foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
            elevation: 1.0,
            title: Text(
              title,
              style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFavorite ? Colors.red.shade400 : (isDark ? null : Colors.white),
                ),
                tooltip: _isFavorite ? 'ካብ ንዋየ-ልበይ ኣውፅእ' : 'ናብ ንዋየ-ልበይ ኣእትው',
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: Icon(_getLockIcon()),
                tooltip: _getLockTooltip(),
                onPressed: _toggleOrientationLock
              ),
              IconButton(
                icon: const Icon(Icons.copy_all_rounded),
                tooltip: 'Copy Lyrics',
                onPressed: _copyLyricsToClipboard,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleControlsVisibility,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(30.0),
                  minScale: _minScale,
                  maxScale: _maxScale,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      // ================== BEGIN CHANGE ==================
                      child: SelectableText(
                        lyrics,
                        style: GoogleFonts.notoSerifEthiopic(
                          fontSize: 19,
                          height: 1.7, // <<< ተዓሪሙ: ካብ 1.8 ናብ 1.7
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.start, // <<< ተዓሪሙ: ካብ Center ናብ Start
                      ),
                      // =================== END CHANGE ===================
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              transform: Matrix4.translationValues(0, _showControls ? 0 : 100, 0),
              child: _buildControlBar(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900.withOpacity(0.9) : primaryAppBarColor.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.text_fields_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: _currentScale,
              min: _minScale,
              max: _maxScale,
              divisions: ((_maxScale - _minScale) / 0.1).round(),
              label: "x${_currentScale.toStringAsFixed(1)}",
              onChanged: _updateScaleFromSlider,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.4),
              thumbColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.text_fields_rounded, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}