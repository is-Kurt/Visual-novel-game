import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/game_assets/character_sprites_cache.dart';
import 'package:helloworld_hellolove/screens/home_screen.dart';
import 'package:helloworld_hellolove/game_scene/scene.dart';
import 'package:helloworld_hellolove/game_assets/scene_set.dart';

class HelloworldHellolove extends FlameGame with HasKeyboardHandlerComponents {
  static final virtualResolution = Vector2(1920, 1080);

  late List<SceneSets> chapters;
  late SceneSets chapter;
  late Scene chapterScene;
  late World homeScreen;
  late final CameraComponent cam;

  @override
  Color backgroundColor() {
    return const Color(0xFF000000);
  }

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    await CharacterSpriteManager.loadAllSprites();

    homeScreen = HomeScreen();
    cam = CameraComponent(
      world: homeScreen,
      viewport: FixedResolutionViewport(resolution: virtualResolution),
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    await add(homeScreen);
    await add(cam);

    return super.onLoad();
  }

  void exitGame() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  void startNewGame() {
    chapters = getChapters();

    if (chapters.isNotEmpty) chapter = chapters.removeAt(0);
    if (chapter.scenes.isNotEmpty) chapterScene = chapter.scenes.removeAt(0);

    remove(homeScreen);
    add(chapterScene);

    cam.world = chapterScene;
  }

  void goToNextScene() {
    remove(chapterScene);
    if (chapter.scenes.isNotEmpty) {
      chapterScene = chapter.scenes.removeAt(0);
    } else if (chapters.isNotEmpty) {
      chapter = chapters.removeAt(0);
      if (chapter.scenes.isNotEmpty) chapterScene = chapter.scenes.removeAt(0);
    } else {
      goToHomeScreen();
      return;
    }

    add(chapterScene);
    cam.world = chapterScene;
  }

  void goToHomeScreen() {
    remove(chapterScene);
    add(homeScreen);
    cam.world = homeScreen;
  }
}
