part of 'ui_tiledmap_mixin.dart';

extension SceneButtonsPart on TiledUiBuilder {
  Future<void> _sceneButtons(String buttonName) async {
    if (this is Scene) {
      final scene = this as Scene;
      switch (buttonName) {
        case 'auto':
          scene.isAutoClicked(true);
          break;
        case 'logs':
          break;
        case 'load':
          _openSettingsPopUp(scene);
          break;
        case 'settings':
          break;
        case 'save':
          scene.saveGame();
          break;
        case 'menu':
          add(_exitPopUp(scene));
          break;
        default:
          if (kDebugMode) {
            print('Button "$buttonName" pressed (no action assigned).');
          }
      }
    }
  }

  void _openSettingsPopUp(Scene scene) {
    game.characterSFX?.pause();
    scene.isPopUpMounted = true;
    game.openSettingsOverlay(() {
      scene.isPopUpMounted = false;
      game.characterSFX?.resume();
      game.characterSFX?.setVolume(game.masterVolume * game.sfxVolume);
    });
  }

  ButtonComponent _exitPopUp(Scene scene) {
    scene.isPopUpMounted = true;
    game.characterSFX?.pause();

    final exitPopUp = openPopUp(
      'Save before exiting?',
      {
        'Save and Exit': () async {
          await scene.saveGame();
          game.goToHomeScreen();
          await game.minigameAudioPlayer?.stop();
          game.minigameAudioPlayer = null;

          if (game.minigameAudioPlayer != null) {
            game.fadeAudio(game.minigameAudioPlayer!, 0.0, 0.5, () {
              game.minigameAudioPlayer!.stop();
              game.minigameAudioPlayer = null;
            });
          }
          game.loadMainAudio();
        },
        'Exit': () async {
          game.goToHomeScreen();
          await game.minigameAudioPlayer?.stop();
          game.minigameAudioPlayer = null;

          if (game.minigameAudioPlayer != null) {
            game.fadeAudio(game.minigameAudioPlayer!, 0.0, 0.5, () {
              game.minigameAudioPlayer!.stop();
              game.minigameAudioPlayer = null;
            });
          }
          game.loadMainAudio();
        },
      },
      onRemovePopUp: () => {
        scene.isPopUpMounted = false,
        game.characterSFX?.resume(),
        game.characterSFX?.setVolume(game.masterVolume * game.sfxVolume),
      },
    );

    return exitPopUp;
  }
}
