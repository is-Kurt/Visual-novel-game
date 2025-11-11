part of 'ui_tiledmap_mixin.dart';

extension HomeScreenButtonsPart on TiledUiBuilder {
  void _homeScreenButons(String buttonName) {
    if (this is HomeScreen) {
      switch (buttonName) {
        case 'newGame':
          _newGamePopUp();
          break;
        case 'loadGame':
          game.goToLoadScreen();
          break;
        case 'gallery':
          break;
        case 'settings':
          _openSettingsMenu();
          break;
        case 'exit':
          _exitGamePopUp();
          break;
        default:
          if (kDebugMode) {
            print('Button "$buttonName" pressed (no action assigned).');
          }
      }
    }
  }

  void _newGamePopUp() {
    final newGamePopUp = openTextInputPopUp('Enter player name:', {
      'Save': (text) {
        game.startNewGame(text);
      },
      'Back': null,
    }, exitOnBackgroundClick: false);

    add(newGamePopUp);
  }

  void _exitGamePopUp() {
    final exitPopUp = openPopUp('Are you sure you want to exit the game?', {
      'Yes': game.exitGame,
      'No': () {},
    }, exitOnBackgroundClick: false);
    add(exitPopUp);
  }

  Future<void> _openSettingsMenu() async {
    add(await SettingsOverlay().openSettings());
  }
}
