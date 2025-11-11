part of 'scene.dart';

extension DialogueOptionsPart on Scene {
  Future<void> showDecisions(List<String> options, List<String> scenesPoints) async {
    _isWaitingForDecision = true;

    if (objectLayer == null) return;

    final TiledObject container = objectLayer!.objects.firstWhere((object) => object.name == 'decisionContainer');

    const double boxHeight = 70;
    const double bottomMargin = 10;
    final double overallHeight = (boxHeight + bottomMargin) * options.length;

    for (int i = 0; i < options.length; i++) {
      final double offsetY = i * (boxHeight + bottomMargin);
      final decisionButton = await _createDecisionButton(
        container,
        boxHeight,
        offsetY,
        overallHeight,
        options[i],
        scenesPoints[i],
        () => _handleDecision(scenesPoints[i]),
      );

      await add(decisionButton);
      _decisionButtons.add(decisionButton);
    }
  }

  Future<void> _handleDecision(String scene) async {
    _isWaitingForDecision = false;

    for (final button in _decisionButtons) {
      remove(button);
    }
    _decisionButtons.clear();

    if (_scenePointLineIndex[scene] != null) {
      currentLineIndex = _scenePointLineIndex[scene]!;
    }

    // Remove decision event audio
    await game.minigameAudioPlayer?.stop();
    game.minigameAudioPlayer = null;

    if (game.minigameAudioPlayer != null) {
      game.fadeAudio(game.minigameAudioPlayer!, 0.0, 0.5, () {
        game.minigameAudioPlayer!.stop();
        game.minigameAudioPlayer = null;
      });
    }

    FlameAudio.bgm.audioPlayer.setVolume(0.0);
    FlameAudio.bgm.resume();

    game.fadeAudio(FlameAudio.bgm.audioPlayer, game.masterVolume * game.musicVolume, 0.5);

    advanceScript();
  }

  Future<ButtonComponent> _createDecisionButton(
    TiledObject obj,
    double boxHeight,
    double offsetY,
    double overallHeight,
    String option,
    String scene,
    VoidCallback onPressed,
  ) async {
    final boxSize = Vector2(obj.width, boxHeight);

    // Semi-transparent black rectangle background
    final boxPaint = Paint()..color = const Color(0xAA000000);
    final buttonShape = RectangleComponent(size: boxSize, paint: boxPaint);

    // Create the actual button
    final decisionButton = ButtonComponent(
      size: boxSize,
      position: Vector2(obj.x, ((obj.height - overallHeight) / 2) + offsetY),
      anchor: Anchor.topLeft,
      priority: 10,
      button: buttonShape,
      buttonDown: RectangleComponent(size: boxSize, paint: Paint()..color = const Color(0xAA333333)),
      onPressed: onPressed,
    );

    // Text style for button labels
    final textStyle = TextPaint(style: const TextStyle(fontSize: 24.0, color: Color(0xFFFFFFFF)));

    const padding = 10.0;

    final textBox = TextBoxComponent(
      text: option,
      textRenderer: textStyle,
      size: Vector2(boxSize.x - (padding * 2), boxSize.y - (padding * 2)),
      position: Vector2(padding, padding),
      anchor: Anchor.topLeft,
      priority: 1,
      align: Anchor.center,
    );

    await decisionButton.add(textBox);
    return decisionButton;
  }
}
