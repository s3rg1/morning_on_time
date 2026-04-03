package com.lagunitacrew.native_sound_player

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.view.KeyEvent
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
 *
 * Supports **pausing other media**: call `requestAudioFocus` before playing
 * sounds/TTS to pause the user's music, then `abandonAudioFocus` when done
 * so music resumes automatically.
 *
 * Uses a two-pronged strategy:
 * 1. Try Android audio focus API (`AUDIOFOCUS_GAIN_TRANSIENT`)
 * 2. If focus is denied (common from background isolates), fall back to
 *    dispatching `KEYCODE_MEDIA_PAUSE` via [AudioManager.dispatchMediaKeyEvent]
 *    which directly tells the active media session to pause — like pressing
 *    the pause button on headphones.
 */
class NativeSoundPlayerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var flutterAssets: FlutterPlugin.FlutterAssets

    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null

    /** Tracks whether media was paused via media key event (vs audio focus). */
    private var pausedViaMediaKey = false

    /** Tracks whether music was actually playing when we paused it. */
    private var wasMusicActive = false

    /** No-op listener — required so the system dispatches focus changes to other apps. */
    private val focusChangeListener = AudioManager.OnAudioFocusChangeListener { /* no-op */ }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        flutterAssets = binding.flutterAssets
        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
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
                        // Wait for playback to finish before returning to Dart.
                        // This ensures abandonAudioFocus runs AFTER the sound
                        // completes, not while it's still playing.
                        setOnCompletionListener { mp ->
                            mp.release()
                            result.success(true)
                        }
                        setOnErrorListener { mp, _, _ ->
                            mp.release()
                            result.success(false)
                            true
                        }
                        start()
                    }

                    afd.close()
                } catch (e: Exception) {
                    result.error("PLAY_ERROR", e.message, null)
                }
            }

            "requestAudioFocus" -> {
                try {
                    val am = audioManager
                    if (am == null) {
                        android.util.Log.w("NativeSoundPlayer", "AudioManager is null — cannot request focus")
                        result.success(false)
                        return
                    }

                    // Remember if music is currently playing so we only resume
                    // if we actually interrupted something.
                    wasMusicActive = am.isMusicActive
                    android.util.Log.d("NativeSoundPlayer", "isMusicActive=$wasMusicActive")

                    if (!wasMusicActive) {
                        // No music playing — nothing to pause
                        result.success(true)
                        return
                    }

                    // Strategy 1: Try audio focus API (API 26+)
                    var focusGranted = false
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val attrs = AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()

                        val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                            .setAudioAttributes(attrs)
                            .setOnAudioFocusChangeListener(focusChangeListener)
                            .build()

                        val outcome = am.requestAudioFocus(request)
                        android.util.Log.d("NativeSoundPlayer", "AudioFocus outcome=$outcome (1=granted)")
                        if (outcome == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                            focusRequest = request
                            pausedViaMediaKey = false
                            focusGranted = true
                        }
                    }

                    // Strategy 2: If focus denied (or API < 26), send media
                    // pause key event — this directly tells the active media
                    // session to pause, like pressing pause on headphones.
                    if (!focusGranted) {
                        android.util.Log.d("NativeSoundPlayer", "Focus not granted — falling back to MEDIA_PAUSE key event")
                        sendMediaKeyEvent(am, KeyEvent.KEYCODE_MEDIA_PAUSE)
                        pausedViaMediaKey = true
                    }

                    result.success(true)
                } catch (e: Exception) {
                    android.util.Log.e("NativeSoundPlayer", "requestAudioFocus failed", e)
                    result.error("FOCUS_ERROR", e.message, null)
                }
            }

            "abandonAudioFocus" -> {
                try {
                    val am = audioManager
                    if (!wasMusicActive) {
                        android.util.Log.d("NativeSoundPlayer", "abandonAudioFocus: music was not active — nothing to resume")
                        result.success(true)
                        return
                    }

                    if (pausedViaMediaKey) {
                        // Resume via media key event
                        if (am != null) {
                            android.util.Log.d("NativeSoundPlayer", "Sending MEDIA_PLAY key event — music should resume")
                            sendMediaKeyEvent(am, KeyEvent.KEYCODE_MEDIA_PLAY)
                        }
                        pausedViaMediaKey = false
                    } else {
                        // Resume via audio focus abandon
                        val req = focusRequest
                        if (am != null && req != null) {
                            am.abandonAudioFocusRequest(req)
                            focusRequest = null
                            android.util.Log.d("NativeSoundPlayer", "Audio focus abandoned — music should resume")
                        }
                    }
                    wasMusicActive = false
                    result.success(true)
                } catch (e: Exception) {
                    android.util.Log.e("NativeSoundPlayer", "abandonAudioFocus failed", e)
                    result.error("FOCUS_ERROR", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    /** Dispatches a media button key event (down + up) to the active media session. */
    private fun sendMediaKeyEvent(am: AudioManager, keyCode: Int) {
        val downEvent = KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
        val upEvent = KeyEvent(KeyEvent.ACTION_UP, keyCode)
        am.dispatchMediaKeyEvent(downEvent)
        am.dispatchMediaKeyEvent(upEvent)
    }
}
