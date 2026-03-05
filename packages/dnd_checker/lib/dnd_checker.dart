import 'dart:io';
import 'package:flutter/services.dart';

/// Checks whether Android Do Not Disturb mode is active.
///
/// Uses a MethodChannel that is registered as a proper Flutter plugin so it
/// works in both the main isolate **and** the background isolates created by
/// `android_alarm_manager_plus`.
class DndChecker {
  static const _channel =
      MethodChannel('com.lagunitacrew.dnd_checker/dnd');

  /// Returns `true` when DND is active (any mode other than
  /// `INTERRUPTION_FILTER_ALL`).
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
