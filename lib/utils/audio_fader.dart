import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioFaderComponent extends Component {
  final AudioPlayer player;
  final double targetVolume;
  final double duration;
  final VoidCallback? onComplete;

  late double _startVolume;
  late double _elapsed;

  AudioFaderComponent({required this.player, required this.targetVolume, required this.duration, this.onComplete});

  @override
  Future<void> onLoad() async {
    _startVolume = player.volume;
    _elapsed = 0;
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    double progress;

    if (_elapsed >= duration) {
      progress = 1.0;
    } else {
      progress = _elapsed / duration;
    }

    // Linearly interpolate the volume
    final newVolume = lerpDouble(_startVolume, targetVolume, progress)!;
    player.setVolume(newVolume);

    // When done, clean up
    if (progress == 1.0) {
      onComplete?.call();
      removeFromParent();
    }
  }
}
