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
}
