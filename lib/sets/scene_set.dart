import 'package:helloworld_hellolove/game_scene/scene.dart';

class SceneSets {
  final String name;
  final List<Scene> scenes;

  SceneSets({required this.name, required this.scenes});
}

String dialoguePath = 'assets/dialogue/';

List<SceneSets> getChapters() {
  return [
    SceneSets(
      name: 'Chapter1',
      scenes: [
        Scene('${dialoguePath}c1_s1.txt'),
        Scene('${dialoguePath}c1_s1.txt'),
        Scene('${dialoguePath}c1_s1.txt'),
      ],
    ),
  ];
}
