import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:helloworld_hellolove/game_assets/character_sprites_cache.dart';

enum PositionAt { center, left, right }

enum FacingAt { left, right }

class CharacterData extends SpriteComponent {
  late final List<String> states;
  late final String name;
  late PositionAt positionAt;
  String state = 'default';
  FacingAt facingAt;

  CharacterData({required this.states, required this.name, required super.size, this.facingAt = FacingAt.right});

  @override
  FutureOr<void> onLoad() {
    setFacingDirection(facingAt);
    setState(state);
    return super.onLoad();
  }

  void setState(String state) {
    state = state.toLowerCase();
    sprite = CharacterSpriteManager.getSprite(name, state);
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
