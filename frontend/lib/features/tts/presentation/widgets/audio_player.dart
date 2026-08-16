import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';

/// Simulated audio player controls.
///
/// The MVP has no real audio playback — the player exposes play/stop state
/// and the audio duration, and the recording workflow's playback simulation
/// drives the actual phase transitions.
class AudioPlayer extends StatefulWidget {
  const AudioPlayer({
    super.key,
    required this.audio,
    required this.onPlay,
    required this.onStop,
  });

  final AudioAsset audio;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = widget.audio.duration.inSeconds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: () {
              setState(() => _playing = !_playing);
              if (_playing) {
                widget.onPlay();
              } else {
                widget.onStop();
              }
            },
            icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
            tooltip: _playing ? 'Stop preview' : 'Preview audio',
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _playing ? 'Playing…' : 'Preview',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${widget.audio.kind.label} · ${seconds}s · ${widget.audio.format.label}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
