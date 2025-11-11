import 'dart:io';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/utils/rounded_rectangle.dart';

class TappableInputTextBox extends RoundedBoxComponent
    with TapCallbacks, HasGameReference<HelloworldHellolove>, KeyboardHandler {
  String _text = '';
  final TextBoxComponent _textBox;
  final TextPaint _textStyle;
  final String _placeholder;
  String? _invalidInput;
  void Function(String)? onSubmit;
  bool isUsingKeyboard = false;

  String get text => _text;

  TappableInputTextBox({
    required super.size,
    required Vector2 super.position,
    required TextPaint textRenderer,
    String placeholder = 'Enter text...',
    this.onSubmit,
    super.priority,
  }) : _textStyle = textRenderer,
       _placeholder = placeholder,
       _textBox = TextBoxComponent(
         text: placeholder,
         textRenderer: textRenderer.copyWith((style) => style.copyWith(color: Color.fromARGB(255, 192, 144, 155))),
         size: size - Vector2(20, 10),
         position: Vector2(10, 5),
         align: Anchor.center,
       ),
       super(
         borderRadius: 15,
         borderPaint: Paint()..color = const Color.fromARGB(255, 102, 37, 52),
         borderWidth: 5,
         borderLeft: false,
         borderTop: false,
         borderRight: false,
         borderBottom: true,
       );

  @override
  Future<void> onLoad() async {
    add(_textBox);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) isUsingKeyboard = true;
    updateTextDisplay();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      game.overlays.add('TextEditor');

      // Set the current text in the game before opening overlay
      game.textToEdit = _text;

      // Set up real-time update callback
      game.onTextUpdate = (newText) {
        _text = newText;
        updateTextDisplay();
      };
    }
  }

  void updateTextDisplay() {
    if (_text.isEmpty) {
      _textBox.text = (_invalidInput ?? _placeholder);
      _invalidInput = null;
      _textBox.textRenderer = _textStyle.copyWith((style) => style.copyWith(color: Color.fromARGB(255, 161, 128, 136)));
    } else {
      _textBox.textRenderer = _textStyle;
      _textBox.text = _text;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && isUsingKeyboard) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_text.isNotEmpty) {
          _text = _text.substring(0, _text.length - 1);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (onSubmit != null) {
          onSubmit!(_text);
        }
      } else if (event.character != null &&
          event.character!.isNotEmpty &&
          event.character!.length == 1 &&
          event.character!.codeUnitAt(0) >= 32) {
        _text += event.character!;
      }

      updateTextDisplay();
      return true;
    }
    return false;
  }

  void editText(String newText) {
    _text = newText;
  }

  void editPlaceholder(String newText) {
    _invalidInput = newText;
  }
}
