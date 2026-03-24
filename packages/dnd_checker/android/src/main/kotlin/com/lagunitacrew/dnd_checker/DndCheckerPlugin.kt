package com.lagunitacrew.dnd_checker

import android.app.NotificationManager
import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter plugin that checks whether the app should suppress audio playback.
 *
 * Returns `true` (suppress audio) when:
 * - **DND is active**: any interruption filter other than `INTERRUPTION_FILTER_ALL`
 * - **Phone/VoIP call is active**: `AudioManager.getMode()` reports `MODE_IN_CALL`,
 *   `MODE_IN_COMMUNICATION`, or `MODE_RINGTONE`
 *
 * The `AudioManager.getMode()` check requires **no permissions** and covers both
 * regular phone calls and VoIP calls (WhatsApp, Zoom, Teams, etc.).
 *
 * Registered as a proper [FlutterPlugin] so it is automatically added to
 * every [FlutterEngine], including the background engine created by
 * `android_alarm_manager_plus` for alarm callbacks.
 */
class DndCheckerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(
            binding.binaryMessenger,
            "com.lagunitacrew.dnd_checker/dnd"
        )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isDndActive" -> {
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE)
                    as NotificationManager
                val filter = nm.currentInterruptionFilter
                // INTERRUPTION_FILTER_ALL (1) means DND is OFF — all sounds allowed.
                // Any other value means some form of DND is active.
                val dndActive = filter != NotificationManager.INTERRUPTION_FILTER_ALL

                // Check if the user is on a phone or VoIP call.
                // AudioManager.getMode() requires no permissions.
                val audioManager = context.getSystemService(Context.AUDIO_SERVICE)
                    as AudioManager
                val audioMode = audioManager.mode
                val inCall = audioMode == AudioManager.MODE_IN_CALL ||
                    audioMode == AudioManager.MODE_IN_COMMUNICATION ||
                    audioMode == AudioManager.MODE_RINGTONE

                result.success(dndActive || inCall)
            }
            else -> result.notImplemented()
        }
    }
}
