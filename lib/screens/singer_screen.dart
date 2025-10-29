// lib/screens/singer_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'album_songs_screen.dart';
import '../app_colors.dart';
import '../custom_page_route.dart';

class SingerScreen extends StatelessWidget {
  final String singer;
  final List<Map<String, dynamic>> albums;
  final String? imagePath;

  const SingerScreen({
    super.key,
    required this.singer,
    required this.albums,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = (imagePath != null && imagePath!.isNotEmpty);

    // <<< [ለውጢ] እቲ Scaffold ብሙሉኡ፡ ስእሊ ምህላውን ዘይምህላውን መሰረት ገይሩ ይቕየር >>>
    if (hasImage) {
      return _buildScreenWithImage(context);
    } else {
      return _buildScreenWithoutImage(context);
    }
  }

  // Helper Widget 1: ንስእሊ ዘለዎም ዘመርቲ
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
              expandedHeight: 300.0,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? theme.scaffoldBackgroundColor : refinedPastelGradient.colors.last,
              foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                background: Material(
                  type: MaterialType.transparency,
                  child: Hero(
                    tag: 'singer_image_$singer',
                    child: _buildBlurredHeader(),
                  ),
                ),
                stretchModes: const [StretchMode.zoomBackground],
              ),
              title: const Text(""), 
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: Text(
                  singer,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            albums.isEmpty
                ? SliverFillRemaining(child: Center(child: Text('ን $singer ዝተመዝገበ ኣልበም የለን።', style: theme.textTheme.bodyMedium)))
                : _buildAlbumsSliverList(),
          ],
        ),
      ),
    );
  }

  // Helper Widget 2: ንስእሊ ዘይብሎም ዘመርቲ
  Widget _buildScreenWithoutImage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(singer, style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? theme.colorScheme.surface : primaryAppBarColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark ? null : const BoxDecoration(gradient: refinedPastelGradient),
        child: albums.isEmpty
            ? Center(child: Text('ን $singer ዝተመዝገበ ኣልበም የለን።', style: theme.textTheme.bodyMedium))
            : _buildAlbumsListView(), // ListView ንምጥቃም
      ),
    );
  }

  // Helper for SliverList (for image version)
  Widget _buildAlbumsSliverList() {
    return AnimationLimiter(
      child: SliverPadding(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 24.0), 
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildAlbumCard(context, index),
            childCount: albums.length,
          ),
        ),
      ),
    );
  }
  
  // Helper for ListView (for no-image version)
  Widget _buildAlbumsListView() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 24.0),
        itemCount: albums.length,
        itemBuilder: (context, index) => _buildAlbumCard(context, index),
      ),
    );
  }

  // Common Card Builder to avoid code duplication
  Widget _buildAlbumCard(BuildContext context, int index) {
      final theme = Theme.of(context);
      final album = albums[index];
      final String albumTitle = album['albumTitle'] as String? ?? 'Untitled Album';
      final String? albumImagePath = album['albumImagePath'] as String?;
      final dynamic songsDynamic = album['songs'];
      final List<Map<String, dynamic>> songs = (songsDynamic is List)
          ? songsDynamic.whereType<Map<String, dynamic>>().toList()
          : [];

      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: _buildAlbumArt(context, albumImagePath),
                title: Text(
                  albumTitle,
                  style: GoogleFonts.notoSansEthiopic(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "${songs.length} መዝሙራት",
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    SlowCupertinoPageRoute(
                      builder: (context) => AlbumSongsScreen(
                        albumTitle: albumTitle,
                        singer: singer,
                        songs: songs,
                        albumImagePath: albumImagePath,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildBlurredHeader() {
    return ClipRRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath!,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          Image.asset(
            imagePath!,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, String? imagePath) {
    final theme = Theme.of(context);
    final fallbackIcon = Icon(
      Icons.album_rounded,
      color: theme.colorScheme.primary.withOpacity(0.7),
      size: 35,
    );

    return SizedBox(
      width: 60,
      height: 60,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: (imagePath != null && imagePath.isNotEmpty)
            ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: fallbackIcon,
                ),
              )
            : Container(
                color: theme.colorScheme.primary.withOpacity(0.1),
                child: fallbackIcon,
              ),
      ),
    );
  }
}