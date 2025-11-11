import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:helloworld_hellolove/game_assets/character_data.dart';
import 'package:helloworld_hellolove/game_db/save_manager.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/mixin/ui_tiledmap_mixin.dart';
import 'package:helloworld_hellolove/utils/rounded_rectangle.dart';
import 'package:path/path.dart';

part 'decision_container_part.dart';
part 'characters_part.dart';
part 'dialogue_box_part.dart';
part 'save_game_container_part.dart';

class LoadGameScreen extends World with HasGameReference<HelloworldHellolove>, TiledUiBuilder {
  final sizeRatio = 560 / 1920;
  final SaveManager saveManager = SaveManager();
  late Vector2 saveBoxSize;
  late Vector2 saveBoxPosition;
  late List<File> saveFiles;

  int _currentPage = 0;
  final List<Component> _currentSaveBoxes = [];

  @override
  FutureOr<void> onLoad() async {
    final tiledMap = await TiledComponent.load('loadGameUI.tmx', Vector2.all(1.0));
    tiledMap.priority = 11;
    await add(tiledMap);
    final objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>('loadGameUI');

    if (objectLayer != null) {
      buildUiFromTiled(objectLayer);
    }

    await loadSaveFilesByPage(_currentPage);
  }

  Future<void> loadSaveFilesByPage(int page) async {
    saveFiles = await saveManager.listSaveFiles();

    for (final box in _currentSaveBoxes) {
      if (box.isMounted) {
        box.removeFromParent();
      }
    }
    _currentSaveBoxes.clear();

    final startIndex = page * 6; // 6 saves per page
    final endIndex = (startIndex + 6).clamp(0, saveFiles.length);

    // If no saves to show, return early
    if (startIndex >= saveFiles.length) return;

    saveBoxSize = Vector2(
      HelloworldHellolove.virtualResolution.x * sizeRatio,
      HelloworldHellolove.virtualResolution.y * sizeRatio,
    );

    final loadGamePaddingX = HelloworldHellolove.virtualResolution.x * (1 / 25);
    final loadGamePaddingY = HelloworldHellolove.virtualResolution.y * (1 / 20);

    saveBoxPosition = Vector2(loadGamePaddingX, loadGamePaddingY);

    final innerPadding =
        (HelloworldHellolove.virtualResolution.x - ((saveBoxPosition.x * 2) + (saveBoxSize.x * 3))) / 2;

    // Reset count for positioning
    int count = 0;

    for (int i = startIndex; i < endIndex; i++) {
      final file = saveFiles[i];
      String fileName = basename(file.path);
      final loadedSave = await saveManager.loadGame(fileName);

      if (loadedSave == null) continue; // Use continue instead of return

      final saveBox = await addSaveBoxContainer(
        loadedSave.saveName,
        loadedSave.currentLocation,
        loadedSave.gameChapter,
        loadedSave.playerName,
        loadedSave.gameSavedLine,
        loadedSave.currentPoint,
      );

      final dialogueBox = await addDialogue(loadedSave.currentText);
      final characters = addCharacters(loadedSave.currentCharacters);

      for (final char in characters) {
        await saveBox.add(char);
      }

      if (loadedSave.currentText.isNotEmpty) {
        await saveBox.add(dialogueBox);
      }

      // Set position before adding
      saveBox.position = saveBoxPosition.clone();
      await add(saveBox);
      _currentSaveBoxes.add(saveBox);

      // Update position for next box (3 columns layout)
      if (count % 3 == 2) {
        // After every 3rd box (0-indexed: 2, 5, 8...)
        saveBoxPosition.x = loadGamePaddingX;
        saveBoxPosition.y += saveBoxSize.y + 100; // Fixed: use constant padding, not saveBoxPosition.y
      } else {
        saveBoxPosition.x += saveBoxSize.x + innerPadding;
      }

      count++;
    }
  }

  void nextPage() {
    final totalPages = (saveFiles.length / 6).ceil();
    if (_currentPage < totalPages - 1) {
      _currentPage += 1;
      loadSaveFilesByPage(_currentPage);
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage -= 1;
      loadSaveFilesByPage(_currentPage);
    }
  }
}
