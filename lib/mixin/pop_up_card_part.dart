part of 'ui_tiledmap_mixin.dart';

extension PopUpCardPart on TiledUiBuilder {
  ButtonComponent openPopUp(
    String title,
    Map<String, VoidCallback> buttons, {
    bool exitOnBackgroundClick = true,
    VoidCallback? onRemovePopUp,
  }) {
    late ButtonComponent popUpBoxWithScrim;

    popUpBoxWithScrim = ButtonComponent(
      button: RectangleComponent(
        size: HelloworldHellolove.virtualResolution,
        paint: Paint()..color = const Color(0x80000000),
      ),
      size: HelloworldHellolove.virtualResolution,
      onPressed: () => {
        if (exitOnBackgroundClick) popUpBoxWithScrim.removeFromParent(),
        if (onRemovePopUp != null) onRemovePopUp(),
      },
      priority: 11,
    );

    Vector2 boxSize = Vector2(1000, 500);
    final boxPaint = Paint()..color = const Color.fromARGB(240, 180, 87, 109);
    final borderPaint = Paint()..color = const Color.fromARGB(250, 242, 195, 205);

    final popUpBox = RoundedBoxComponent(
      size: boxSize,
      fillPaint: boxPaint,
      borderPaint: borderPaint,
      borderRadius: 20,
      borderWidth: 5,
      priority: 20,
    );

    // --- Text Box (Title) ---
    final textStyle = TextPaint(
      style: const TextStyle(fontFamily: 'Knewave', fontSize: 48.0, color: Color(0xFFF2C3CD)),
    ); // Changed to black for contrast
    const double outerPadding = 100.0; // Padding for left/right edges
    const double innerPadding = 200.0; // Padding between buttons
    const double topPadding = 0.0;

    final textBox = TextBoxComponent(
      text: title,
      textRenderer: textStyle,
      size: Vector2(boxSize.x - (outerPadding * 2), boxSize.y * (2 / 3)),
      position: Vector2(outerPadding, 0),
      priority: 1,
      align: Anchor.center,
    );
    popUpBox.add(textBox);

    final buttonFillPaint = Paint()..color = const Color(0xFFF2C3CD);
    // final buttonBorderPaint = Paint()..color = const Color(0xFFB8536C);

    final int numButtons = buttons.length;
    if (numButtons == 0) {
      popUpBoxWithScrim.add(popUpBox);
      return (popUpBoxWithScrim);
    }

    // 1. Calculate total horizontal space used by padding
    final double totalPadding = (outerPadding * 2) + (innerPadding * (numButtons - 1));

    // 2. Calculate the width available for all buttons
    final double availableWidth = boxSize.x - totalPadding;

    // 3. Calculate the width of a single button
    final double buttonWidth = availableWidth / numButtons;
    final double buttonHeight = boxSize.y * (1 / 6);
    final buttonSize = Vector2(buttonWidth, buttonHeight);

    // 4. Get the Y position (same for all buttons)
    final double yPos = (boxSize.y * (2 / 3)) + topPadding;

    // 5. Loop and create each button
    int i = 0;
    for (final entry in buttons.entries) {
      final String label = entry.key;
      final VoidCallback onPressed = entry.value;

      // 6. Calculate the X position for *this* button
      final double xPos = outerPadding + (i * (buttonWidth + innerPadding));

      // 7. Create button shape
      final buttonShape = RoundedBoxComponent(
        size: buttonSize,
        fillPaint: buttonFillPaint,
        borderRadius: 50,
        boxShadow: BoxShadow(
          color: Color.fromARGB(90, 0, 0, 0), // Black with 50% opacity
          blurRadius: 1.0,
          offset: Offset(0, 8), // 4 pixels right, 4 pixels down
        ),
      );

      // 8. Create and add the text to the button
      final buttonTextStyle = TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 32.0, color: Color(0xFF8C4B5A)),
      );
      final buttonTextBox = TextBoxComponent(
        text: label,
        textRenderer: buttonTextStyle,
        size: buttonSize,
        align: Anchor.center,
      );
      buttonShape.add(buttonTextBox);

      final button = ButtonComponent(
        size: buttonSize,
        position: Vector2(xPos, yPos),
        button: buttonShape,
        onPressed: () {
          onPressed();
          popUpBoxWithScrim.removeFromParent();
        },
      );

      popUpBox.add(button);
      i++;
    }

    final settingsWrapper = ButtonComponent(
      button: popUpBox,
      position: Vector2(
        (HelloworldHellolove.virtualResolution.x / 2) - (boxSize.x / 2),
        (HelloworldHellolove.virtualResolution.y / 2) - (boxSize.y / 2),
      ),
      priority: 12,
      onPressed: () {},
    );

    popUpBoxWithScrim.add(settingsWrapper);

    return popUpBoxWithScrim;
  }

  // ---------------------------------------------------------------------------------------
  ButtonComponent openTextInputPopUp(
    String title,
    Map<String, void Function(String)?> buttons, {
    bool exitOnBackgroundClick = true,
    VoidCallback? onRemovePopUp,
  }) {
    late ButtonComponent popUpBoxWithScrim;

    popUpBoxWithScrim = ButtonComponent(
      button: RectangleComponent(
        size: HelloworldHellolove.virtualResolution,
        paint: Paint()..color = const Color(0x80000000),
      ),
      size: HelloworldHellolove.virtualResolution,
      onPressed: () => {
        if (exitOnBackgroundClick) popUpBoxWithScrim.removeFromParent(),
        if (onRemovePopUp != null) onRemovePopUp(),
      },
      priority: 11,
    );

    Vector2 boxSize = Vector2(1000, 500);
    final boxPaint = Paint()..color = const Color.fromARGB(240, 180, 87, 109);
    final borderPaint = Paint()..color = const Color.fromARGB(250, 242, 195, 205);

    final popUpBox = RoundedBoxComponent(
      size: boxSize,
      fillPaint: boxPaint,
      borderPaint: borderPaint,
      borderRadius: 20,
      borderWidth: 5,
      priority: 20,
    );

    // --- Text Box (Title) ---
    final textStyle = TextPaint(
      style: const TextStyle(fontFamily: 'Knewave', fontSize: 48.0, color: Color.fromARGB(255, 245, 227, 231)),
    );
    const double outerPadding = 100.0;
    const double topPadding = 20.0;
    const double buttonInnerPadding = 200.0;

    final descTextBox = TextBoxComponent(
      text: title,
      textRenderer: textStyle,
      size: Vector2(boxSize.x - (outerPadding * 2), boxSize.y * (1 / 3)),
      position: Vector2(outerPadding, topPadding),
      priority: 1,
      align: Anchor.center,
    );
    popUpBox.add(descTextBox);

    final inputTextStyle = TextPaint(
      style: const TextStyle(fontFamily: 'Knewave', fontSize: 32.0, color: Color.fromARGB(255, 241, 238, 239)),
    );

    late void Function(String)? onSubmit;
    for (final button in buttons.values) {
      if (button != null) onSubmit = button;
    }

    late TappableInputTextBox inputTextBox;

    inputTextBox = TappableInputTextBox(
      size: Vector2(boxSize.x - (outerPadding * 2), boxSize.y * (1 / 6)),
      position: Vector2(outerPadding, boxSize.y * (1 / 3) + topPadding + 20),
      textRenderer: inputTextStyle,
      priority: 20,
      placeholder: 'Enter name...',
      onSubmit: (text) async {
        if (text.isEmpty) return;
        if (await SaveManager().loadGame('$text.txt') != null) {
          inputTextBox.editPlaceholder('${inputTextBox.text} is already taken...');
          inputTextBox.editText('');
          inputTextBox.updateTextDisplay();
        } else {
          onSubmit!(text);
          popUpBoxWithScrim.removeFromParent();
        }
      },
    );
    popUpBox.add(inputTextBox);

    final buttonFillPaint = Paint()..color = const Color(0xFFF2C3CD);

    final int numButtons = buttons.length;
    if (numButtons == 0) {
      add(popUpBox);
      return (popUpBoxWithScrim);
    }

    final double totalPadding = (outerPadding * 2) + (buttonInnerPadding * (numButtons - 1));
    final double availableWidth = boxSize.x - totalPadding;
    final double buttonWidth = availableWidth / numButtons;
    final double buttonHeight = boxSize.y * (1 / 6);
    final buttonSize = Vector2(buttonWidth, buttonHeight);
    final double yPos = (boxSize.y * (2 / 3)) + topPadding + 20;

    int i = 0;
    for (final entry in buttons.entries) {
      final String label = entry.key;
      final void Function(String)? onPressed = entry.value;
      final double xPos = outerPadding + (i * (buttonWidth + buttonInnerPadding));
      final buttonShape = RoundedBoxComponent(
        size: buttonSize,
        fillPaint: buttonFillPaint,
        borderRadius: 50,
        boxShadow: BoxShadow(color: Color.fromARGB(90, 0, 0, 0), blurRadius: 1.0, offset: Offset(0, 8)),
      );
      final buttonTextStyle = TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 32.0, color: Color(0xFF8C4B5A)),
      );
      final buttonTextBox = TextBoxComponent(
        text: label,
        textRenderer: buttonTextStyle,
        size: buttonSize,
        align: Anchor.center,
      );
      buttonShape.add(buttonTextBox);

      // --- THIS IS THE NEW BUTTON LOGIC ---
      final button = ButtonComponent(
        size: buttonSize,
        position: Vector2(xPos, yPos),
        button: buttonShape,
        onPressed: () async {
          if (onPressed != null) {
            if (inputTextBox.text.isEmpty) return;
            if (await SaveManager().loadGame('${inputTextBox.text}.txt') != null) {
              inputTextBox.editPlaceholder('${inputTextBox.text} is already taken...');
              inputTextBox.editText('');
              inputTextBox.updateTextDisplay();
            } else {
              onPressed(inputTextBox.text);
              popUpBoxWithScrim.removeFromParent();
            }
          } else {
            popUpBoxWithScrim.removeFromParent();
          }
        },
      );

      popUpBox.add(button);
      i++;
    }

    final settingsWrapper = ButtonComponent(
      button: popUpBox,
      position: Vector2(
        (HelloworldHellolove.virtualResolution.x / 2) - (boxSize.x / 2),
        (HelloworldHellolove.virtualResolution.y / 2) - (boxSize.y / 2),
      ),
      priority: 12,
      onPressed: () {},
    );

    popUpBoxWithScrim.add(settingsWrapper);

    return popUpBoxWithScrim;
  }
}
