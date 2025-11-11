part of 'load_game_screen.dart';

extension CharactersPart on LoadGameScreen {
  List<CharacterData> addCharacters(Map<String, CharacterData> characters) {
    List<CharacterData> allCharacters = [];
    double rightOffset = 0.0;
    double leftOffset = 0.0;

    double centerOffset = 0.0;
    double container = 1000 * sizeRatio;
    int divider = characters.length;

    double offset = container / divider;
    double rightAnchor = container + ((saveBoxSize.x - (container)) / 2) - (offset / 2);
    double leftAnchor = saveBoxSize.x - rightAnchor;
    centerOffset = offset * (divider - 1);

    for (final char in characters.values) {
      char.size = char.size * sizeRatio;

      double xPosition = 0.0;
      double yPosition = saveBoxSize.y - char.size.y;
      if (char.positionAt == PositionAt.center) {
        char.position = Vector2(
          saveBoxSize.x / 2 +
              (char.facingAt == FacingAt.right
                  ? (rightAnchor - container) + (container / 2) - centerOffset
                  : (leftAnchor - container) + (container / 4) - centerOffset),
          yPosition,
        );
        centerOffset -= offset;
      } else {
        if (char.positionAt == PositionAt.left) {
          char.facingAt == FacingAt.right
              ? xPosition = (800 * sizeRatio) + leftOffset
              : xPosition = (-100 * sizeRatio) + leftOffset;
          leftOffset += 400 * sizeRatio;
        } else if (char.positionAt == PositionAt.right) {
          char.facingAt == FacingAt.left
              ? xPosition = (1120 * sizeRatio) - rightOffset
              : xPosition = (2020 * sizeRatio) + rightOffset;
          rightOffset += 400 * sizeRatio;
        }
        char.position = Vector2(xPosition, yPosition);
      }
      char.priority = 1;

      allCharacters.add(char);
    }
    return allCharacters;
  }
}
