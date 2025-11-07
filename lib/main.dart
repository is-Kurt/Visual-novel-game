import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  HelloworldHellolove game = HelloworldHellolove();

  runApp(GameWidget(game: game));
}
