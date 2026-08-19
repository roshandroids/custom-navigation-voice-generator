import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';

/// Audio player controls.
///
/// When the [AudioAsset] carries a payload ([AudioAsset.bytes] or
/// [AudioAsset.uri]) it plays the audio for real via `audioplayers`; when it
/// is metadata-only (mock assets) it falls back to simulated play/stop state.
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

  /// Only created when the asset actually carries audio.
  audio.AudioPlayer? _engine;

  bool get _canPlayReal => widget.audio.bytes != null || widget.audio.uri != null;

  Future<void> _togglePlayback() async {
    if (!_canPlayReal) {
      setState(() => _playing = !_playing);
      if (_playing) {
        widget.onPlay();
      } else {
        widget.onStop();
      }
      return;
    }

    if (_playing) {
      await _stop();
    } else {
      await _play();
    }
  }

  Future<void> _play() async {
    final engine = _engine ??= audio.AudioPlayer();
    if (!_playing) {
      _playing = true;
      widget.onPlay();
      setState(() {});
      engine.onPlayerComplete.listen((_) => _handleComplete());
    }

    final asset = widget.audio;
    if (asset.bytes != null) {
      await engine.play(audio.BytesSource(asset.bytes!));
    } else if (asset.uri != null) {
      await engine.play(audio.UrlSource(asset.uri!.toString()));
    }
  }

  Future<void> _stop() async {
    _playing = false;
    widget.onStop();
    setState(() {});
    await _engine?.stop();
  }

  void _handleComplete() {
    if (!mounted) return;
    _playing = false;
    setState(() {});
  }

  @override
  Future<void> dispose() async {
    await _engine?.dispose();
    super.dispose();
  }

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
            onPressed: () => _togglePlayback(),
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