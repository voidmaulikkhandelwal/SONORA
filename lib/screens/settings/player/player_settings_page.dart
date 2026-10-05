import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../generated/l10n.dart';
import '../../../services/media_player.dart';
import '../../../services/settings_manager.dart';
import '../widgets/setting_item.dart';

class PlayerSettingsPage extends StatelessWidget {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GetIt.I<SettingsManager>();
    final player = GetIt.I<MediaPlayer>();

    return AnimatedBuilder(
      animation: Listenable.merge([settings, player]),
      builder: (context, _) {
        final isDataSaver = settings.streamingQuality == AudioQuality.low;
        final timer = player.timerDuration.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Player', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  const GroupTitle(title: 'Playback'),
                  SettingSwitchTile(
                    title: 'Data Saver',
                    subtitle: 'Use lower-bitrate audio to reduce network usage.',
                    leading: const Icon(Icons.data_saver_on_rounded),
                    value: isDataSaver,
                    onChanged: (value) {
                      settings.streamingQuality = value ? AudioQuality.low : AudioQuality.high;
                    },
                    isFirst: true,
                  ),
                  SettingTile(
                    title: 'Streaming quality',
                    subtitle: settings.streamingQuality == AudioQuality.high
                        ? 'High quality'
                        : 'Data saver / lower quality',
                    leading: const Icon(Icons.high_quality_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showQualityDialog(context, settings),
                    isLast: true,
                  ),
                  if (!Platform.isWindows) ...[
                    const GroupTitle(title: 'Automatic playback'),
                    SettingSwitchTile(
                      title: S.of(context).Skip_Silence,
                      subtitle: 'Automatically trim long silent sections.',
                      leading: const Icon(Icons.fast_forward_rounded),
                      value: settings.skipSilence,
                      onChanged: (value) async {
                        await player.skipSilence(value);
                      },
                      isFirst: true,
                      isLast: true,
                    ),
                  ],
                  const GroupTitle(title: 'Sleep timer'),
                  SettingTile(
                    title: timer == null ? 'Sleep timer' : 'Timer active',
                    subtitle: timer == null
                        ? 'Stop playback automatically after a chosen duration.'
                        : 'Playback will stop in ${_formatDuration(timer)}',
                    leading: const Icon(Icons.bedtime_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSleepTimer(context, player),
                    isFirst: true,
                    isLast: true,
                  ),
                  if (!Platform.isWindows) ...[
                    const GroupTitle(title: 'Audio effects'),
                    SettingSwitchTile(
                      title: 'Loudness enhancer',
                      subtitle: 'Boost perceived loudness while preserving headroom.',
                      leading: const Icon(Icons.volume_up_rounded),
                      value: settings.loudnessEnabled,
                      onChanged: (value) async {
                        await player.setLoudnessEnabled(value);
                      },
                      isFirst: true,
                    ),
                    SettingTile(
                      title: 'Equalizer',
                      subtitle: settings.equalizerEnabled ? 'Enabled' : 'Disabled',
                      leading: const Icon(Icons.equalizer_rounded),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/settings/player/equalizer'),
                      isLast: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showQualityDialog(BuildContext context, SettingsManager settings) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Streaming quality', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            RadioListTile<AudioQuality>(
              value: AudioQuality.high,
              groupValue: settings.streamingQuality,
              title: const Text('High quality'),
              subtitle: const Text('Best available audio quality.'),
              onChanged: (value) {
                settings.streamingQuality = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<AudioQuality>(
              value: AudioQuality.low,
              groupValue: settings.streamingQuality,
              title: const Text('Data saver'),
              subtitle: const Text('Lower bitrate for slower or limited connections.'),
              onChanged: (value) {
                settings.streamingQuality = value!;
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _showSleepTimer(BuildContext context, MediaPlayer player) async {
    final choices = <Duration>[
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(minutes: 60),
      const Duration(minutes: 90),
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: Text('Sleep timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            ...choices.map(
              (duration) => ListTile(
                leading: const Icon(Icons.schedule_rounded),
                title: Text('${duration.inMinutes} minutes'),
                onTap: () {
                  player.setTimer(duration);
                  Navigator.pop(context);
                },
              ),
            ),
            if (player.timerDuration.value != null)
              ListTile(
                leading: const Icon(Icons.timer_off_rounded),
                title: const Text('Cancel timer'),
                onTap: () {
                  player.cancelTimer();
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return minutes >= 60
        ? '${minutes ~/ 60}h ${minutes % 60}m'
        : seconds == 0
            ? '${minutes}m'
            : '${minutes}m ${seconds}s';
  }
}
