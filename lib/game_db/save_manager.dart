import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'game_save.dart';

class SaveManager {
  // Helper to get the save directory
  Future<Directory> _getSaveDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final saveDirPath = join(appDir.path, 'game_saves');
    final saveDir = Directory(saveDirPath);

    // Create the directory if it doesn't exist
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }
    return saveDir;
  }

  // --- Core Database Functions ---

  /// Saves a GameSave object to a .txt file.
  /// The filename will be [saveName].txt
  Future<void> saveGame(GameSave save) async {
    final saveDir = await _getSaveDirectory();
    final fileName = '${save.saveName}.txt';
    final file = File(join(saveDir.path, fileName));

    // 1. Convert the object to a JSON map
    final jsonMap = save.toJson();

    // 2. Encode the map into a formatted JSON string
    final jsonString = JsonEncoder.withIndent('  ').convert(jsonMap);

    // 3. Write the string to the file
    await file.writeAsString(jsonString);
    print('Game saved to: ${file.path}');
  }

  /// Loads a GameSave object from a .txt file
  Future<GameSave?> loadGame(String fileName) async {
    try {
      final saveDir = await _getSaveDirectory();
      final file = File(join(saveDir.path, fileName));

      // 1. Read the JSON string from the file
      final jsonString = await file.readAsString();

      // 2. Decode the string into a map
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      // 3. Convert the map into a GameSave object
      return GameSave.fromJson(jsonMap);
    } catch (e) {
      // Handle errors (e.g., file not found, corrupt JSON)
      print('Error loading game $fileName: $e');
      return null;
    }
  }

  /// Lists all .txt files in the save directory.
  Future<List<File>> listSaveFiles() async {
    final saveDir = await _getSaveDirectory();
    final List<File> txtFiles = [];

    // List all entities in the directory
    await for (final entity in saveDir.list()) {
      // Check if it's a file and ends with .txt
      if (entity is File && extension(entity.path).toLowerCase() == '.txt') {
        txtFiles.add(entity);
      }
    }

    // Sort files by last modified date (newest first)
    txtFiles.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });

    return txtFiles;
  }

  /// Deletes a save file by its name (e.g., 'my_save_1.txt')
  Future<void> deleteSave(String fileName) async {
    try {
      final saveDir = await _getSaveDirectory();
      final file = File(join(saveDir.path, '$fileName.txt'));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting game $fileName: $e');
      }
    }
  }
}
