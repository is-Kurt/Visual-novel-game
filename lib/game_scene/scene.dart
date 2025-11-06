import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/game_scene/dialogue_box.dart';
import 'package:helloworld_hellolove/game_scene/ui_helper.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/sets/characters.dart';

class Scene extends World
    with
        HasGameReference<HelloworldHellolove>,
        TapCallbacks,
        KeyboardHandler,
        UiHelpers {
  final String dialoguePath;
  final Map<String, CharacterData> _characterSprites = {};
  SpriteComponent? _backgroundComponent;

  late List<ButtonComponent> _decisionButtons;
  late final RectangleComponent _dialogueBox;
  late final TextBoxComponent _textBox;
  // --- Scripting Properties ---
  late List<String> _scriptLines;
  int _currentLineIndex = 0;
  bool _isTyping = false;
  bool _isWaitingForDecision = false;
  String _fullText = '';
  double _timer = 0.0;
  int _charIndex = 0;
  static const double _textSpeed = 0.03;
  String? _currentSpeaker;

  Scene(this.dialoguePath);

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    // Loads the script
    final fullScriptText = await rootBundle.loadString(dialoguePath);

    _scriptLines = [];
    final rawLines = fullScriptText.split('\n');
    String multiLineBuffer = '';

    for (final line in rawLines) {
      final trimmedLine = line.trim();

      if (multiLineBuffer.isNotEmpty) {
        multiLineBuffer += ' $trimmedLine';
        if (trimmedLine.endsWith('"')) {
          _scriptLines.add(multiLineBuffer);
          multiLineBuffer = '';
        }
      } else if (trimmedLine.startsWith('{') && trimmedLine.contains(':"')) {
        if (trimmedLine.endsWith('"')) {
          _scriptLines.add(trimmedLine);
        } else {
          multiLineBuffer = trimmedLine;
        }
      } else if (trimmedLine.startsWith('SCENE{')) {
        _scriptLines.add(trimmedLine);
      } else if (trimmedLine.startsWith('DECISION{')) {
        _scriptLines.add(trimmedLine);
      }
    }
    // print('script lines' + _scriptLines.length.toString());
    // for (var line in _scriptLines) {
    //   print(line);
    // }

    // Add permanent UI elements
    await addUIElements('sceneUI', 'sceneElements', decisionAmount: 4);
    final (dialogueBox, textBox) = await addDialogueBox();
    _dialogueBox = dialogueBox;
    _textBox = textBox;
    _dialogueBox.add(textBox);

    // Start the script. The script will load the first background/characters
    await _advanceScript();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isTyping) {
      if (_charIndex < _fullText.length) {
        _timer += dt;
        if (_timer >= _textSpeed) {
          _timer = 0.0;
          _charIndex++;
          _textBox.text = _fullText.substring(0, _charIndex);
        }
      } else if (_charIndex >= _fullText.length) {
        _isTyping = false;
      }
    }
  }

  Future<void> _skipOrAdvance() async {
    if (_isWaitingForDecision) return;

    if (_isTyping) {
      _skipTyping();
    } else {
      await _advanceScript();
    }
  }

  void _skipTyping() {
    _charIndex = _fullText.length;
    _textBox.text = _fullText;
    _isTyping = false;
  }

  void _startTyping(String speaker, String text) {
    _currentSpeaker = speaker;
    _characterSprites[_currentSpeaker]!.greydOut(false);

    _fullText = '$speaker: $text';
    _charIndex = 0;
    _timer = 0.0;
    _textBox.text = '';
    _isTyping = true;
    if (!_dialogueBox.isMounted) add(_dialogueBox);
  }

  Future<void> _advanceScript() async {
    if (_currentLineIndex >= _scriptLines.length) {
      game.goToNextScene();
      return;
    }

    final line = _scriptLines[_currentLineIndex].trim();
    _currentLineIndex++;

    await _parseLine(line);
  }

  Future<void> _parseLine(String line) async {
    if (line.isEmpty || line.startsWith('//')) {
      await _advanceScript();
      return;
    }

    // --- Check for SCENE command ---
    final RegExp sceneRegex = RegExp(
      r'^SCENE{LOCATION:\s*([^,]+),\s*CHARACTERS:\s*\[(.*)\]}$',
    );
    final sceneMatch = sceneRegex.firstMatch(line.trim());
    // print(sceneMatch);

    if (sceneMatch != null) {
      final String locationName = sceneMatch.group(1)!.trim();
      final String charactersString = sceneMatch.group(2)!.trim();
      // print(locationName + ' -- ' + charactersString);

      final List<CharacterData> characters = _parseCharacters(charactersString);

      await _setScene(locationName, characters);

      await _advanceScript();
      return;
    }

    // --- Check for DECISION command ---
    final RegExp decisionRegex = RegExp(r'^DECISION\{(.*)\}$');
    final decisionMatch = decisionRegex.firstMatch(line.trim());

    if (decisionMatch != null) {
      final String optionsStr = decisionMatch.group(1)!; // "a:Yes, b:No, ..."
      final List<String> options = [];
      final List<String> scenes = [];

      // Parse the options
      final pairs = optionsStr.split(',');
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          options.add(parts[1].trim()); // Add "Yes", "No", etc. to the list
          scenes.add(parts[0].trim());
        }
      }

      _showDecision(options, scenes);
      return;
    }

    // --- Check for DIALOGUE command ---
    final RegExp dialogueRegex = RegExp(r'^\{(.*)\}:\"([\s\S]*)\"$');
    final dialogueMatch = dialogueRegex.firstMatch(line.trim());

    if (dialogueMatch != null) {
      final String allCommandsStr = dialogueMatch.group(1)!;
      final String text = dialogueMatch.group(2)!;
      final commandList = allCommandsStr.split(',');
      print(allCommandsStr + ' --- ' + text);

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
          _handleEmote(speaker, state);
        }
        if (_characterSprites.containsKey(_currentSpeaker)) {
          _characterSprites[_currentSpeaker]!.greydOut(true);
        }
        _startTyping(speaker, text);
      } else {
        if (kDebugMode) {
          print('WARNING: Dialogue line has no SAY command: $line');
        }
        await _advanceScript();
      }
      return;
    }

    // --- Handle other commands or errors ---
    if (kDebugMode) {
      print('WARNING: Unknown script line: $line');
    }
    await _advanceScript();
  }

  void _showDecision(List<String> options, List<String> scenes) async {
    _isWaitingForDecision = true;
    _decisionButtons = await addDecisionElement(
      options,
      scenes,
      _handleDecision,
    );
  }

  void _handleDecision(String sceneName) {
    _isWaitingForDecision = false;

    for (final button in _decisionButtons) {
      remove(button);
    }
    _decisionButtons.clear();

    if (kDebugMode) {
      print("Decision made: Go to scene '$sceneName'");
    }

    _advanceScript();
  }

  /// --- Parses the character definition string ---
  List<CharacterData> _parseCharacters(String charStr) {
    final List<CharacterData> characters = [];
    // This RegExp finds "left(...)", "right(...)", or "center(...)"
    final RegExp positionRegex = RegExp(r'(left|right|center)\(([^)]+)\)');

    for (final match in positionRegex.allMatches(charStr)) {
      final String positionStr = match.group(
        1,
      )!; // "left", "right", or "center"
      final String namesStr = match.group(2)!; // "Habane, Akagi"
      // print(positionStr + ' -- ' + namesStr);

      final names = namesStr.split(',').map((e) => e.trim()).toList();
      // print(names);

      PositionAt pos;
      FacingAt face;

      // Set position and facing direction based on the command
      switch (positionStr) {
        case 'left':
          pos = PositionAt.left;
          face = FacingAt.right; // Characters on the left face right
          break;
        case 'right':
          pos = PositionAt.right;
          face = FacingAt.left; // Characters on the right face left
          break;
        case 'center':
        default:
          pos = PositionAt.center;
          face = FacingAt.right; // Default center facing
          break;
      }

      for (final name in names) {
        final String fullName = name;
        final CharacterData char = characterFactory(fullName);
        char.positionAt = pos;
        char.facingAt = face;
        char.greydOut(true);
        characters.add(char);
      }
    }
    return characters;
  }

  /// Clears old scene and loads new background and characters
  Future<void> _setScene(
    String locationName,
    List<CharacterData> characters,
  ) async {
    if (_backgroundComponent != null) remove(_backgroundComponent!);
    for (final charSprite in _characterSprites.values) {
      remove(charSprite);
    }
    _characterSprites.clear();

    final backgroundSprite = await Sprite.load('locations/$locationName.png');
    _backgroundComponent = SpriteComponent()
      ..sprite = backgroundSprite
      ..size = HelloworldHellolove.virtualResolution
      ..priority = -1;
    await add(_backgroundComponent!);

    await _addCharacters(characters);
  }

  void _handleEmote(String charName, String stateName) {
    // if (kDebugMode) {
    //   print('SCRIPT: Character $charName changes to $stateName');
    // }

    final charComponent = _characterSprites[charName];
    if (charComponent != null) {
      charComponent.setState(stateName);
    } else {
      if (kDebugMode) {
        print('ERROR: Sprite for $charName not found on screen');
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _skipOrAdvance(); // Calls async version
    super.onTapDown(event);
  }

  Future<void> _addCharacters(List<CharacterData>? characters) async {
    if (characters != null) {
      double rightOffset = 0.0;
      double leftOffset = 0.0;

      for (final character in characters) {
        double xPosition = 0.0;
        double yPosition =
            HelloworldHellolove.virtualResolution.y - character.size.y;

        if (character.positionAt == PositionAt.center) {
          character.position = Vector2(
            HelloworldHellolove.virtualResolution.x / 2 +
                (character.facingAt == FacingAt.right
                    ? (character.size.x / 2)
                    : -(character.size.x / 2)),
            yPosition,
          );
        } else {
          if (character.facingAt == FacingAt.right) {
            xPosition = 800 + leftOffset;
            leftOffset += 400;
          } else {
            xPosition = 1120 - rightOffset;
            rightOffset += 400;
          }
          character.position = Vector2(xPosition, yPosition);
        }
        character.priority = 1;

        await add(character);
        _characterSprites[character.name] = character;
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _skipOrAdvance(); // Calls async version
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
