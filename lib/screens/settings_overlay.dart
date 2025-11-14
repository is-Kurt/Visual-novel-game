import 'dart:io' show Platform; // For checking the platform
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:helloworld_hellolove/helloworld_hellolove.dart';
import 'package:helloworld_hellolove/utils/rounded_rectangle.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart'; // For fullscreen toggle

class SettingsOverlay {
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

  // These are 0-100 values for the UI
  double masterVolume = 100;
  double musicVolume = 100;
  double sfxVolume = 100;
  double textSpeed = 50;
  bool isFullScreen = false;

  late SharedPreferences prefs;

  SettingsOverlay({required this.game});

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();

    // Load 0.0-1.0 values from prefs and convert to 0-100 for sliders
    masterVolume = (prefs.getDouble('masterVolume') ?? 1.0) * 100;
    musicVolume = (prefs.getDouble('musicVolume') ?? 1.0) * 100;
    sfxVolume = (prefs.getDouble('sfxVolume') ?? 1.0) * 100;
    textSpeed = prefs.getDouble('textSpeed') ?? 50;

    // Load fullscreen setting
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      isFullScreen = prefs.getBool('isFullScreen') ?? false;
    }
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

    // --- MASTER VOLUME ---
    settingsContainer.add(
      createSlider(masterVolume, 'Master volume', (newValue) {
        masterVolume = newValue;
        // Update live for preview
        game.masterVolume = masterVolume / 100.0;
        FlameAudio.bgm.audioPlayer.setVolume(game.musicVolume * game.masterVolume);
        game.minigameAudioPlayer?.setVolume(game.sfxVolume * game.masterVolume);
      }),
    );
    // --- MUSIC VOLUME ---
    settingsContainer.add(
      createSlider(musicVolume, 'Music volume', (newValue) {
        musicVolume = newValue;
        // Update live for preview
        game.musicVolume = musicVolume / 100.0;
        FlameAudio.bgm.audioPlayer.setVolume(game.musicVolume * game.masterVolume);
      }),
    );
    // --- SFX VOLUME ---
    settingsContainer.add(
      createSlider(sfxVolume, 'SFX volume', (newValue) {
        sfxVolume = newValue;
        // Update live for preview
        game.sfxVolume = sfxVolume / 100.0;
        game.minigameAudioPlayer?.setVolume(game.sfxVolume * game.masterVolume);
      }),
    );

    settingsContainer.add(createtextLabel('Text Speed'));
    settingsContainer.add(
      createSlider(textSpeed, 'Text Speed', (newValue) {
        textSpeed = newValue;
      }),
    );

    // --- FULLSCREEN TOGGLE (DESKTOP ONLY) ---
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      settingsContainer.add(createtextLabel('Display'));

      topPadding += 60;

      // --- NEW: Create the ToggleSwitch ---
      final toggleSwitch = ToggleSwitch(
        initialValue: isFullScreen,
        onChanged: (newValue) async {
          // This is called when the switch is tapped
          isFullScreen = newValue;
        },
        position: Vector2(0, topPadding),
        anchor: Anchor.centerLeft,
        width: settingsComponentWidth * 0.7, // Make it a good size
      );

      settingsContainer.add(toggleSwitch);
    }

    topPadding += 70;
    // --- SAVE BUTTON ---
    settingsContainer.add(
      addButtons('Save', settingsContainerSize.x * 0.2, () async {
        // Save all values
        await prefs.setDouble('masterVolume', masterVolume / 100.0);
        await prefs.setDouble('musicVolume', musicVolume / 100.0);
        await prefs.setDouble('sfxVolume', sfxVolume / 100.0);
        await prefs.setDouble('textSpeed', textSpeed);

        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          await prefs.setBool('isFullScreen', isFullScreen);
        }

        // Apply settings to game
        await game.loadSettings();
        settingsScrim.removeFromParent();
      }),
    );

    // --- EXIT BUTTON ---
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
    topPadding += 90;

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

  PositionComponent createSlider(double initialValue, String name, Function(double) onUpdate) {
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
      text: '$name: ${initialValue.toStringAsFixed(0)}%',
      textRenderer: TextPaint(
        style: const TextStyle(fontFamily: 'Knewave', fontSize: 32.0, color: Color.fromARGB(250, 242, 195, 205)),
      ),
      anchor: Anchor.centerLeft,
    );
    volumeContainer.add(volumeText);

    final slider = VolumeSlider(
      initialValue: initialValue / 100.0,
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

// ---------------------------------------------------------------------
// --- HELPER COMPONENT: VolumeSlider ---
// ---------------------------------------------------------------------
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

    _trackBg = RoundedBoxComponent(
      size: Vector2(trackWidth, trackHeight),
      position: Vector2(thumbRadius, trackY),
      fillPaint: Paint()..color = inactiveTrackColor,
      borderRadius: trackHeight / 2,
    );

    _trackFg = RoundedBoxComponent(
      size: Vector2(trackWidth, trackHeight),
      position: Vector2(thumbRadius, trackY),
      fillPaint: Paint()..color = activeTrackColor,
      borderRadius: trackHeight / 2,
      borderPaint: Paint()..color = inactiveTrackColor,
      borderWidth: 5,
    );

    _thumb = CircleComponent(
      radius: thumbRadius,
      paint: Paint()..color = activeTrackColor,
      anchor: Anchor.center,
      position: Vector2(0, size.y / 2),
    );

    await addAll([_trackBg, _trackFg, _thumb]);
    _updateVisuals();
  }

  void _updateVisuals() {
    final thumbX = thumbRadius + _value * (size.x - thumbRadius * 2);
    _thumb.position.x = thumbX;
    _trackFg.size.x = _value * _trackBg.size.x;
  }

  void _updateValueFromPosition(double localX) {
    final trackStart = thumbRadius;
    final trackWidth = size.x - thumbRadius * 2;
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

// ---------------------------------------------------------------------
// --- HELPER COMPONENT: _ScrimButtonComponent ---
// ---------------------------------------------------------------------
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

// ---------------------------------------------------------------------
// --- NEW HELPER COMPONENT: ToggleSwitch ---
// ---------------------------------------------------------------------
class ToggleSwitch extends PositionComponent with TapCallbacks {
  bool _value;
  final Function(bool) onChanged;

  late RoundedBoxComponent _trackInactive;
  late RoundedBoxComponent _trackActive;
  late RoundedBoxComponent _knob;

  final double _padding = 5.0;
  final Color _activeColor = const Color.fromARGB(255, 146, 50, 72);
  final Color _inactiveColor = const Color.fromARGB(250, 242, 195, 205);
  final TextStyle _textStyle = const TextStyle(
    fontFamily: 'Knewave',
    fontSize: 32.0,
    color: Color.fromARGB(250, 242, 195, 205),
  );

  bool get value => _value;

  ToggleSwitch({
    required bool initialValue,
    required this.onChanged,
    required double width,
    super.position,
    super.anchor,
  }) : _value = initialValue,
       super(size: Vector2(width, 50)); // Set a fixed height

  @override
  Future<void> onLoad() async {
    final double trackWidth = 100.0; // Width of the switch itself
    final double trackHeight = 40.0;
    final double knobSize = trackHeight + _padding;

    // --- Labels ---
    final windowLabel = TextComponent(
      text: 'Window',
      textRenderer: TextPaint(style: _textStyle),
      anchor: Anchor.centerRight,
      position: Vector2(size.x / 2 - trackWidth / 2 - 20, size.y / 2),
    );

    final fullscreenLabel = TextComponent(
      text: 'Fullscreen',
      textRenderer: TextPaint(style: _textStyle),
      anchor: Anchor.centerLeft,
      position: Vector2(size.x / 2 + trackWidth / 2 + 20, size.y / 2),
    );

    // --- Switch Components ---
    _trackInactive = RoundedBoxComponent(
      size: Vector2(trackWidth, trackHeight),
      fillPaint: Paint()..color = _inactiveColor,
      borderRadius: trackHeight / 2,
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );

    _trackActive = RoundedBoxComponent(
      size: Vector2(trackWidth + 10, trackHeight),
      fillPaint: Paint()..color = _activeColor,
      borderRadius: trackHeight / 2,
      borderPaint: Paint()..color = const Color.fromARGB(250, 242, 195, 205),
    );

    _knob = RoundedBoxComponent(
      size: Vector2.all(knobSize),
      fillPaint: Paint()..color = const Color.fromARGB(255, 146, 50, 72),
      borderRadius: knobSize / 2,
      boxShadow: BoxShadow(color: Color.fromARGB(90, 0, 0, 0), blurRadius: 1.0, offset: Offset(0, 4)),
      position: Vector2(0, (knobSize / 2) - _padding / 2),
      anchor: Anchor.center,
    );

    // Add children
    await add(windowLabel);
    await add(fullscreenLabel);
    await add(_trackInactive);
    // Add active track and knob as children of the *inactive* track
    // so their positions are relative to it.
    await _trackInactive.add(_trackActive);
    await _trackInactive.add(_knob);

    _updateVisuals(false); // Set initial state
  }

  @override
  void onTapDown(TapDownEvent event) {
    _value = !_value;
    onChanged(_value);
    _updateVisuals(true);
  }

  void _updateVisuals(bool animate) {
    if (_value) {
      // ON (Fullscreen)
      _trackActive.size.x = _trackInactive.size.x; // Fill
      _trackActive.borderWidth = 10;
      _knob.position.x = _trackInactive.size.x - (_knob.size.x / 2) - _padding + 10;
    } else {
      // OFF (Window)
      _trackActive.size.x = 0; // Empty
      _trackActive.borderWidth = 0;
      _knob.position.x = (_knob.size.x / 2) + _padding - 10;
    }
  }
}
