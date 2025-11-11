import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/game_assets/character_sprites_cache.dart';
import 'package:helloworld_hellolove/screens/home_screen.dart';
import 'package:helloworld_hellolove/game_assets/game_chapters.dart';
import 'package:helloworld_hellolove/screens/load_game_screen/load_game_screen.dart';
import 'package:helloworld_hellolove/utils/audio_fader.dart';

class HelloworldHellolove extends FlameGame with HasKeyboardHandlerComponents {
  static final virtualResolution = Vector2(1920, 1080);
  late final CameraComponent cam;

  final GameChapters chapter = GameChapters();
  final homeScreen = HomeScreen();

  double soundVolume = 0.25;
  bool playSounds = true;
  AudioPlayer? minigameAudioPlayer;

  @override
  Color backgroundColor() {
    return const Color(0xFF000000);
  }

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.play('Main Theme.wav', volume: soundVolume);

    await images.loadAllImages();
    await CharacterSpriteManager.loadAllSprites();
    chapter.initiate();

    cam = CameraComponent(
      world: homeScreen,
      viewport: FixedResolutionViewport(resolution: virtualResolution),
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    await add(homeScreen);
    await add(cam);

    return super.onLoad();
  }

  void fadeAudio(AudioPlayer player, double targetVolume, double duration, [VoidCallback? onComplete]) {
    add(AudioFaderComponent(player: player, targetVolume: targetVolume, duration: duration, onComplete: onComplete));
  }

  // --- Text state for the overlay for virtual keyboard ---
  String textToEdit = ""; // This will be updated by the overlay
  void Function(String)? onTextUpdate; // Callback for real-time updates
  // --- Method to update text from overlay ---
  void updateText(String newText) {
    textToEdit = newText;
    onTextUpdate?.call(newText);
  }

  void moveScreenTo(World screen) {
    final World? currentWorld = cam.world;
    if (currentWorld != null) {
      remove(currentWorld);
    }
    cam.world = screen;
    add(screen);
  }

  Future<void> startNewGame(String playerName) async {
    moveScreenTo(await chapter.newGame(playerName));
  }

  // parameters in brackets are only used when loading games
  Future<void> goToChapter(String chapter, String playerName, {int? savedLine, int? currentPoint}) async {
    moveScreenTo(await this.chapter.loadGame(chapter, playerName, savedLine, currentPoint));
  }

  void goToHomeScreen() {
    moveScreenTo(homeScreen);
  }

  void goToLoadScreen() {
    moveScreenTo(LoadGameScreen());
  }

  void exitGame() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }
}
