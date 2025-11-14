import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:helloworld_hellolove/game_assets/character_sprites_cache.dart';

enum PositionAt { center, left, right }

enum FacingAt { left, right }

class CharacterData extends SpriteComponent {
  late final List<String> states;
  late final String name;
  // late final String fullName;
  late PositionAt positionAt;
  String state;
  FacingAt facingAt;

  CharacterData({
    required this.states,
    required this.name,
    // required this.fullName,
    required super.size,
    this.facingAt = FacingAt.right,
    this.positionAt = PositionAt.center,
    this.state = 'default',
  });

  @override
  FutureOr<void> onLoad() {
    setFacingDirection(facingAt);
    setState(state);
    return super.onLoad();
  }

  void setState(String state) {
    this.state = state.toLowerCase();
    sprite = CharacterSpriteManager.getSprite(name, this.state);
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
      paint.colorFilter = const ColorFilter.mode(Color(0x70000000), BlendMode.srcATop);
      priority = 1;
    } else {
      paint.colorFilter = null;
      priority = 2;
    }
  }

  // --- 2. FIXED fromJson ---
  factory CharacterData.fromJson(Map<String, dynamic> json) {
    // Load Vector2
    final sizeMap = json['size'] as Map<String, dynamic>;
    final size = Vector2(sizeMap['x'], sizeMap['y']);

    // Load PositionAt enum
    final positionString = json['positionAt'] as String;
    final position = PositionAt.values.byName(positionString);

    // Load FacingAt enum
    final facingString = json['facingAt'] as String;
    final facing = FacingAt.values.byName(facingString);

    return CharacterData(
      states: List<String>.from(json['states']),
      name: json['name'] as String,
      size: size,
      positionAt: position, // Pass loaded value
      facingAt: facing, // Pass loaded value
      state: json['state'] as String, // Pass loaded value
    );
  }

  // --- 3. FIXED toJson ---
  Map<String, dynamic> toJson() {
    return {
      'states': states,
      'name': name,

      // Save enums using their string name
      'positionAt': positionAt.name,
      'facingAt': facingAt.name,

      // Save the current state
      'state': state,

      // Convert Vector2 into a simple map
      'size': {'x': size.x, 'y': size.y},
    };
  }

  @override
  String toString() {
    // Customize this to show whatever you want!
    return 'Character(Name: $name, State: $state, Pos: $positionAt, Facing: $facingAt, Size: $size)';
  }
}

CharacterData characterFactory(String name) {
  // 'name' is the short name: 'Akagi', 'Habane', or 'Hotaru'
  final meta = CharacterSpriteManager.getMetaData(name);

  return CharacterData(
    states: meta.states,
    name: name, // Pass the short name
    size: meta.size,
  );
  // The default/throw case is handled inside getMetaData()
}
