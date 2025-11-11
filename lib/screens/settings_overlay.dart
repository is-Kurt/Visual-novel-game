import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:helloworld_hellolove/game_scene/scene.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/utils/rounded_rectangle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame_audio/flame_audio.dart'; // Import for FlameAudio

class SettingsOverlay {
  // 1. ADD A VARIABLE TO HOLD THE GAME INSTANCE
  final HelloworldHellolove game;

  final settingsContainerSize = Vector2(
    HelloworldHellolove.virtualResolution.x * (8 / 10),
    HelloworldHellolove.virtualResolution.y * (8 / 10),
  );
  final settingsContainerPadding = Vector2(
    HelloworldHellolove.virtualResolution.x * (1 / 10),
    HelloworldHellolove.virtualResolution.y * (1 / 10),
  );
  late double settingsComponentWidth;
  double topPadding = 0;

  double masterVolume = 100; // These are 0-100
  double musicVolume = 100;
  double sfxVolume = 100;
  double textSpeed = 50;

  late SharedPreferences prefs;

  // 2. ADD A CONSTRUCTOR TO RECEIVE THE GAME
  SettingsOverlay({required this.game});

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();

    masterVolume = (prefs.getDouble('masterVolume') ?? 1.0) * 100;
    musicVolume = (prefs.getDouble('musicVolume') ?? 1.0) * 100;
    sfxVolume = (prefs.getDouble('sfxVolume') ?? 1.0) * 100;
    textSpeed = prefs.getDouble('textSpeed') ?? 50;
  }

  Future<ButtonComponent> openSettings([VoidCallback? onDismount]) async {
    await initialize();

    late ButtonComponent settingsScrim;
    settingsComponentWidth = settingsContainerSize.x * 0.8;

    settingsScrim = _ScrimButtonComponent(
      button: RectangleComponent(
        size: HelloworldHellolove.virtualResolution,
        paint: Paint()..color = const Color(0x80000000),
      ),
      size: HelloworldHellolove.virtualResolution,
      onPressed: () => {settingsScrim.removeFromParent()},
      priority: 11,
      onDismount: onDismount,
    );

    final settingsContainer = RoundedBoxComponent(
      size: settingsContainerSize,
      fillPaint: Paint()..color = const Color.fromARGB(240, 180, 87, 109),
      borderPaint: Paint()..color = const Color.fromARGB(250, 242, 195, 205),
      borderRadius: 20,
      borderWidth: 10,
      priority: 12,
    );

    settingsContainer.add(createtextLabel('Volume'));

    settingsContainer.add(
      createSlider(masterVolume, 'Master volume', (newValue) {
        masterVolume = newValue;
        // Update live for preview
        game.masterVolume = masterVolume / 100.0;
        FlameAudio.bgm.audioPlayer.setVolume(game.musicVolume * game.masterVolume);
        if (game.minigameAudioPlayer != null) {
          game.minigameAudioPlayer!.setVolume(game.sfxVolume * game.masterVolume);
        }
      }),
    );
    settingsContainer.add(
      createSlider(musicVolume, 'Music volume', (newValue) {
        musicVolume = newValue;
        // Update live for preview
        game.musicVolume = musicVolume / 100.0;
        FlameAudio.bgm.audioPlayer.setVolume(game.musicVolume * game.masterVolume);
      }),
    );
    settingsContainer.add(
      createSlider(sfxVolume, 'SFX volume', (newValue) {
        sfxVolume = newValue;
        // Update live for preview
        game.sfxVolume = sfxVolume / 100.0;
        if (game.minigameAudioPlayer != null) {
          game.minigameAudioPlayer!.setVolume(game.sfxVolume * game.masterVolume);
        }
      }),
    );

    settingsContainer.add(createtextLabel('Text Speed'));
    settingsContainer.add(
      createSlider(textSpeed, 'Text Speed', (newValue) {
        textSpeed = newValue;
      }),
    );

    topPadding += 100;
    settingsContainer.add(
      addButtons('Save', settingsContainerSize.x * 0.2, () async {
        await prefs.setDouble('masterVolume', masterVolume / 100.0);
        await prefs.setDouble('musicVolume', musicVolume / 100.0);
        await prefs.setDouble('sfxVolume', sfxVolume / 100.0);
        await prefs.setDouble('textSpeed', textSpeed);

        game.loadSettings();
        settingsScrim.removeFromParent();
      }),
    );

    settingsContainer.add(
      addButtons('Exit', (settingsContainerSize.x * 0.8) - (settingsComponentWidth * 0.2), () async {
        await game.loadSettings();
        settingsScrim.removeFromParent();
      }),
    );

    final settingsWrapper = ButtonComponent(
      button: settingsContainer,
      position: settingsContainerPadding,
      priority: 12,
      onPressed: () {},
    );

    settingsScrim.add(settingsWrapper);

    return settingsScrim;
  }

  ButtonComponent addButtons(String label, double xPos, Function() onPress) {
    final buttonSize = Vector2(settingsComponentWidth * 0.2, settingsContainerSize.y * 0.1);

    final buttonShape = RoundedBoxComponent(
      size: buttonSize,
      fillPaint: Paint()..color = const Color.fromARGB(250, 242, 195, 205),
      borderRadius: 50,
      boxShadow: BoxShadow(color: Color.fromARGB(90, 0, 0, 0), blurRadius: 1.0, offset: Offset(0, 8)),
    );

    final buttonTextBox = TextBoxComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 48.0, color: Color.fromARGB(240, 180, 87, 109)),
      ),
      size: buttonSize,
      align: Anchor.center,
    );

    buttonShape.add(buttonTextBox);

    final button = ButtonComponent(button: buttonShape, position: Vector2(xPos, topPadding), onPressed: onPress);

    return button;
  }

  RoundedBoxComponent createtextLabel(String text) {
    topPadding += 100;

    final textContainter = RoundedBoxComponent(
      size: Vector2(settingsComponentWidth, settingsContainerSize.y * 0.1),
      position: Vector2(settingsContainerSize.x / 2, topPadding),
      anchor: Anchor.center,
      fillPaint: Paint()..color = const Color.fromARGB(250, 242, 195, 205),
      borderRadius: 50,
    );

    final textLabel = TextComponent(
      text: text,
      position: Vector2(settingsComponentWidth / 2, 5),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 48.0, color: Color.fromARGB(240, 180, 87, 109)),
      ),
    );

    textContainter.add(textLabel);

    topPadding += 30;
    return textContainter;
  }

  PositionComponent createSlider(double initialVolume, String name, Function(double) onUpdate) {
    topPadding += 60;

    final volumeContainer = PositionComponent(
      size: Vector2(settingsComponentWidth, 0),
      position: Vector2(settingsContainerSize.x / 2, topPadding),
      anchor: Anchor.center,
    );

    // --- Slider & Text ---
    final sliderWidth = settingsComponentWidth * 0.7;
    final sliderHeight = 20.0;
    final thumbRadius = 15.0; // Thumb is slightly larger than track
    const activeTrackColor = Color.fromARGB(255, 146, 50, 72); // Pink/Red from image
    const inactiveTrackColor = Color.fromARGB(250, 242, 195, 205); // White from image

    final TextComponent volumeText = TextComponent(
      text: '$name: ${initialVolume.toStringAsFixed(0)}%',
      textRenderer: TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 32.0, color: Color.fromARGB(250, 242, 195, 205)),
      ),
      anchor: Anchor.centerLeft,
    );
    volumeContainer.add(volumeText);

    final slider = VolumeSlider(
      initialValue: initialVolume / 100.0,
      onChanged: (newSliderValue) {
        final newVolume = newSliderValue * 100;
        onUpdate(newVolume);
        volumeText.text = '$name ${newVolume.toStringAsFixed(0)}%';
      },
      size: Vector2(sliderWidth, thumbRadius * 2),
      position: Vector2(settingsComponentWidth * 0.3, 0),
      anchor: Anchor.centerLeft,
      thumbRadius: thumbRadius,
      trackHeight: sliderHeight,
      activeTrackColor: activeTrackColor,
      inactiveTrackColor: inactiveTrackColor,
    );
    volumeContainer.add(slider);

    return volumeContainer;
  }
}

class VolumeSlider extends PositionComponent with DragCallbacks, TapCallbacks {
  double _value;
  final Function(double) onChanged;
  final double thumbRadius;
  final double trackHeight;
  final Color activeTrackColor;
  final Color inactiveTrackColor;

  late RoundedBoxComponent _trackBg;
  late RoundedBoxComponent _trackFg;
  late CircleComponent _thumb;

  double get value => _value;

  VolumeSlider({
    required double initialValue,
    required this.onChanged,
    required super.size,
    required this.thumbRadius,
    required this.trackHeight,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    super.position,
    super.anchor,
  }) : _value = initialValue.clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    final trackWidth = size.x - thumbRadius * 2;
    final trackY = (size.y - trackHeight) / 2;

    // 1. Inactive Track (Background)
    _trackBg = RoundedBoxComponent(
      size: Vector2(trackWidth, trackHeight),
      position: Vector2(thumbRadius, trackY),
      fillPaint: Paint()..color = inactiveTrackColor,
      borderRadius: trackHeight / 2,
    );

    // 2. Active Track (Foreground)
    _trackFg = RoundedBoxComponent(
      size: Vector2(trackWidth, trackHeight),
      position: Vector2(thumbRadius, trackY),
      fillPaint: Paint()..color = activeTrackColor,
      borderRadius: trackHeight / 2,
      borderPaint: Paint()..color = inactiveTrackColor,
      borderWidth: 5,
    );

    // 3. Thumb
    _thumb = CircleComponent(
      radius: thumbRadius,
      paint: Paint()..color = activeTrackColor,
      anchor: Anchor.center,
      position: Vector2(0, size.y / 2), // Initial position set by _updateVisuals
    );

    await addAll([_trackBg, _trackFg, _thumb]);
    _updateVisuals(); // Set initial visual state
  }

  // --- Visual Update Logic ---

  void _updateVisuals() {
    // Update thumb position
    final thumbX = thumbRadius + _value * (size.x - thumbRadius * 2);
    _thumb.position.x = thumbX;

    // Update active track width by resizing the component
    final clipWidth = _value * _trackBg.size.x;
    _trackFg.size.x = clipWidth;
  }

  // --- Input Handling ---

  void _updateValueFromPosition(double localX) {
    final trackStart = thumbRadius;
    final trackWidth = size.x - thumbRadius * 2;

    // Calculate the value based on the tap/drag position
    final newRawValue = (localX - trackStart) / trackWidth;
    final newValue = newRawValue.clamp(0.0, 1.0);

    if (_value != newValue) {
      _value = newValue;
      onChanged(_value);
      _updateVisuals();
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _updateValueFromPosition(event.localPosition.x);
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    _updateValueFromPosition(event.localEndPosition.x);
    return true;
  }

  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _updateValueFromPosition(event.localPosition.x);
    return true;
  }
}

class _ScrimButtonComponent extends ButtonComponent {
  final VoidCallback? onDismount;
  _ScrimButtonComponent({
    required super.button,
    required super.size,
    required super.onPressed,
    required super.priority,
    this.onDismount,
  });

  @override
  void onRemove() {
    onDismount?.call();
    super.onRemove();
  }
}
