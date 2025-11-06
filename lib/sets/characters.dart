import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

enum PositionAt { center, left, right, none }

enum FacingAt { left, right }

class CharacterData extends SpriteComponent {
  late final List<String> states;
  late final String name;
  PositionAt positionAt = PositionAt.none;
  String state = 'default';
  FacingAt facingAt;

  CharacterData({
    required this.states,
    required this.name,
    required super.size,
    this.facingAt = FacingAt.right,
  });

  @override
  FutureOr<void> onLoad() async {
    setFacingDirection(facingAt);
    setState(state);
    return super.onLoad();
  }

  void setState(String state) async {
    if (states.contains(state)) {
      sprite = await Sprite.load('characters/$name/$state.png');
    } else {
      if (kDebugMode) {
        print('$name has no $state state');
      }
    }
  }

  void setPosition(Vector2 position) {
    this.position = position;
  }

  void setFacingDirection(FacingAt facingAt) {
    this.facingAt = facingAt;
    scale.x = (facingAt == FacingAt.right ? -1 : 1);
  }

  void greydOut(bool greyOut) {
    if (greyOut) {
      paint.colorFilter = const ColorFilter.mode(
        Color(0x70000000),
        BlendMode.srcATop,
      );
    } else {
      paint.colorFilter = null;
    }
  }
}

CharacterData characterFactory(String name) {
  switch (name) {
    case 'Akagi':
      return CharacterData(
        states: [
          'blushing',
          'concerned',
          'crying',
          'default',
          'disappointed',
          'mad',
          'smile',
          'smug',
        ],
        name: 'Akagi Kohaku',
        size: Vector2.all(1000),
      );
    case 'Habane':
      return CharacterData(
        states: [
          'concerned',
          'crying1',
          'crying2',
          'crying3',
          'default',
          'disappointed',
          'mad1',
          'mad2',
          'sad',
          'shocked',
          'smug',
          'tsundere',
        ],
        name: 'Habane Akari',
        size: Vector2.all(900),
      );
    case 'Hotaru':
      return CharacterData(
        states: [
          'blushing',
          'shock',
          'crying',
          'default',
          'mad',
          'sad',
          'smug',
          'flustered',
          'koi',
        ],
        name: 'Hotaru Yuna',
        size: Vector2.all(875),
      );
    default:
      throw Exception('Unknown character name for factory: $name');
  }
}
