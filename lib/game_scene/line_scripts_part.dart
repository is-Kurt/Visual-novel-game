part of 'scene.dart';

extension LineScirptsPart on Scene {
  Future<void> addScriptLines() async {
    final fullScriptText = await rootBundle.loadString('assets/chapters/$chapter.txt');
    final rawLines = fullScriptText.split('\n');
    final RegExp scenePointRegex = RegExp(r'^SCENE\{\s*POINT:\s*([^\s,}]+)\s*,?\s*');
    final RegExp pointRemover = RegExp(r'POINT:\s*[^\s,}]+\s*,?\s*');

    String multiLineBuffer = '';
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
      } else if (trimmedLine.startsWith('CHAPTER{')) {
        currentScriptIndex++;
        _scriptLines.add(trimmedLine);
      }
    }
  }
}
