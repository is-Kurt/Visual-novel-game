import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/sets/characters.dart';

class HomeScreen extends World with HasGameReference<HelloworldHellolove> {
  @override
  FutureOr<void> onLoad() async {
    final backgroundSprite = await Sprite.load(
      'locations/Courtyard (Sunset).png',
    );
    final backgroundComponent = SpriteComponent()
      ..priority = -1
      ..sprite = backgroundSprite
      ..size = HelloworldHellolove.virtualResolution;
    await add(backgroundComponent);

    final tiledMap = await TiledComponent.load(
      'homeScreen.tmx',
      Vector2.all(1.0),
    );
    add(tiledMap);

    final objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>(
      'HomeScreenButtons',
    );

    if (objectLayer != null) {
      for (final TiledObject obj in objectLayer.objects) {
        final buttonSprite = await Sprite.load('HUD/newGameButton.png');

        final button = ButtonComponent(
          button: SpriteComponent(
            sprite: buttonSprite,
            size: Vector2(obj.width, obj.height),
          ),
          position: Vector2(obj.x, obj.y),
          size: Vector2(obj.width, obj.height),
          anchor: Anchor.bottomLeft,
          onPressed: () {
            _handleButtonPress(obj.name);
          },
        );

        await add(button);
      }
    } else {
      if (kDebugMode) {
        print('ERROR: Could not find object layer');
      }
    }

    // --- Characters in homescreen---
    final akagi = characterFactory('Akagi');
    akagi.setPosition(
      Vector2(1400, HelloworldHellolove.virtualResolution.y - akagi.size.y),
    );
    await add(akagi);

    final habane = characterFactory('Habane');
    habane.setPosition(
      Vector2(1100, HelloworldHellolove.virtualResolution.y - habane.size.y),
    );
    habane.priority = 1;

    await add(habane);

    final hotaru = characterFactory('Hotaru');
    hotaru.setFacingDirection(FacingAt.left);
    hotaru.setPosition(
      Vector2(-30, HelloworldHellolove.virtualResolution.y - hotaru.size.y),
    );
    await add(hotaru);
  }

  void _handleButtonPress(String buttonName) {
    switch (buttonName) {
      case 'NewGameButton':
        print('Starting a new game!');
        game.startNewGame();
        break;
      case 'LoadGameButton':
        print('Loading a saved game!');
        break;
      case 'SettingsButton':
        print('Opening settings!');
        break;
      default:
        print('Button "$buttonName" pressed.');
    }
  }
}
