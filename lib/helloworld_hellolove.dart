import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/game_assets/character_sprites_cache.dart';
import 'package:helloworld_hellolove/screens/home_screen.dart';
import 'package:helloworld_hellolove/game_assets/game_chapters.dart';
import 'package:helloworld_hellolove/screens/load_game_screen/load_game_screen.dart';
import 'package:helloworld_hellolove/screens/settings_overlay.dart';
import 'package:helloworld_hellolove/utils/audio_fader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helloworld_hellolove/game_scene/scene.dart';
import 'package:window_manager/window_manager.dart';

class HelloworldHellolove extends FlameGame with HasKeyboardHandlerComponents {
  static final virtualResolution = Vector2(1920, 1080);
  late final CameraComponent cam;

  final GameChapters chapter = GameChapters();
  final homeScreen = HomeScreen();

  // 1. GIVE YOUR VARIABLES DEFAULT VALUES
  // These are 0.0 - 1.0
  double masterVolume = 1.0;
  double musicVolume = 1.0;
  double sfxVolume = 1.0;

  bool playSounds = true;
  late String currentbgm;
  AudioPlayer? minigameAudioPlayer;
  AudioPlayer? characterSFX;
  final Map<AudioPlayer, AudioFaderComponent> _activeFaders = {};

  @override
  Color backgroundColor() {
    return const Color(0xFF000000);
  }

  @override
  FutureOr<void> onLoad() async {
    await CharacterSpriteManager.loadAllSprites();
    _loadGameFiles();

    cam = CameraComponent(
      world: homeScreen,
      viewport: FixedResolutionViewport(resolution: virtualResolution),
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    await add(homeScreen);
    await add(cam);

    return super.onLoad();
  }

  void loadMainAudio() {
    currentbgm = 'Main Theme';
    FlameAudio.bgm.play('bgm/Main Theme.wav', volume: musicVolume * masterVolume);

    final state = FlameAudio.bgm.audioPlayer.state;
    if (state == PlayerState.paused) {
      FlameAudio.bgm.resume();
    }
  }

  void _loadGameFiles() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'bgm/Main Theme.wav',
      'bgm/Park or Sad V2.wav',
      'bgm/Park or Sad.wav',
      'bgm/Sad V1.wav',
      'sfx/Minigame Ext.wav',
      'sfx/Minigame OST.wav',
      'sfx/test_laugh.wav',
      'sfx/test_sfx.wav',
    ]);
    await images.loadAllImages();
    await loadSettings();
    loadMainAudio();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    masterVolume = prefs.getDouble('masterVolume') ?? 1.0;
    musicVolume = prefs.getDouble('musicVolume') ?? 1.0;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 1.0;
    final savedTextSpeed = prefs.getDouble('textSpeed') ?? 50.0;

    FlameAudio.bgm.audioPlayer.setVolume(musicVolume * masterVolume);
    if (minigameAudioPlayer != null) {
      minigameAudioPlayer!.setVolume(sfxVolume * masterVolume);
    }
    Scene.textSpeed = 0.10 - (savedTextSpeed / 100) * 0.10;
    Scene.advanceDelayTime = (1 - (savedTextSpeed / 100)) + 0.1;

    await setWindowManagerSettings(prefs);
  }

  Future<void> setWindowManagerSettings(prefs) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final isFullScreen = prefs.getBool('isFullScreen') ?? true;
      await windowManager.setFullScreen(isFullScreen);

      if (!isFullScreen) {
        WindowOptions windowOptions = const WindowOptions(
          size: Size(1280, 750),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
        );

        await windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }
    }
  }

  void openSettingsOverlay([VoidCallback? onDismount]) async {
    final settingsOverlay = await SettingsOverlay(game: this).openSettings(() async {
      await loadSettings();
      if (onDismount != null) {
        onDismount();
      }
    });
    await cam.world!.add(settingsOverlay);
  }

  void fadeAudio(AudioPlayer player, double targetVolume, double duration, [VoidCallback? onComplete]) {
    _activeFaders[player]?.removeFromParent();

    // 2. Create the new fader
    late final AudioFaderComponent fader;
    fader = AudioFaderComponent(
      player: player,
      targetVolume: targetVolume,
      duration: duration,
      onComplete: () {
        onComplete?.call();
        _activeFaders.remove(player);
      },
    );
    _activeFaders[player] = fader;
    add(fader);
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

class WindowManagerListener with WindowListener {
  HelloworldHellolove game;
  WindowManagerListener({required this.game});

  @override
  void onWindowMaximize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFullScreen', true);

    game.setWindowManagerSettings(prefs);
  }

  @override
  void onWindowUnmaximize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFullScreen', false);

    game.setWindowManagerSettings(prefs);
    super.onWindowUnmaximize();
  }
}
