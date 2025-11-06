import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';

mixin UiHelpers on Component, HasGameReference<HelloworldHellolove> {
  late TiledComponent<FlameGame<World>> tiledMap;

  Future<void> addUIElements(
    String tiledMapName,
    String objectLayerName, {
    int decisionAmount = 0,
  }) async {
    tiledMap = await TiledComponent.load('$tiledMapName.tmx', Vector2.all(1.0));
    tiledMap.priority = 11;
    await add(tiledMap);

    final objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>(objectLayerName);

    if (objectLayer != null) {
      for (final TiledObject obj in objectLayer.objects) {
        String spritePath = '';
        if (obj.name == 'exitButton') {
          spritePath = 'HUD/exitButton.png';
        } else if (obj.name == 'NewGameButton') {
          spritePath = 'HUD/newGameButton.png';
        }

        if (spritePath.isEmpty) {
          // This "continue" is correct, it skips the button logic below
          continue;
        }

        final buttonSprite = await Sprite.load(spritePath);

        final button = ButtonComponent(
          button: SpriteComponent(
            sprite: buttonSprite,
            size: Vector2(obj.width, obj.height),
          ),
          position: Vector2(obj.x, obj.y),
          size: Vector2(obj.width, obj.height),
          anchor: Anchor.topLeft,
          priority: 12,
          onPressed: () {
            handleButtonPress(obj.name);
          },
        );

        await add(button);
      }
    } else {
      if (kDebugMode) {
        print('ERROR: Could not find object layer "$objectLayerName"');
      }
    }
  }

  void handleButtonPress(String buttonName) {
    switch (buttonName) {
      case 'exitButton':
        print("exit");
        game.goToHomeScreen();
        break;

      case 'NewGameButton':
        print('Starting a new game!');
        game.startNewGame();
        break;

      default:
        print('Button "$buttonName" pressed.');
    }
  }

  Future<List<ButtonComponent>> addDecisionElement(
    List<String> options,
    List<String> scenes,
    Function(String scene) onDecisionMade,
  ) async {
    final objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>('sceneElements');
    if (objectLayer == null) return [];
    final TiledObject container = objectLayer.objects.firstWhere(
      (object) => object.name == 'decisionContainer',
    );

    List<ButtonComponent> createdButtons = [];

    const double boxHeight = 70;
    const double bottomMargin = 10;
    final double overAllHeight = (boxHeight + bottomMargin) * options.length;

    for (int i = 0; i < options.length; i++) {
      final double offsetY = i * (boxHeight + bottomMargin);

      final decisionButton = await _createDecisionButton(
        container,
        boxHeight,
        offsetY,
        overAllHeight,
        options[i],
        scenes[i],
        () => onDecisionMade(scenes[i]),
      );

      await add(decisionButton);
      createdButtons.add(decisionButton);
    }

    return createdButtons;
  }

  Future<ButtonComponent> _createDecisionButton(
    TiledObject obj,
    double boxHeight,
    double offsetY,
    double overAllHeight,
    String option,
    String scene,
    VoidCallback onPressed,
  ) async {
    final boxSize = Vector2(obj.width, boxHeight);

    // 1. This is your exact design: a semi-transparent black rectangle
    final boxPaint = Paint()..color = const Color(0xAA000000);
    final buttonShape = RectangleComponent(size: boxSize, paint: boxPaint);

    // 2. We create a ButtonComponent
    final decisionButton = ButtonComponent(
      size: boxSize,
      position: Vector2(obj.x, ((obj.height - overAllHeight) / 2) + offsetY),
      anchor: Anchor.topLeft,
      priority: 10,
      button: buttonShape,

      buttonDown: RectangleComponent(
        size: boxSize,
        paint: Paint()..color = const Color(0xAA333333),
      ),

      // 6. Set the onPressed callback
      onPressed: onPressed,
    );

    final textStyle = TextPaint(
      style: const TextStyle(fontSize: 24.0, color: Color(0xFFFFFFFF)),
    );

    const padding = 10.0;

    final textBox = TextBoxComponent(
      text: option, // Use the text passed in
      textRenderer: textStyle,
      size: Vector2(boxSize.x - (padding * 2), boxSize.y - (padding * 2)),
      position: Vector2(padding, padding),
      align: Anchor.center,
      priority: 1,
    );

    decisionButton.add(textBox);
    return decisionButton;
  }
}
