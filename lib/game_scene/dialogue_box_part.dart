part of 'scene.dart';

extension DialogueBoxPart on Scene {
  Future<void> addDialogueBox() async {
    final boxHeight = 300.0;
    final boxSize = Vector2(HelloworldHellolove.virtualResolution.x, boxHeight);
    final boxPaint = Paint()..color = const Color(0xAA000000);

    final dialogueBox = RectangleComponent(
      size: boxSize,
      position: Vector2(0, HelloworldHellolove.virtualResolution.y),
      anchor: Anchor.bottomLeft,
      paint: boxPaint,
      priority: 10,
    );

    final textStyle = TextPaint(style: TextStyle(fontSize: 32.0, color: const Color(0xFFFFFFFF)));

    const padding = 50.0;

    final textBox = TextBoxComponent(
      text: "",
      textRenderer: textStyle,
      size: Vector2(boxSize.x - (padding * 2), boxSize.y - (padding * 2)),
      position: Vector2(padding, padding),
    );

    _textBox = textBox;
    _dialogueBox = dialogueBox;
    await dialogueBox.add(textBox);
  }
}
