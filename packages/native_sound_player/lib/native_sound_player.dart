import 'dart:io';
import 'package:flutter/services.dart';

/// Plays Flutter asset sound files on the **music** audio stream using
/// Android's native MediaPlayer.
///
/// This works reliably in background isolates created by
/// `android_alarm_manager_plus`, unlike the `audioplayers` package whose
/// AssetSource resolver fails in background engines.
///
/// Registered as a proper Flutter plugin so it is automatically added to
/// every FlutterEngine, including background engines.
///
/// ## Audio focus
///
/// Call [requestAudioFocus] before playing sounds to temporarily pause the
/// user's music, then [abandonAudioFocus] when done so music resumes.
class NativeSoundPlayer {
  static const _channel =
      MethodChannel('com.lagunitacrew.native_sound_player/player');

  /// Plays the given Flutter asset on the music audio stream.
  ///
  /// [assetPath] is the Flutter asset path, e.g.
  /// `'assets/sounds/wake-up/morning-rooster.wav'`.
  ///
  /// Does nothing on iOS. Fails silently with a log message on error.
  static Future<void> playAsset(String assetPath) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('playAsset', {'assetPath': assetPath});
    } catch (e) {
      print('⚠️ Failed to play asset sound: $e');
    }
  }

  /// Requests that other media apps (e.g. Spotify, YouTube Music) pause
  /// playback while our notification sounds and TTS play.
  ///
  /// Uses audio focus if granted, otherwise falls back to sending a
  /// MEDIA_PAUSE key event which directly pauses the active media session.
  ///
  /// Returns `true` if the pause was dispatched. Does nothing on iOS.
  /// Call [abandonAudioFocus] when playback is complete to let music resume.
  static Future<bool> requestAudioFocus() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('requestAudioFocus');
      final result = granted ?? false;
      print('🔇 requestAudioFocus: ${result ? "OK (music paused)" : "FAILED"}');
      return result;
    } catch (e) {
      print('⚠️ Failed to request audio focus: $e');
      return false;
    }
  }

  /// Abandons audio focus so the user's music can resume.
  ///
  /// Safe to call even if focus was never requested. Does nothing on iOS.
  static Future<void> abandonAudioFocus() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('abandonAudioFocus');
      print('🔊 abandonAudioFocus: music should resume');
    } catch (e) {
      print('⚠️ Failed to abandon audio focus: $e');
    }
  }
}
