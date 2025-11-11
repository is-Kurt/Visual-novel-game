import 'package:flutter/material.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';

class TextEditorOverlay extends StatefulWidget {
  final HelloworldHellolove game;
  const TextEditorOverlay({super.key, required this.game});

  @override
  State<TextEditorOverlay> createState() => _TextEditorOverlayState();
}

class _TextEditorOverlayState extends State<TextEditorOverlay> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize with the current text from the game
    _controller = TextEditingController(text: widget.game.textToEdit);

    // Add listener for real-time updates to the game
    _controller.addListener(() {
      widget.game.updateText(_controller.text);
    });

    // Request focus to show keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the callback when overlay is disposed
    _focusNode.unfocus();
    widget.game.onTextUpdate = null;
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitAndRemove() {
    if (!mounted) return;
    widget.game.overlays.remove('TextEditor');
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        // Close when tapping background
        GestureDetector(
          onTap: _submitAndRemove,
          child: Container(color: Colors.transparent),
        ),

        // Simple visible TextField
        Positioned(
          bottom: keyboardHeight,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Enter name...', border: OutlineInputBorder()),
              onSubmitted: (value) {
                _submitAndRemove();
              },
            ),
          ),
        ),
      ],
    );
  }
}
