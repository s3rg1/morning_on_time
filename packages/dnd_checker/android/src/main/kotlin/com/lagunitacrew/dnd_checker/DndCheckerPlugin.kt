package com.lagunitacrew.dnd_checker

import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter plugin that exposes Android's Do Not Disturb (DND) status.
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
                result.success(filter != NotificationManager.INTERRUPTION_FILTER_ALL)
            }
            else -> result.notImplemented()
        }
    }
}
