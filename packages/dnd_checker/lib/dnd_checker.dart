import 'dart:io';
import 'package:flutter/services.dart';

/// Checks whether the app should suppress audio (sound & TTS).
///
/// Returns `true` when:
/// - **DND is active** (any interruption filter other than `INTERRUPTION_FILTER_ALL`)
/// - **Phone/VoIP call is active** (`AudioManager.getMode()` is `MODE_IN_CALL`,
///   `MODE_IN_COMMUNICATION`, or `MODE_RINGTONE`)
///
/// The call-detection check uses `AudioManager.getMode()` which requires
/// **no permissions** and covers regular phone calls as well as VoIP calls
/// (WhatsApp, Zoom, Teams, etc.).
///
/// Uses a MethodChannel that is registered as a proper Flutter plugin so it
/// works in both the main isolate **and** the background isolates created by
/// `android_alarm_manager_plus`.
class DndChecker {
  static const _channel =
      MethodChannel('com.lagunitacrew.dnd_checker/dnd');

  /// Returns `true` when audio should be suppressed — either DND is active
  /// or the user is on a phone/VoIP call.
  ///
  /// Returns `false` on iOS or when the native call fails (fail-open so
  /// audio still plays if something goes wrong).
  static Future<bool> isDndActive() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool result = await _channel.invokeMethod('isDndActive');
      return result;
    } catch (e) {
      print('⚠️ Failed to check DND status: $e');
      return false; // fail-open: play audio when in doubt
    }
  }
}
