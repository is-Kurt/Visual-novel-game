part of 'scene.dart';

extension ParseCommandsPart on Scene {
  Future<void> parseLine(String line) async {
    // --- Check for SCENE command ---
    if (await _scene(line)) return;

    // --- Check for DECISION command ---
    if (await _decision(line)) return;

    // --- Check for DIALOGUE command ---
    if (_dialogue(line)) return;

    // --- CHECK for JUMP COMMAND ---
    if (_jump(line)) return;

    // --- CHECK for CLEAR COMMAND ---
    if (_clear(line)) return;

    // --- CHECK gor CHAPTER COMMAND ---
    if (_chapter(line)) return;

    // --- Handle other commands or errors ---
    if (kDebugMode) {
      print('WARNING: Unknown script line: $line');
    }
    await advanceScript();
  }

  Future<bool> _scene(String line) async {
    if (line == 'SCENE{}') {
      await advanceScript();
      return true;
    }

    final RegExp sceneRegex = RegExp(r'SCENE\{\s*LOCATION:\s*([^,]+),\s*CHARACTERS:\s*\[(.*)\]\s*\}$');
    final sceneMatch = sceneRegex.firstMatch(line.trim());

    if (sceneMatch != null) {
      final String locationName = sceneMatch.group(1)!.trim();
      final String charactersString = sceneMatch.group(2)!.trim();

      currentLocation = locationName; // SAVE game property
      currentPoint = currentLineIndex; // Save game property

      final List<(String, CharacterData)> characters = _parseCharacters(charactersString);

      await _setScene(locationName, characters);

      await advanceScript();
      return true;
    }
    return false;
  }

  Future<bool> _decision(String line) async {
    final RegExp decisionRegex = RegExp(r'^DECISION\{(.*)\}$');
    final decisionMatch = decisionRegex.firstMatch(line.trim());

    if (decisionMatch != null) {
      // Add decision event audio
      if (game.playSounds) {
        game.fadeAudio(FlameAudio.bgm.audioPlayer, 0.0, 0.5, () {
          FlameAudio.bgm.pause();
        });

        game.minigameAudioPlayer = await FlameAudio.loop('Minigame OST.wav', volume: 0.0);

        if (game.minigameAudioPlayer != null) {
          game.fadeAudio(game.minigameAudioPlayer!, game.sfxVolume * game.masterVolume, 0.5);
        }
      }

      final String optionsStr = decisionMatch.group(1)!; // "a:Yes, b:No, ..."
      final List<String> options = [];
      final List<String> scenesPoints = [];
      // Parse the options
      final pairs = optionsStr.split(',');
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          options.add(parts[1].trim()); // Add "Yes", "No", etc. to the list
          scenesPoints.add(parts[0].trim());
        }
      }

      showDecisions(options, scenesPoints);
      return true;
    }
    return false;
  }

  bool _dialogue(String line) {
    final RegExp dialogueRegex = RegExp(r'^\{(.*)\}:\s*\"([\s\S]*)\"$');
    final dialogueMatch = dialogueRegex.firstMatch(line.trim());

    if (dialogueMatch != null) {
      final String allCommandsStr = dialogueMatch.group(1)!;
      final String text = dialogueMatch.group(2)!;
      final commandList = allCommandsStr.split(',');

      String speaker = '';
      String state = '';

      for (final cmdStr in commandList) {
        final parts = cmdStr.split(':');
        if (parts.length == 2) {
          final command = parts[0].trim().toUpperCase();
          final value = parts[1].trim();

          if (command == 'SAY') {
            speaker = value;
          } else if (command == 'STATE') {
            state = value;
          }
        }
      }

      if (speaker.isNotEmpty) {
        if (state.isNotEmpty) {
          handleState(speaker, state);
        }
        greyAllChar();
        _startTyping(speaker, text);
      } else {
        throw ('WARNING: Dialogue line has no SAY command: $line');
      }
      return true;
    }
    return false;
  }

  bool _jump(String line) {
    final RegExp jumpRegex = RegExp(r'JUMP\(\s*([^\s\)]+)\s*\);');

    final jumpMatch = jumpRegex.firstMatch(line.trim());

    if (jumpMatch != null) {
      final String scene = jumpMatch.group(1)!.trim();
      if (_scenePointLineIndex[scene] != null) {
        currentLineIndex = _scenePointLineIndex[scene]!;
      }

      return true;
    }
    return false;
  }

  bool _clear(String line) {
    currentText = ''; // SAVE game property

    if (line.toUpperCase() == 'CLEAR') {
      clearScene();
      return true;
    }
    return false;
  }

  bool _chapter(String line) {
    final RegExp chapterRegex = RegExp(r'CHAPTER\{\s*([^\s\}]+)\s*\}');
    final chapterMatch = chapterRegex.firstMatch(line.trim());

    if (chapterMatch != null) {
      final String path = chapterMatch.group(1)!;
      game.goToChapter(path, playerName);
      return true;
    }
    return true;
  }

  void handleState(String charName, String stateName) {
    final charComponent = _characterSprites[charName];
    if (charComponent != null) {
      charComponent.setState(stateName);
    } else {
      throw ('ERROR: Sprite for $charName not found on screen');
    }
  }

  void clearScene() {
    for (final char in _characterSprites.values) {
      char.greydOut(false);
      char.priority = 1;
    }
    if (_dialogueBox.isMounted) {
      remove(_dialogueBox);
    }
  }

  void greyAllChar() {
    for (final char in _characterSprites.values) {
      char.greydOut(true);
      char.priority = 1;
    }
  }
}
