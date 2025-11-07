part of 'scene.dart';

extension SetSceneLogic on Scene {
  /// Clears old scene and loads new background and characters
  Future<void> _setScene(String locationName, List<(String, CharacterData)> characters) async {
    if (_backgroundComponent != null) remove(_backgroundComponent!);
    for (final charSprite in _characterSprites.values) {
      remove(charSprite);
    }
    _characterSprites.clear();

    final backgroundSprite = await Sprite.load('locations/$locationName.webp');
    _backgroundComponent = SpriteComponent()
      ..sprite = backgroundSprite
      ..size = HelloworldHellolove.virtualResolution
      ..priority = -1;
    await add(_backgroundComponent!);

    await _addCharacters(characters);
  }

  Future<void> _addCharacters(List<(String, CharacterData)> characters) async {
    if (characters.isNotEmpty) {
      double rightOffset = 0.0;
      double leftOffset = 0.0;

      double centerOffset = 0.0;
      double container = 1000;
      double divider = 0.0;
      for (final (_, char) in characters) {
        if (char.positionAt == PositionAt.center) {
          divider += 1;
        }
      }

      double offset = container / divider;
      double rightAnchor = container + ((HelloworldHellolove.virtualResolution.x - (container)) / 2) - (offset / 2);
      double leftAnchor = HelloworldHellolove.virtualResolution.x - rightAnchor;
      centerOffset = offset * (divider - 1);

      for (final (name, char) in characters) {
        double xPosition = 0.0;
        double yPosition = HelloworldHellolove.virtualResolution.y - char.size.y;
        if (char.positionAt == PositionAt.center) {
          char.position = Vector2(
            HelloworldHellolove.virtualResolution.x / 2 +
                (char.facingAt == FacingAt.right
                    ? (rightAnchor - container) + (container / 2) - centerOffset
                    : (leftAnchor - container) + (container / 4) - centerOffset),
            yPosition,
          );
          centerOffset -= offset;
        } else {
          if (char.positionAt == PositionAt.left) {
            char.facingAt == FacingAt.right ? xPosition = 800 + leftOffset : xPosition = -100 + leftOffset;
            leftOffset += 400;
          } else if (char.positionAt == PositionAt.right) {
            char.facingAt == FacingAt.left ? xPosition = 1120 - rightOffset : xPosition = 2020 + rightOffset;
            rightOffset += 400;
          }
          char.position = Vector2(xPosition, yPosition);
        }
        char.priority = 1;

        await add(char);
        _characterSprites[name] = char;
      }
    }
  }

  List<(String, CharacterData)> _parseCharacters(String charStr) {
    final List<(String, CharacterData)> characters = [];
    // This RegExp finds "left(...)", "right(...)", or "center(...)"
    final RegExp positionRegex = RegExp(r'(left|right|center)\(([^)]+)\)');

    for (final match in positionRegex.allMatches(charStr)) {
      final String positionStr = match.group(1)!; // "left", "right", or "center"
      final String namesStr = match.group(2)!; // "Habane, Akagi"

      final names = namesStr.split(',').map((e) => e.trim()).toList();

      late PositionAt pos;
      late FacingAt face;

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
        // "Akagi.happy" -> ['Akagi', 'happy']
        final parts = name.split('.');
        final charName = parts[0];
        // --- REFACTORED LOGIC ---
        // Set defaults
        String state = 'default';
        FacingAt finalFace = face; // Use the position-based default

        if (parts.length == 2) {
          // Could be "Akagi.happy" or "Akagi.r"
          if (parts[1] == 'l' || parts[1] == 'r') {
            finalFace = parts[1] == 'r' ? FacingAt.right : FacingAt.left;
          } else {
            state = parts[1];
          }
        } else if (parts.length == 3) {
          // "Akagi.happy.r"
          state = parts[1];
          finalFace = parts[2] == 'r' ? FacingAt.right : FacingAt.left;
        }

        final CharacterData char = characterFactory(charName);
        char.positionAt = pos;
        char.facingAt = finalFace;
        char.state = state;
        characters.add((charName, char));
      }
    }
    return characters;
  }
}
