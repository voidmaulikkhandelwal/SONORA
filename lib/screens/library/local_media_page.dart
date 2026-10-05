import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/local_media_service.dart';
import '../../services/media_player.dart';

class LocalMediaPage extends StatefulWidget {
  const LocalMediaPage({super.key});

  @override
  State<LocalMediaPage> createState() => _LocalMediaPageState();
}

class _LocalMediaPageState extends State<LocalMediaPage> {
  final _service = GetIt.I<LocalMediaService>();

  Future<void> _import() async {
    final count = await _service.importFiles();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(count == 0
            ? 'No audio files were added.'
            : '$count audio file${count == 1 ? '' : 's'} added to your library.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _remove(Map<String, dynamic> track) async {
    final path = track['localPath']?.toString();
    if (path == null) return;
    await _service.remove(path);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tracks = _service.tracks;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Local music', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('Music stored on this PC', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              await _service.clearMissingFiles();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          FilledButton.icon(
            onPressed: _import,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add music'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: tracks.isEmpty
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.library_music_rounded, size: 54, color: scheme.primary),
                        const SizedBox(height: 18),
                        const Text(
                          'Bring your own music',
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add MP3, M4A, WAV, FLAC, AAC, OGG, OPUS or WMA files. They stay on your PC and appear in SONORA alongside streamed music.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65), height: 1.45),
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: _import,
                          icon: const Icon(Icons.folder_open_rounded),
                          label: const Text('Choose music files'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
              itemCount: tracks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final track = tracks[index];
                final filePath = track['localPath']?.toString() ?? '';
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: scheme.primary.withValues(alpha: 0.10),
                    ),
                    child: Icon(Icons.music_note_rounded, color: scheme.primary),
                  ),
                  title: Text(track['title']?.toString() ?? 'Local track', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    filePath.isEmpty ? 'Local file' : '${track['artist'] ?? 'Local music'}  •  ${File(filePath).uri.pathSegments.last}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Add to queue',
                        onPressed: () => GetIt.I<MediaPlayer>().addToQueue(Map<String, dynamic>.from(track)),
                        icon: const Icon(Icons.queue_music_rounded),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: () => _remove(track),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                  onTap: () => GetIt.I<MediaPlayer>().playSong(Map<String, dynamic>.from(track)),
                );
              },
            ),
    );
  }
}
