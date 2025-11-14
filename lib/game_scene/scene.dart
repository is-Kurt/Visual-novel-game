import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/game_db/game_save.dart';
import 'package:helloworld_hellolove/game_db/save_manager.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/game_assets/character_data.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:helloworld_hellolove/mixin/ui_tiledmap_mixin.dart';

part 'skip_or_advance_part.dart';
part 'set_scene_part.dart';
part 'dialogue_options_container_part.dart';
part 'dialogue_container_part.dart';
part 'parse_commands_part.dart';
part 'line_scripts_part.dart';

class Scene extends World with HasGameReference<HelloworldHellolove>, TapCallbacks, KeyboardHandler, TiledUiBuilder {
  final String chapter;
  final String playerName;
  final Map<String, CharacterData> _characterSprites = {};
  SpriteComponent? _backgroundComponent;

  late final ObjectGroup? objectLayer;
  final List<ButtonComponent> _decisionButtons = [];
  late final RectangleComponent _dialogueBox;
  late final TextBoxComponent _textBox;

  static late double textSpeed;
  // --- Scripting Properties ---
  late final List<String> _scriptLines = [];
  final Map<String, int> _scenePointLineIndex = {};
  int currentLineIndex = 0; // Accesed by game save
  bool _isTyping = false;
  bool _isWaitingForDecision = false;
  String _fullText = '';
  double _timer = 0.0;
  int _charIndex = 0;

  // --- Button Properties ---
  late ButtonComponent autoButton;
  static bool isAuto = false;
  double _autoAdvanceDelay = 0.0;
  static late double advanceDelayTime;

  // late ButtonComponent menuButton;
  // late RoundedBoxComponent popUpBox;
  bool isPopUpMounted = false;

  // --- Save Game Properties ---
  late String currentLocation;
  late Map<String, CharacterData> currentCharacters;
  late int currentPoint;
  String currentText = '';
  int? savedLine;
  int? savedPoint;

  Scene(this.chapter, this.playerName, {this.savedLine, this.savedPoint});

  @override
  FutureOr<void> onLoad() async {
    // if (savedPoint != null) print(chapter + ' --- ' + savedLine.toString() + ' --- ' + (savedPoint! - 1).toString());
    currentCharacters = _characterSprites; // SAVE game property

    final tiledMap = await TiledComponent.load('sceneUI.tmx', Vector2.all(1.0));
    tiledMap.priority = 11;
    await add(tiledMap);

    objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>('sceneElements');
    if (objectLayer != null) {
      buildUiFromTiled(objectLayer!);
    }

    await addScriptLines();
    await addDialogueBox();
    await advanceScript();
    await saveGame(); // new game save
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if ((_isTyping || isAuto) && !isPopUpMounted) {
      if (_charIndex < _fullText.length) {
        _timer += dt;
        if (_timer >= textSpeed) {
          _timer = 0.0;
          _charIndex++;
          _textBox.text = _fullText.substring(0, _charIndex);
        }
      } else if (_charIndex >= _fullText.length) {
        _isTyping = false;
        if (isAuto && !_isWaitingForDecision) {
          _autoAdvanceDelay += dt;
          if (_autoAdvanceDelay >= advanceDelayTime) {
            _autoAdvanceDelay = 0;
            advanceScript();
          }
        }
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      isAutoClicked(false);
      _skipOrAdvance();
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownEvent event) {
    isAutoClicked(false);
    _skipOrAdvance();
    super.onTapDown(event);
  }

  void isAutoClicked(bool isClickedFromButton) {
    final visual = autoButton.button;

    if (visual is SpriteComponent) {
      if (isClickedFromButton) {
        isAuto = !isAuto;
        if (isAuto) {
          visual.paint.colorFilter = const ColorFilter.mode(Color(0x80000000), BlendMode.srcATop);
        } else {
          visual.paint.colorFilter = null;
        }
      } else {
        isAuto = false;
        visual.paint.colorFilter = null;
      }
    }
  }

  Future<void> saveGame() async {
    final saveManager = SaveManager();
    GameSave save = GameSave(
      saveName: playerName,
      playerName: playerName,
      gameChapter: chapter,
      gameSavedLine: currentLineIndex,
      currentLocation: currentLocation,
      currentCharacters: currentCharacters,
      currentText: currentText,
      currentPoint: currentPoint,
    );
    await saveManager.saveGame(save);
  }
}
