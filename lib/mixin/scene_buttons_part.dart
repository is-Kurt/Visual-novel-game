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
          scene.isPopUpMounted = true;
          await add(
            await SettingsOverlay().openSettings(() {
              scene.isPopUpMounted = false;
            }),
          );
          break;
        case 'settings':
          break;
        case 'save':
          scene.saveGame();
          break;
        case 'menu':
          add(
            openPopUp('Save before exiting?', {
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

                FlameAudio.bgm.audioPlayer.setVolume(0.0);
                FlameAudio.bgm.resume();

                game.fadeAudio(FlameAudio.bgm.audioPlayer, game.soundVolume, 0.5);
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

                FlameAudio.bgm.audioPlayer.setVolume(0.0);
                FlameAudio.bgm.resume();

                game.fadeAudio(FlameAudio.bgm.audioPlayer, game.soundVolume, 0.5);
              },
            }, onRemovePopUp: () => scene.isPopUpMounted = false),
          );
          scene.isPopUpMounted = true;
          break;
        default:
          if (kDebugMode) {
            print('Button "$buttonName" pressed (no action assigned).');
          }
      }
    }
  }
}
