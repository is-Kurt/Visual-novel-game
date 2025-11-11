part of 'load_game_screen.dart';

extension DialogueBoxPart on LoadGameScreen {
  Future<RectangleComponent> addDialogue(String text) async {
    final dialogueBoxSize = Vector2(saveBoxSize.x, saveBoxSize.y * (2 / 7));
    final dialogueBoxPaint = Paint()..color = const Color(0xAA000000);

    final dialogueBox = RectangleComponent(
      size: dialogueBoxSize,
      position: Vector2(0, saveBoxSize.y),
      anchor: Anchor.bottomLeft,
      paint: dialogueBoxPaint,
      priority: 2,
    );

    final textStyle = TextPaint(
      style: TextStyle(fontSize: 32.0 * sizeRatio, color: const Color(0xFFFFFFFF)),
    );

    final padding = 50.0 * sizeRatio;

    final textBox = TextBoxComponent(
      text: text,
      textRenderer: textStyle,
      size: Vector2(dialogueBoxSize.x - (padding * 2), dialogueBoxSize.y - (padding * 2)),
      position: Vector2(padding, padding),
    );

    dialogueBox.add(textBox);
    return dialogueBox;
  }
}
