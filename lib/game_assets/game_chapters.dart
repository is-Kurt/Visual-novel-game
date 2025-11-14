import 'package:helloworld_hellolove/game_scene/scene.dart';

class GameChapters {
  late String playerName;

  Future<Scene> newGame(String playerName) async {
    this.playerName = playerName;
    Scene.isAuto = false;
    return Scene('c1_1', playerName);
  }

  Future<Scene> loadGame(String chapter, playerName, int? savedLine, int? currentPoint) async {
    this.playerName = playerName;
    Scene.isAuto = false;
    return Scene(chapter, playerName, savedLine: savedLine, savedPoint: currentPoint);
  }

  void goToChapter(String chapter) async {
    Scene(chapter, playerName);
  }
}
