import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:flutter/foundation.dart';

final List<String> objectExceptions = ['dialogueBox', 'decisionContainer'];

mixin TiledUiBuilder on Component, HasGameReference<HelloworldHellolove> {
  Future<void> buildUiFromTiled(ObjectGroup objectLayer) async {
    for (final TiledObject obj in objectLayer.objects) {
      if (!objectExceptions.contains(obj.name)) {
        final sprite = await Sprite.load('HUD/${obj.name}.webp');

        if (obj.class_ == 'button') {
          final button = ButtonComponent(
            button: SpriteComponent(sprite: sprite, size: Vector2(obj.width, obj.height)),
            position: Vector2(obj.x, obj.y),
            size: Vector2(obj.width, obj.height),
            anchor: Anchor.bottomLeft,
            priority: 20,
            onPressed: () {
              _handleButtonPress(obj.name);
            },
          );
          await add(button);
        } else {
          final staticImage = SpriteComponent(sprite: sprite, position: Vector2(obj.x, obj.y), size: Vector2(obj.width, obj.height), anchor: Anchor.bottomLeft);
          await add(staticImage);
        }
      }
    }
  }

  void _handleButtonPress(String buttonName) {
    switch (buttonName) {
      case 'newGame':
        game.startNewGame();
        break;
      case 'loadGame':
        print('Loading a saved game!');
        // e.g., game.loadGame();
        break;
      case 'settingsButton':
        print('Opening settings!');
        // e.g., game.goToSettings();
        break;
      case 'menu':
        game.goToHomeScreen();
      case 'exit':
        print('exit');
        game.exitGame();
        break;
      default:
        if (kDebugMode) {
          print('Button "$buttonName" pressed (no action assigned).');
        }
    }
  }
}
