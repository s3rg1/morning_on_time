package com.lagunitacrew.native_sound_player

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter plugin that plays Flutter asset sounds using Android's native
 * [MediaPlayer] on the **music** audio stream.
 *
 * Using native [MediaPlayer] instead of the `audioplayers` Flutter package
 * because `audioplayers`' [AssetSource] resolver does not work reliably in
 * the background isolates created by `android_alarm_manager_plus`.
 *
 * Registered as a proper [FlutterPlugin] so it is automatically added to
 * every [FlutterEngine], including the background engine created by
 * `android_alarm_manager_plus` for alarm callbacks.
 */
class NativeSoundPlayerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var flutterAssets: FlutterPlugin.FlutterAssets

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        flutterAssets = binding.flutterAssets
        channel = MethodChannel(
            binding.binaryMessenger,
            "com.lagunitacrew.native_sound_player/player"
        )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "playAsset" -> {
                val assetPath = call.argument<String>("assetPath")
                if (assetPath == null) {
                    result.error("INVALID_ARG", "assetPath is required", null)
                    return
                }
                try {
                    // Resolve Flutter asset key to the real path inside the APK
                    val key = flutterAssets.getAssetFilePathByName(assetPath)
                    val afd = context.assets.openFd(key)

                    val player = MediaPlayer().apply {
                        setAudioAttributes(
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_MEDIA)
                                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                .build()
                        )
                        setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                        prepare()
                        start()
                        setOnCompletionListener { mp -> mp.release() }
                        setOnErrorListener { mp, _, _ -> mp.release(); true }
                    }

                    afd.close()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("PLAY_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
