import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';
import 'package:flutter/services.dart';

import 'package:helloworld_hellolove/screens/home_screen.dart';
import 'package:helloworld_hellolove/game_scene/scene.dart';
import 'package:flutter/painting.dart';
import 'package:helloworld_hellolove/sets/scene_set.dart';

class HelloworldHellolove extends FlameGame with HasKeyboardHandlerComponents {
  static final virtualResolution = Vector2(1920, 1080);

  // --- NEW: Class-level variables ---
  late List<SceneSets> chapters;
  late SceneSets chapter;
  late Scene chapterScene;
  late World homeScreen;
  late final CameraComponent cam;
  // ----------------------------------

  @override
  Color backgroundColor() {
    return const Color(0xFF000000);
  }

  @override
  FutureOr<void> onLoad() async {
    // String fullText = await rootBundle.loadString('assets/');
    // print(fullText);
    await images.loadAllImages();

    homeScreen = HomeScreen(); // Assign to class variable

    // Assign to class variable
    cam = CameraComponent(
      world: homeScreen,
      viewport: FixedResolutionViewport(resolution: virtualResolution),
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    await add(homeScreen);
    await add(cam);

    return super.onLoad();
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
