import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:helloworld_hellolove/game_db/save_manager.dart';
import 'package:helloworld_hellolove/game_scene/scene.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:flutter/foundation.dart';
import 'package:helloworld_hellolove/screens/home_screen.dart';
import 'package:helloworld_hellolove/screens/load_game_screen/load_game_screen.dart';
import 'package:helloworld_hellolove/utils/rounded_rectangle.dart';
import 'package:helloworld_hellolove/utils/tappable_input_text_box.dart';

part 'pop_up_card_part.dart';
part 'scene_buttons_part.dart';
part 'home_screen_buttons_part.dart';
part 'load_game_screen_buttons_part.dart';

final List<String> objectExceptions = ['decisionContainer'];

mixin TiledUiBuilder on Component, HasGameReference<HelloworldHellolove> {
  Future<void> buildUiFromTiled(ObjectGroup objectLayer) async {
    for (final TiledObject obj in objectLayer.objects) {
      if (!objectExceptions.contains(obj.name)) {
        final sprite = await Sprite.load('HUD/${obj.name}.webp');

        if (obj.class_ == 'button') {
          late ButtonComponent button;

          button = ButtonComponent(
            button: SpriteComponent(
              sprite: sprite,
              size: Vector2(obj.width, obj.height),
              paint: Paint()..filterQuality = FilterQuality.high,
            ),
            position: Vector2(obj.x, obj.y),
            size: Vector2(obj.width, obj.height),
            anchor: Anchor.bottomLeft,
            priority: 10,
            onPressed: () {
              _handleButtonPress(obj.name);
            },
          );
          await add(button);

          if (this is Scene) {
            final scene = this as Scene;
            if (obj.name == 'auto') scene.autoButton = button;
            // if (obj.name == 'menu') scene.menuButton = button;
          }
        } else {
          final staticImage = SpriteComponent(
            sprite: sprite,
            position: Vector2(obj.x, obj.y),
            size: Vector2(obj.width, obj.height),
            anchor: Anchor.bottomLeft,
            paint: Paint()..filterQuality = FilterQuality.high,
          );

          if (this is LoadGameScreen) {
            final overlay = RectangleComponent(
              size: HelloworldHellolove.virtualResolution,
              paint: Paint()..color = const Color(0x80000000),
              priority: 0,
            );
            await staticImage.add(overlay);
          }
          await add(staticImage);
        }
      }
    }
  }

  void _handleButtonPress(String buttonName) {
    _homeScreenButons(buttonName);
    _sceneButtons(buttonName);
    _loadGameScreen(buttonName);
  }
}
