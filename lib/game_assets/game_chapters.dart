import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/game_scene/scene.dart';

class GameChapters {
  late final List<String> chapters;
  late String playerName;

  Future<void> initiate() async {
    final AssetManifest assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final List<String> allAssetPaths = assetManifest.listAssets();
    chapters = allAssetPaths.where((path) => path.startsWith('assets/chapters/')).toList();
  }

  Future<Scene> newGame(String playerName) async {
    this.playerName = playerName;
    Scene.isAuto = false;
    return Scene('c1_1', playerName);
  }

  Future<Scene> loadGame(String chapter, playerName, int? savedLine, int? currentPoint) async {
    Scene.isAuto = false;
    return Scene(chapter, playerName, savedLine: savedLine, savedPoint: currentPoint);
  }

  void goToChapter(String chapter) async {
    Scene(chapter, playerName);
  }
}
