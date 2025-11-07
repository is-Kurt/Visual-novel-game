import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/game_assets/character_data.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:helloworld_hellolove/mixin/ui_tiledmap_mixin.dart';

part 'skip_or_advance_part.dart';
part 'set_scene_part.dart';
part 'dialogue_options_part.dart';
part 'dialogue_box_part.dart';
part 'parse_commands_part.dart';

class Scene extends World with HasGameReference<HelloworldHellolove>, TapCallbacks, KeyboardHandler, TiledUiBuilder {
  final String dialoguePath;
  final Map<String, CharacterData> _characterSprites = {};
  SpriteComponent? _backgroundComponent;

  late final ObjectGroup? objectLayer;
  final List<ButtonComponent> _decisionButtons = [];
  late final RectangleComponent _dialogueBox;
  late final TextBoxComponent _textBox;

  static const double _textSpeed = 0.03;
  // --- Scripting Properties ---
  late final List<String> _scriptLines = [];
  final Map<String, int> _scenePointLineIndex = {};
  int _currentLineIndex = 0;
  bool _isTyping = false;
  bool _isWaitingForDecision = false;
  String _fullText = '';
  double _timer = 0.0;
  int _charIndex = 0;

  Scene(this.dialoguePath);

  @override
  FutureOr<void> onLoad() async {
    final fullScriptText = await rootBundle.loadString(dialoguePath);

    final tiledMap = await TiledComponent.load('sceneUI.tmx', Vector2.all(1.0));

    tiledMap.priority = 11;

    await add(tiledMap);

    objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>('sceneElements');
    if (objectLayer != null) {
      buildUiFromTiled(objectLayer!);
    }

    final rawLines = fullScriptText.split('\n');
    String multiLineBuffer = '';
    final RegExp scenePointRegex = RegExp(r'^SCENE\{\s*POINT:\s*([^\s,}]+)\s*,?\s*');
    final RegExp pointRemover = RegExp(r'POINT:\s*[^\s,}]+\s*,?\s*');
    int currentScriptIndex = 0;

    for (final line in rawLines) {
      String trimmedLine = line.trim();

      if (multiLineBuffer.isNotEmpty) {
        multiLineBuffer += ' $trimmedLine';
        if (trimmedLine.endsWith('"') || trimmedLine.endsWith('}')) {
          currentScriptIndex++;
          _scriptLines.add(multiLineBuffer);
          multiLineBuffer = '';
        }
      } else if (trimmedLine.startsWith('{') && trimmedLine.contains('}:')) {
        if (trimmedLine.endsWith('"')) {
          currentScriptIndex++;
          print(trimmedLine);
          _scriptLines.add(trimmedLine);
        } else {
          multiLineBuffer = trimmedLine;
        }
      } else if (trimmedLine.startsWith('SCENE{')) {
        final sceneMatch = scenePointRegex.firstMatch(trimmedLine);
        if (sceneMatch != null) {
          final scenePoint = sceneMatch.group(1)!;
          _scenePointLineIndex[scenePoint] = currentScriptIndex;
          trimmedLine = line.replaceFirst(pointRemover, '');
          // print(trimmedLine);
          // print(_scenePointLineIndex);
        }
        currentScriptIndex++;
        _scriptLines.add(trimmedLine);
      } else if (trimmedLine.startsWith('DECISION{')) {
        if (trimmedLine.endsWith('}')) {
          currentScriptIndex++;
          _scriptLines.add(trimmedLine);
        } else {
          multiLineBuffer = trimmedLine;
        }
      } else if (trimmedLine.startsWith('JUMP{')) {
        currentScriptIndex++;
        _scriptLines.add(trimmedLine);
      } else if (trimmedLine.startsWith('CLEAR')) {
        currentScriptIndex++;
        _scriptLines.add(trimmedLine);
      }
    }
    // print(_scenePointLineIndex);
    // print('script lines' + _scriptLines.length.toString());
    // for (var line in _scriptLines) {
    //   print(line);
    // }
    // print('script ends');
    await addDialogueBox();

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

  Future<void> _parseLine(String line) async {
    // --- Check for SCENE command ---
    if (await scene(line)) return;

    // --- Check for DECISION command ---
    if (decision(line)) return;

    // --- Check for DIALOGUE command ---
    if (dialogue(line)) return;

    // --- CHECK for JUMP COMMAND ---
    if (jump(line)) return;

    // --- CHECK for CLEAR COMMAND ---
    if (clear(line)) return;
    // --- Handle other commands or errors ---
    if (kDebugMode) {
      print('WARNING: Unknown script line: $line');
    }

    await _advanceScript();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _skipOrAdvance();
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _skipOrAdvance();
    super.onTapDown(event);
  }
}
