part of 'scene.dart';

extension SkipOrAdvanceLogic on Scene {
  Future<void> advanceScript() async {
    if (currentLineIndex >= _scriptLines.length) {
      game.goToHomeScreen();
      return;
    }

    if (savedLine != null && savedPoint == null) {
      currentLineIndex = savedLine! - 1;
      savedLine = null;
    }
    if (savedPoint != null) {
      currentLineIndex = savedPoint! - 1;
      savedPoint = null;
    }

    final line = _scriptLines[currentLineIndex].trim();

    currentLineIndex++;
    await parseLine(line);
  }

  Future<void> _skipOrAdvance() async {
    if (_isWaitingForDecision) return;

    if (_isTyping) {
      _skipTyping();
    } else {
      await advanceScript();
    }
  }

  void _skipTyping() {
    _charIndex = _fullText.length;
    _textBox.text = _fullText;
    _isTyping = false;
  }

  void _startTyping(String speaker, String text) {
    late String finalText;
    String modifiedText = text.replaceAll("PLAYER", playerName);

    if (speaker == 'PLAYER') {
      finalText = '$playerName: $modifiedText';
    } else if (speaker == 'NARRATOR') {
      finalText = modifiedText;
    } else {
      _characterSprites[speaker]!.greydOut(false);

      final fullName = _characterSprites[speaker]!.name;
      finalText = '$fullName: $modifiedText';
    }

    _fullText = finalText;
    currentText = _fullText; // SAVE game property
    _charIndex = 0;
    _timer = 0.0;
    _textBox.text = '';
    _isTyping = true;
    if (!_dialogueBox.isMounted) add(_dialogueBox);
  }
}
