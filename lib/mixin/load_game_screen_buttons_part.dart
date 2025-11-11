part of 'ui_tiledmap_mixin.dart';

extension LoadGameScreenButtonsPart on TiledUiBuilder {
  void _loadGameScreen(String buttonName) {
    if (this is LoadGameScreen) {
      LoadGameScreen loadGameScreen = this as LoadGameScreen;
      switch (buttonName) {
        case 'menu':
          game.goToHomeScreen();
          break;
        case 'skip':
          loadGameScreen.nextPage();
          break;
        case 'logs':
          loadGameScreen.previousPage();
          break;
        default:
          if (kDebugMode) {
            print('Button "$buttonName" pressed (no action assigned).');
          }
      }
    }
  }
}
