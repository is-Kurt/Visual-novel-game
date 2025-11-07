part of 'scene.dart';

extension SkipOrAdvanceLogic on Scene {
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
    _characterSprites[speaker]!.greydOut(false);
    final fullName = _characterSprites[speaker]!.name;

    _fullText = '$fullName: $text';
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
}
