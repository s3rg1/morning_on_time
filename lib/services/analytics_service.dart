import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Firebase Analytics event logging.
///
/// Handles both foreground logging and deferred events from background
/// isolates where Firebase may not be initialized.
class AnalyticsService {
  static const String _pendingEventsKey = 'pending_analytics_events';

  static FirebaseAnalytics? _instance;

  static FirebaseAnalytics? get _analytics {
    try {
      _instance ??= FirebaseAnalytics.instance;
      return _instance;
    } catch (_) {
      return null;
    }
  }

  // --- Foreground event logging ---

  static Future<void> logJourneyStarted() async {
    try {
      await _analytics?.logEvent(name: 'journey_started');
      print('📊 Analytics: journey_started');
    } catch (e) {
      print('⚠️ Analytics error (journey_started): $e');
    }
  }

  static Future<void> logJourneyCompleted({required bool onTime}) async {
    try {
      await _analytics?.logEvent(
        name: 'journey_completed',
        parameters: {'on_time': onTime.toString()},
      );
      print('📊 Analytics: journey_completed (on_time=$onTime)');
    } catch (e) {
      print('⚠️ Analytics error (journey_completed): $e');
    }
  }

  static Future<void> logStreakUpdated({required int streakLength}) async {
    try {
      await _analytics?.logEvent(
        name: 'streak_updated',
        parameters: {'streak_length': streakLength},
      );
      print('📊 Analytics: streak_updated (streak_length=$streakLength)');
    } catch (e) {
      print('⚠️ Analytics error (streak_updated): $e');
    }
  }

  static Future<void> logStreakBroken({required int streakLengthBeforeReset}) async {
    try {
      await _analytics?.logEvent(
        name: 'streak_broken',
        parameters: {'streak_length_before_reset': streakLengthBeforeReset},
      );
      print('📊 Analytics: streak_broken (streak_length_before_reset=$streakLengthBeforeReset)');
    } catch (e) {
      print('⚠️ Analytics error (streak_broken): $e');
    }
  }

  // --- Deferred event queue (for background isolates) ---

  /// Queue an event to be sent when the app next opens.
  /// Call this from background isolates where Firebase is not initialized.
  static Future<void> queueDeferredEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingEventsKey);
      final List<dynamic> pending =
          pendingJson != null ? json.decode(pendingJson) : [];

      pending.add({
        'name': name,
        if (parameters != null) 'parameters': parameters,
      });

      await prefs.setString(_pendingEventsKey, json.encode(pending));
      print('📊 Analytics: queued deferred event "$name"');
    } catch (e) {
      print('⚠️ Analytics error (queueDeferredEvent): $e');
    }
  }

  /// Flush all pending deferred events to Firebase.
  /// Call this once during app initialization after Firebase is ready.
  static Future<void> flushDeferredEvents() async {
    try {
      if (Firebase.apps.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingEventsKey);
      if (pendingJson == null) return;

      final List<dynamic> pending = json.decode(pendingJson);
      if (pending.isEmpty) return;

      final analytics = _analytics;
      if (analytics == null) return;

      for (final event in pending) {
        final name = event['name'] as String;
        final params = event['parameters'] as Map<String, dynamic>?;
        await analytics.logEvent(
          name: name,
          parameters: params?.map((k, v) => MapEntry(k, v)),
        );
        print('📊 Analytics: flushed deferred event "$name"');
      }

      await prefs.remove(_pendingEventsKey);
      print('📊 Analytics: all deferred events flushed (${pending.length})');
    } catch (e) {
      print('⚠️ Analytics error (flushDeferredEvents): $e');
    }
  }
}
