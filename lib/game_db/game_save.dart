import 'package:helloworld_hellolove/game_assets/character_data.dart';

class GameSave {
  final String saveName;
  final String gameChapter;
  final String playerName;
  final int gameSavedLine;
  final String currentLocation;
  final Map<String, CharacterData> currentCharacters;
  final String currentText;
  final int currentPoint;

  GameSave({
    required this.saveName,
    required this.gameSavedLine,
    required this.playerName,
    required this.gameChapter,
    required this.currentLocation,
    required this.currentCharacters,
    required this.currentText,
    required this.currentPoint,
  });

  // Creates a GameSave object from a JSON map
  factory GameSave.fromJson(Map<String, dynamic> json) {
    return GameSave(
      saveName: json['saveName'] as String,
      gameSavedLine: json['gameState'] as int,
      playerName: json['playerName'] as String,
      gameChapter: json['gameChapter'] as String,
      currentLocation: json['location'] as String,
      currentCharacters: (json['currentCharacters'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CharacterData.fromJson(value as Map<String, dynamic>)),
      ),
      currentText: json['currentText'] as String,
      currentPoint: json['currentPoint'] as int,
    );
  }

  // Converts this GameSave object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'saveName': saveName,
      'gameChapter': gameChapter,
      'playerName': playerName,
      'gameState': gameSavedLine,
      'location': currentLocation,
      'currentCharacters': currentCharacters,
      'currentText': currentText,
      'currentPoint': currentPoint,
    };
  }
}
