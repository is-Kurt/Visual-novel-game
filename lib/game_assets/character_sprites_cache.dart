import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class CharacterMetaData {
  final String fullName;
  final List<String> states;
  final Vector2 size;
  CharacterMetaData({required this.fullName, required this.states, required this.size});
}

class CharacterSpriteManager {
  static final Map<String, CharacterMetaData> _metaData = {
    'Akagi': CharacterMetaData(
      fullName: 'Akagi Kohaku',
      states: ['blushing', 'concerned', 'crying', 'default', 'disappointed', 'mad', 'smile', 'smug'],
      size: Vector2.all(1000),
    ),
    'Habane': CharacterMetaData(
      fullName: 'Habane Akari',
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
      size: Vector2.all(900),
    ),
    'Hotaru': CharacterMetaData(
      fullName: 'Hotaru Yuna',
      states: ['blushing', 'shock', 'crying', 'default', 'mad', 'sad', 'smug', 'flustered', 'koi'],
      size: Vector2.all(875),
    ),
  };

  // Map<CharacterName (short), Map<StateName, Sprite>>
  static final Map<String, Map<String, Sprite>> _spriteCache = {};

  // Call this from your game's main onLoad.
  static Future<void> loadAllSprites() async {
    for (final entry in _metaData.entries) {
      final shortName = entry.key; // 'Akagi'
      final meta = entry.value;

      final Map<String, Sprite> stateSprites = {};
      for (final state in meta.states) {
        final sprite = await Sprite.load('characters/${meta.fullName}/$state.webp');
        stateSprites[state] = sprite;
      }
      _spriteCache[shortName] = stateSprites;
    }
  }

  // Helper for the factory
  static CharacterMetaData getMetaData(String shortName) {
    final meta = _metaData[shortName];
    if (meta == null) {
      throw Exception('Unknown character name for factory: $shortName');
    }
    return meta;
  }

  // 5. Helper for CharacterData to get a pre-loaded sprite
  static Sprite getSprite(String shortName, String state) {
    final stateLower = state.toLowerCase();
    final charSprites = _spriteCache[shortName];

    if (charSprites == null) {
      throw ('$shortName is not in the sprite cache.');
    }

    final sprite = charSprites[stateLower];
    if (sprite == null) {
      // Use debugPrint to avoid crashing, as we discussed
      debugPrint('WARNING: $shortName has no $stateLower state. Using "default".');
      return charSprites['default']!; // Fallback to default
    }
    return sprite;
  }
}
