import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

/// The short, one-shot sound effects MixRun can play. Each maps to a file in
/// `assets/audio/sfx/`.
enum Sfx {
  pickup,
  drop,
  combine,
  discovery,
  reject,
  clear,
  revert,
  hint,
  hintBlocked,
  reward,
  button,
  toggle,
  milestone,
}

/// Plays MixRun's audio: a looping background music track (kept deliberately
/// quiet) and short one-shot sound effects.
///
/// Music sounds only when it is *both* enabled by the player and the app is in
/// the foreground,  when the app is minimised or otherwise backgrounded the
/// track is paused, and it resumes from where it left off when the player comes
/// back. Lifecycle is observed directly so callers don't have to think about it.
///
/// Music playback is idempotent,  calling [setMusicEnabled] repeatedly with the
/// same value is a no-op,  so it's safe to drive directly from a controller's
/// change notifications. Sound effects are gated by [setSoundEnabled] so callers
/// can fire [playEffect] freely without checking the preference themselves.
class AudioService with WidgetsBindingObserver {
  AudioService() {
    // Background music loops for as long as it's playing.
    _music.setReleaseMode(ReleaseMode.loop);
    _music.setVolume(_musicVolume);
    // A small pool of low-latency players so rapid effects (e.g. fast combines)
    // overlap instead of cutting each other off.
    //
    // Effects use `mixWithOthers` focus (Android: AudioFocus.none) so they layer
    // *over* the background music instead of grabbing exclusive audio focus, 
    // which would otherwise pause the music every time an effect played.
    final AudioContext sfxContext =
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();
    _sfxPool = List<AudioPlayer>.generate(_sfxPoolSize, (_) {
      final AudioPlayer p = AudioPlayer();
      p.setPlayerMode(PlayerMode.lowLatency);
      p.setReleaseMode(ReleaseMode.stop);
      p.setAudioContext(sfxContext);
      return p;
    });
    WidgetsBinding.instance.addObserver(this);
  }

  /// Background music is mixed well below sound effects so it sits under the
  /// game rather than competing with it.
  static const double _musicVolume = 0.22;

  /// Default sound-effect level. Individual effects can override this via
  /// [_volumeFor],  the whooshy clear/revert in particular are kept quiet.
  static const double _sfxVolume = 0.5;

  /// Per-effect playback volume (0–1). Anything not listed uses [_sfxVolume].
  static double _volumeFor(Sfx sfx) => switch (sfx) {
        // Whooshes are harsh; keep them well below the rest.
        Sfx.clear || Sfx.revert => 0.22,
        // Frequent, incidental taps stay subtle.
        Sfx.pickup || Sfx.drop || Sfx.button || Sfx.toggle => 0.38,
        Sfx.reject || Sfx.hintBlocked => 0.42,
        // Rewarding moments can sit a touch louder.
        Sfx.discovery || Sfx.milestone || Sfx.reward || Sfx.hint => 0.6,
        Sfx.combine => _sfxVolume,
      };

  /// How many effects can overlap before the oldest is reused.
  static const int _sfxPoolSize = 4;

  /// Asset path relative to the `assets/` folder (audioplayers' default root).
  static const String _musicAsset = 'audio/background_music.mp3';

  final AudioPlayer _music = AudioPlayer();
  late final List<AudioPlayer> _sfxPool;
  int _sfxIndex = 0;

  /// The player's music preference (the settings toggle).
  bool _musicEnabled = false;

  /// The player's sound-effects preference (the settings toggle).
  bool _soundEnabled = true;

  /// Whether the app is currently in the foreground and interactive.
  bool _foreground = true;

  /// Whether the track is actually sounding right now (enabled + foreground).
  bool _playing = false;

  /// Turns the player's music preference on or off. Safe to call repeatedly.
  Future<void> setMusicEnabled(bool enabled) async {
    if (enabled == _musicEnabled) return;
    _musicEnabled = enabled;
    await _sync();
  }

  /// Turns the player's sound-effects preference on or off.
  void setSoundEnabled(bool enabled) => _soundEnabled = enabled;

  /// Plays a one-shot sound effect, unless effects are disabled. Fire-and-forget
  /// and resilient: a playback failure is swallowed rather than surfaced.
  Future<void> playEffect(Sfx sfx) async {
    if (!_soundEnabled) return;
    final AudioPlayer player = _sfxPool[_sfxIndex];
    _sfxIndex = (_sfxIndex + 1) % _sfxPool.length;
    try {
      await player.stop();
      await player.play(AssetSource(_assetFor(sfx)), volume: _volumeFor(sfx));
    } catch (_) {
      // Audio is non-essential; never let a playback failure break the app.
    }
  }

  static String _assetFor(Sfx sfx) => 'audio/sfx/${_fileFor(sfx)}.wav';

  static String _fileFor(Sfx sfx) => switch (sfx) {
        Sfx.pickup => 'pickup',
        Sfx.drop => 'drop',
        Sfx.combine => 'combine',
        Sfx.discovery => 'discovery',
        Sfx.reject => 'reject',
        Sfx.clear => 'clear',
        Sfx.revert => 'revert',
        Sfx.hint => 'hint',
        Sfx.hintBlocked => 'hint_blocked',
        Sfx.reward => 'reward',
        Sfx.button => 'button',
        Sfx.toggle => 'toggle',
        Sfx.milestone => 'milestone',
      };

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only `resumed` counts as foreground; inactive/hidden/paused/detached all
    // mean the player isn't actively in the game, so the music should hush.
    final bool foreground = state == AppLifecycleState.resumed;
    if (foreground == _foreground) return;
    _foreground = foreground;
    _sync();
  }

  /// Reconciles actual playback with the desired state: music sounds only when
  /// enabled *and* in the foreground. Pauses rather than stops so returning to
  /// the app continues the loop seamlessly.
  Future<void> _sync() async {
    final bool shouldPlay = _musicEnabled && _foreground;
    if (shouldPlay == _playing) return;
    _playing = shouldPlay;
    try {
      if (shouldPlay) {
        await _music.setReleaseMode(ReleaseMode.loop);
        await _music.setVolume(_musicVolume);
        if (_music.state == PlayerState.paused) {
          // Resuming from a background/toggle pause keeps the loop position.
          await _music.resume();
        } else {
          await _music.play(AssetSource(_musicAsset));
        }
      } else {
        await _music.pause();
      }
    } catch (_) {
      // Audio is non-essential; never let a playback failure break the app.
      _playing = !shouldPlay;
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _music.dispose();
    for (final AudioPlayer p in _sfxPool) {
      await p.dispose();
    }
  }
}
