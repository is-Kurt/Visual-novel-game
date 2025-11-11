part of 'load_game_screen.dart';

extension SaveGameContainerPart on LoadGameScreen {
  Future<SpriteButtonComponent> addSaveBoxContainer(
    String saveName,
    String location,
    String chapter,
    String playerName,
    int savedLine,
    int currentPoint,
  ) async {
    final saveBoxSprite = await Sprite.load('locations/$location.webp');
    saveBoxSprite.paint.filterQuality = FilterQuality.high;

    final saveBox = SpriteButtonComponent(
      button: saveBoxSprite,
      size: saveBoxSize,
      position: saveBoxPosition,
      onPressed: () {
        game.goToChapter(chapter, playerName, savedLine: savedLine, currentPoint: currentPoint);
      },
    );

    // NEW: Define the size for the name box first
    final nameBoxSize = Vector2(saveBoxSize.x * (3 / 4), saveBoxSize.y * (1 / 5));
    final nameBoxHeight = nameBoxSize.y;

    final saveNameBox = RoundedBoxComponent(
      size: nameBoxSize, // Use the var
      position: Vector2((saveBoxSize.x / 2), saveBoxSize.y - 2.5),
      fillPaint: Paint()..color = const Color.fromARGB(240, 180, 87, 109),
      borderPaint: Paint()..color = const Color.fromARGB(250, 242, 195, 205),
      borderWidth: 5.0,
      bottomLeftRadius: 20.0,
      bottomRightRadius: 20.0,
      anchor: Anchor.topCenter,
      borderTop: false,
      priority: 1,
    );

    final saveText = TextBoxComponent(
      text: saveName,
      textRenderer: TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 24.0, color: Color(0xFFF2C3CD)),
      ),
      align: Anchor.center,
      position: Vector2.all(0),
      size: nameBoxSize, // Use the var
    );

    final deleteButtonSize = nameBoxHeight * 0.7;
    final deleteButtonPadding = nameBoxHeight * 0.2;

    final deleteShape = RoundedBoxComponent(
      size: Vector2.all(deleteButtonSize),
      fillPaint: Paint()..color = const Color.fromARGB(255, 204, 104, 128),
      borderRadius: 10,
      boxShadow: BoxShadow(color: Color.fromARGB(90, 0, 0, 0), blurRadius: 1.0, offset: Offset(0, 4)),
    );

    final deleteIcon = TextComponent(
      text: 'X',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'Knewave', // Match your other font
          fontSize: 32.0,
          color: Color(0xFFF2C3CD), // Match your text color
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(deleteButtonSize / 2, 0),
    );

    deleteShape.add(deleteIcon);

    final deleteButton = ButtonComponent(
      button: deleteShape,
      anchor: Anchor.topLeft,
      position: Vector2(deleteButtonPadding, 7),
      onPressed: () {
        add(
          openPopUp('Are you sure you want to delete this save file?', {
            'Yes': () async {
              saveManager.deleteSave(saveName);
              await loadSaveFilesByPage(_currentPage);
            },
            'No': () {},
          }),
        );
      },
      priority: 2,
    );

    saveNameBox.add(saveText);
    saveNameBox.add(deleteButton); // NEW: Add the delete button
    saveBox.add(saveNameBox);
    return saveBox;
  }
}
