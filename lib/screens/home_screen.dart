import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/mixin/ui_tiledmap_mixin.dart';

class HomeScreen extends World with HasGameReference<HelloworldHellolove>, TiledUiBuilder {
  @override
  FutureOr<void> onLoad() async {
    final tiledMap = await TiledComponent.load('homeScreen.tmx', Vector2.all(1.0));
    tiledMap.priority = 11;
    await add(tiledMap);
    final objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>('homeScreenButtons');

    if (objectLayer != null) {
      buildUiFromTiled(objectLayer);
    }
  }
}
   // --- Characters in homescreen---
    // final akagi = characterFactory('Akagi');
    // akagi.setPosition(Vector2(1400, HelloworldHellolove.virtualResolution.y - akagi.size.y));
    // await add(akagi);

    // final habane = characterFactory('Habane');
    // habane.setPosition(Vector2(1100, HelloworldHellolove.virtualResolution.y - habane.size.y));
    // habane.priority = 1;

    // await add(habane);

    // final hotaru = characterFactory('Hotaru');
    // hotaru.setFacingDirection(FacingAt.left);
    // hotaru.setPosition(Vector2(-30, HelloworldHellolove.virtualResolution.y - hotaru.size.y));
    // await add(hotaru);
  

