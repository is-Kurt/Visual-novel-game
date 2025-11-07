part of 'scene.dart';

extension ParseCommandsPart on Scene {
  Future<bool> scene(String line) async {
    final RegExp sceneRegex = RegExp(r'SCENE\{\s*LOCATION:\s*([^,]+),\s*CHARACTERS:\s*\[(.*)\]\s*\}$');
    final sceneMatch = sceneRegex.firstMatch(line.trim());

    if (sceneMatch != null) {
      final String locationName = sceneMatch.group(1)!.trim();
      final String charactersString = sceneMatch.group(2)!.trim();

      final List<(String, CharacterData)> characters = _parseCharacters(charactersString);

      await _setScene(locationName, characters);

      await _advanceScript();
      return true;
    }
    return false;
  }

  bool decision(String line) {
    final RegExp decisionRegex = RegExp(r'^DECISION\{(.*)\}$');
    final decisionMatch = decisionRegex.firstMatch(line.trim());

    if (decisionMatch != null) {
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

      _showDecisions(options, scenesPoints);
      return true;
    }
    return false;
  }

  bool dialogue(String line) {
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
        print(parts);
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

  bool jump(String line) {
    final RegExp jumpRegex = RegExp(r'JUMP\{\s*([^\s\}]+)\s*\}');
    final jumpMatch = jumpRegex.firstMatch(line.trim());
    if (jumpMatch != null) {
      final String scene = jumpMatch.group(1)!.trim();
      scene.toUpperCase() == 'END' ? _currentLineIndex = _scenePointLineIndex[scene]! : _currentLineIndex = _scenePointLineIndex[scene]!;
      return true;
    }
    return false;
  }

  bool clear(String line) {
    if (line.toUpperCase() == 'CLEAR') {
      clearScene();
      return true;
    }
    return false;
  }

  void handleState(String charName, String stateName) {
    // if (kDebugMode) {
    //   print('SCRIPT: Character $charName changes to $stateName');
    // }

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
