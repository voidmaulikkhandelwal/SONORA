import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:sonora/core/widgets/liquid_glass.dart';
import 'package:sonora/services/media_player.dart';
import 'package:sonora/utils/song_thumbnail.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  Color? _accent;

  Future<void> _updateAccent(ImageProvider image) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        image,
        maximumColorCount: 20,
      );
      if (!mounted || palette.dominantColor == null) return;
      setState(() => _accent = palette.dominantColor!.color);
    } catch (_) {
      // Artwork extraction is purely cosmetic; playback must not depend on it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = GetIt.I<MediaPlayer>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder(
      stream: player.currentTrackStream,
      builder: (context, snapshot) {
        final song = snapshot.data?.currentItem;
        if (song == null) return const SizedBox.shrink();

        final art = song.extras;
        final accent = _accent ?? scheme.primary;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(232, 0, 14, 10),
            child: Material(
              color: Colors.transparent,
              child: LiquidGlass(
                height: 76,
                borderRadius: BorderRadius.circular(24),
                blur: 32,
                surfaceOpacity: 0.40,
                tint: accent.withValues(alpha: 1).computeLuminance() > 0.6
                    ? scheme.surface
                    : Color.alphaBlend(accent.withValues(alpha: 0.22), scheme.surface),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: ValueListenableBuilder<ProgressBarState>(
                        valueListenable: player.progressBarState,
                        builder: (context, state, _) {
                          final total = state.total.inMilliseconds;
                          final current = state.current.inMilliseconds;
                          final progress = total <= 0
                              ? 0.0
                              : (current / total).clamp(0.0, 1.0);
                          return Align(
                            alignment: Alignment.topLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.push('/player'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (art != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SongThumbnail(
                                        song: art,
                                        height: 54,
                                        width: 54,
                                        fit: BoxFit.cover,
                                        onImageReady: _updateAccent,
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 54,
                                      width: 54,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: scheme.surfaceContainerHigh,
                                      ),
                                      child: const Icon(Icons.music_note_rounded),
                                    ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 250,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          song.artist ?? art?['subtitle'] ?? 'Unknown artist',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: scheme.onSurface.withValues(alpha: 0.62),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          ValueListenableBuilder<ButtonState>(
                            valueListenable: player.buttonState,
                            builder: (context, state, _) {
                              return _CircleControl(
                                tooltip: 'Previous',
                                icon: Icons.skip_previous_rounded,
                                onPressed: player.player.seekToPrevious,
                              );
                            },
                          ),
                          const SizedBox(width: 2),
                          ValueListenableBuilder<ButtonState>(
                            valueListenable: player.buttonState,
                            builder: (context, state, _) {
                              if (state == ButtonState.loading) {
                                return const SizedBox(
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                    child: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                );
                              }
                              final playing = state == ButtonState.playing;
                              return _PrimaryControl(
                                tooltip: playing ? 'Pause' : 'Play',
                                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                onPressed: playing ? player.player.pause : player.player.play,
                              );
                            },
                          ),
                          const SizedBox(width: 2),
                          _CircleControl(
                            tooltip: 'Next',
                            icon: Icons.skip_next_rounded,
                            onPressed: player.player.seekToNext,
                          ),
                          const SizedBox(width: 10),
                          AnimatedBuilder(
                            animation: player,
                            builder: (context, _) => _CircleControl(
                              tooltip: 'Shuffle',
                              icon: Icons.shuffle_rounded,
                              active: player.shuffleModeEnabled,
                              onPressed: () async {
                                await player.setShuffleEnabled(!player.shuffleModeEnabled);
                              },
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: player.loopMode,
                            builder: (context, mode, _) => _CircleControl(
                              tooltip: mode.name == 'one' ? 'Repeat one' : 'Repeat',
                              icon: mode.name == 'one' ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                              active: mode.name != 'off',
                              onPressed: player.changeLoopMode,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Open player',
                            onPressed: () => context.push('/player'),
                            icon: const Icon(Icons.open_in_full_rounded, size: 19),
                          ),
                          IconButton(
                            tooltip: 'More options',
                            onPressed: art == null ? null : () => showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              builder: (_) => _MoreSheet(song: art),
                            ),
                            icon: const Icon(Icons.more_horiz_rounded, size: 21),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ValueListenableBuilder<ProgressBarState>(
                        valueListenable: player.progressBarState,
                        builder: (context, state, _) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (details) {
                              final renderBox = context.findRenderObject() as RenderBox;
                              final x = details.localPosition.dx.clamp(0.0, renderBox.size.width);
                              final ratio = renderBox.size.width == 0 ? 0 : x / renderBox.size.width;
                              final position = state.total * ratio;
                              player.player.seek(position);
                            },
                            child: const SizedBox(height: 4),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 21,
        color: active ? scheme.primary : scheme.onSurface.withValues(alpha: 0.78),
      ),
    );
  }
}

class _PrimaryControl extends StatelessWidget {
  const _PrimaryControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        fixedSize: const Size(46, 46),
      ),
      icon: Icon(icon, size: 25),
    );
  }
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.song});
  final Map song;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Wrap(
          runSpacing: 4,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded),
              title: const Text('Add to favorites'),
              onTap: () async {
                final box = Hive.box('FAVOURITES');
                final id = song['videoId'];
                if (id != null && box.get(id) == null) {
                  await box.put(id, {...song, 'createdAt': DateTime.now().millisecondsSinceEpoch});
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Manage downloads'),
              onTap: () {
                Navigator.pop(context);
                context.push('/saved/downloads_page');
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music_rounded),
              title: const Text('Open queue & player'),
              onTap: () {
                Navigator.pop(context);
                context.push('/player');
              },
            ),
          ],
        ),
      ),
    );
  }
}
