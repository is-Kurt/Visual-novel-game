import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/utils/material_app_text_editor_overlay.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

void main() async {
  final HelloworldHellolove game = HelloworldHellolove();
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.addListener(WindowManagerListener(game: game));
  } else {
    // Mobile devices (no change here)
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
  }

  runApp(MaterialGame(game: game));
}

class MaterialGame extends StatelessWidget {
  final HelloworldHellolove game;
  const MaterialGame({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            'TextEditor': (BuildContext context, HelloworldHellolove game) {
              return TextEditorOverlay(game: game);
            },
          },
        ),
      ),
    );
  }
}
