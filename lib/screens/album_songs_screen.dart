// lib/screens/album_songs_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'lyrics_screen.dart';
import '../app_colors.dart';
import '../custom_page_route.dart';

class AlbumSongsScreen extends StatelessWidget {
  final String albumTitle;
  final String singer;
  final List<Map<String, dynamic>> songs;
  final String? albumImagePath;

  const AlbumSongsScreen({
    super.key,
    required this.albumTitle,
    required this.singer,
    required this.songs,
    this.albumImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // <<< [ለውጢ] እዚ ሎጂክ ምስቲ ናይ SingerScreen ተመሳሳሊ ኮይኑ >>>
    final bool hasImage = (albumImagePath != null && albumImagePath!.isNotEmpty);

    if (hasImage) {
      return _buildScreenWithImage(context);
    } else {
      return _buildScreenWithoutImage(context);
    }
  }

  // Helper Widget 1: ንስእሊ ዘለዎም ኣልበማት
  Widget _buildScreenWithImage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? theme.scaffoldBackgroundColor : refinedPastelGradient.colors.last,
              foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  albumTitle,
                  style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [const Shadow(blurRadius: 2.0, color: Colors.black54)]
                  ),
                ),
                background: _buildBlurredHeader(),
                stretchModes: const [StretchMode.zoomBackground],
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: Text(
                  "${songs.length} መዝሙራት",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            songs.isEmpty
                ? SliverFillRemaining(child: Center(child: Text('ኣብዚ ኣልበም መዝሙር የለን።', style: theme.textTheme.bodyMedium)))
                : _buildSongsSliverList(),
          ],
        ),
      ),
    );
  }

  // Helper Widget 2: ንስእሊ ዘይብሎም ኣልበማት
  Widget _buildScreenWithoutImage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(albumTitle, style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: songs.isEmpty
            ? Center(child: Text('ኣብዚ ኣልበም መዝሙር የለን።', style: theme.textTheme.bodyMedium))
            : _buildSongsListView(),
      ),
    );
  }

  Widget _buildBlurredHeader() {
    return ClipRRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(albumImagePath!, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Image.asset(albumImagePath!, fit: BoxFit.contain),
        ],
      ),
    );
  }
  
  // Helpers for list building to avoid repetition
  Widget _buildSongsSliverList() {
    return AnimationLimiter(
      child: SliverPadding(
        padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 24.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSongCard(context, index),
            childCount: songs.length,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSongsListView() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 24.0),
        itemCount: songs.length,
        itemBuilder: (context, index) => _buildSongCard(context, index),
      ),
    );
  }

  Widget _buildSongCard(BuildContext context, int index) {
      final theme = Theme.of(context);
      final song = songs[index];
      final String songTitle = song['title'] as String? ?? 'Untitled Song';
      final hymnData = {
        'title': songTitle, 'singer': singer, 'lyrics': song['lyrics'] as String? ?? '',
        'albumTitle': albumTitle, 'category': song['category'] as String? ?? '',
        'timestamp': song['timestamp'] ?? DateTime.now(), 'albumImagePath': albumImagePath,
      };

      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
                title: Text(
                  songTitle,
                  style: GoogleFonts.notoSansEthiopic(fontSize: 17, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    SlowCupertinoPageRoute(builder: (context) => LyricsScreen(hymn: hymnData)),
                  );
                },
              ),
            ),
          ),
        ),
      );
  }
}