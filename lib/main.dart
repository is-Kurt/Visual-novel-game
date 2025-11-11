import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/utils/material_app_text_editor_overlay.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
  }

  MaterialGame game = MaterialGame();
  runApp(game);
}

class MaterialGame extends StatelessWidget {
  const MaterialGame({super.key});

  @override
  Widget build(BuildContext context) {
    final HelloworldHellolove game = HelloworldHellolove();

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
