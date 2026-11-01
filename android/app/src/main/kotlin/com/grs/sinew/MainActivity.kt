package com.grs.sinew

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * The app's one activity. `com.grs.sinew/platform` answers the few calls that
 * need Android and do not justify a plugin (see lib/core/platform):
 * the app version, spoken timer cues through the phone's own TextToSpeech,
 * and the ringer mode so cues respect silent and vibrate.
 */
class MainActivity : FlutterActivity() {
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var pending: Pair<String, Double>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "appVersion" -> result.success(appVersion())
                    "speak" -> {
                        val ok = speak(
                            call.argument<String>("text") ?: "",
                            call.argument<Double>("rate") ?: 1.0,
                        )
                        result.success(ok)
                    }
                    "stopSpeaking" -> {
                        tts?.stop()
                        result.success(null)
                    }
                    "ringerMode" -> result.success(ringerMode())
                    else -> result.notImplemented()
                }
            }
    }

    private fun appVersion(): String {
        val info = packageManager.getPackageInfo(packageName, 0)
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        return "${info.versionName}+$code"
    }

    private fun ringerMode(): String {
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return when (audio.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> "silent"
            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            else -> "normal"
        }
    }

    /**
     * The engine is bound on the first cue, not at launch: binding runs on the
     * platform main thread, and a slow engine there during a cold start is an
     * ANR (Mull's finding). The first phrase is spoken once the engine is ready.
     */
    private fun speak(text: String, rate: Double): Boolean {
        val engine = tts ?: TextToSpeech(this) { status ->
            ttsReady = status == TextToSpeech.SUCCESS
            if (ttsReady) {
                tts?.language = Locale.getDefault()
                pending?.let { (t, r) -> speak(t, r) }
            }
            pending = null
        }.also { tts = it }
        if (!ttsReady) {
            pending = text to rate
            return true
        }
        engine.setSpeechRate(rate.toFloat())
        return engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, "sinew") ==
            TextToSpeech.SUCCESS
    }

    override fun onDestroy() {
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL = "com.grs.sinew/platform"
    }
}
