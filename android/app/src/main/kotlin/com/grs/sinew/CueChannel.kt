package com.grs.sinew

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.speech.tts.TextToSpeech
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

/**
 * Everything a timer cue needs from Android, on the `com.grs.sinew/cues`
 * channel: the five bundled sounds (SoundPool), vibration, spoken cues
 * (TextToSpeech) and the ringer mode, plus a partial wake lock for the
 * running timer.
 *
 * One instance serves the whole process and is attached to two engines: the
 * app's (MainActivity) and the foreground service's (SinewApplication hooks
 * flutter_foreground_task's engine lifecycle). That is the point: the service
 * isolate has no plugin of its own for sound, vibration or voice, so a cue
 * fired with the screen off behaves exactly like one fired in the app.
 *
 * Methods (all run on the platform thread):
 * - load(names: List<String>) -> Boolean   idempotent, loads assets/audio/<name>.wav
 * - play(name: String) -> Boolean
 * - vibrate(pattern: List<Int>)            [wait, on, off, on, ...] in ms
 * - speak(text: String, rate: Double) -> Boolean
 * - stopSpeaking()
 * - ringerMode() -> "normal" | "vibrate" | "silent"
 * - wakeLock(on: Boolean)
 */
class CueChannel private constructor(context: Context) : MethodChannel.MethodCallHandler {
    private val app: Context = context.applicationContext
    private val channels = HashMap<BinaryMessenger, MethodChannel>()

    // Sound.
    private var pool: SoundPool? = null
    private val soundIds = HashMap<String, Int>()
    private val readyIds: MutableSet<Int> = ConcurrentHashMap.newKeySet()

    // Speech. `tts` is null until the first cue asks for it, and again after
    // any failure, so the next cue binds a fresh engine.
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var ttsInitFailed = false
    private var pending: Pair<String, Float>? = null

    private var wake: PowerManager.WakeLock? = null

    private val vibrator: Vibrator? by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (app.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                ?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            app.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    /** Answers calls from [messenger]'s engine until [detach]ed. */
    fun attach(messenger: BinaryMessenger) {
        if (channels.containsKey(messenger)) return
        val channel = MethodChannel(messenger, CHANNEL)
        channel.setMethodCallHandler(this)
        channels[messenger] = channel
    }

    /** Stops answering [messenger]; frees everything once no engine is left. */
    fun detach(messenger: BinaryMessenger) {
        channels.remove(messenger)?.setMethodCallHandler(null)
        if (channels.isEmpty()) release()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "load" -> {
                    val names = call.argument<List<String>>("names") ?: emptyList()
                    result.success(load(names))
                }
                "play" -> result.success(play(call.argument<String>("name") ?: ""))
                "vibrate" -> {
                    val pattern = call.argument<List<Number>>("pattern") ?: emptyList()
                    vibrate(LongArray(pattern.size) { pattern[it].toLong() })
                    result.success(null)
                }
                "speak" -> result.success(
                    speak(
                        call.argument<String>("text") ?: "",
                        (call.argument<Double>("rate") ?: 1.0).toFloat(),
                    ),
                )
                "stopSpeaking" -> {
                    tts?.stop()
                    pending = null
                    result.success(null)
                }
                "ringerMode" -> result.success(ringerMode())
                "wakeLock" -> {
                    setWakeLock(call.argument<Boolean>("on") ?: false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("cue_failed", e.message, null)
        }
    }

    // ---- sound ------------------------------------------------------------

    /**
     * Media usage with sonification content: the cue follows the media volume
     * (not the system stream, which a quiet phone mutes) and never takes audio
     * focus, so the user's music keeps playing. Silent and vibrate modes are
     * honoured by the Dart side, which asks [ringerMode] before every cue.
     */
    private fun load(names: List<String>): Boolean {
        if (pool != null) return true
        val p = SoundPool.Builder()
            .setMaxStreams(MAX_STREAMS)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            .build()
        p.setOnLoadCompleteListener { _, sampleId, status ->
            if (status == 0) readyIds.add(sampleId)
        }
        val loader = FlutterInjector.instance().flutterLoader()
        for (name in names) {
            val key = loader.getLookupKeyForAsset("assets/audio/$name.wav")
            try {
                app.assets.openFd(key).use { fd -> soundIds[name] = p.load(fd, 1) }
            } catch (e: IOException) {
                // A compressed asset cannot be opened as a descriptor: copy it.
                try {
                    val file = File(app.cacheDir, "cue_$name.wav")
                    app.assets.open(key).use { input ->
                        file.outputStream().use { out -> input.copyTo(out) }
                    }
                    soundIds[name] = p.load(file.absolutePath, 1)
                } catch (e2: IOException) {
                    // This one sound stays silent; the others still work.
                }
            }
        }
        pool = p
        return soundIds.isNotEmpty()
    }

    private fun play(name: String): Boolean {
        val id = soundIds[name] ?: return false
        if (!readyIds.contains(id)) return false
        val p = pool ?: return false
        return p.play(id, 1f, 1f, 1, 0, 1f) != 0
    }

    // ---- vibration --------------------------------------------------------

    private fun vibrate(pattern: LongArray) {
        val v = vibrator ?: return
        if (pattern.isEmpty() || !v.hasVibrator()) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            v.vibrate(VibrationEffect.createWaveform(pattern, NO_REPEAT))
        } else {
            @Suppress("DEPRECATION")
            v.vibrate(pattern, NO_REPEAT)
        }
    }

    // ---- speech -----------------------------------------------------------

    /**
     * The engine is bound on the first spoken cue, not at launch: binding runs
     * on the platform thread, and a slow engine there during a cold start is
     * an ANR. The first phrase is spoken once the engine is ready.
     */
    private fun speak(text: String, rate: Float): Boolean {
        if (text.isEmpty()) return false
        val engine = tts
        if (engine == null) {
            pending = text to rate
            startTts()
            return tts != null
        }
        if (!ttsReady) {
            pending = text to rate
            return true
        }
        return speakNow(engine, text, rate)
    }

    private fun startTts() {
        ttsInitFailed = false
        val engine = TextToSpeech(app) { status -> onTtsInit(status) }
        if (ttsInitFailed) {
            // The init callback already ran, and failed, inside the constructor.
            engine.shutdown()
            return
        }
        tts = engine
    }

    private fun onTtsInit(status: Int) {
        val engine = tts
        if (status != TextToSpeech.SUCCESS || engine == null) {
            ttsInitFailed = true
            resetTts()
            return
        }
        engine.language = Locale.getDefault()
        engine.setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .build(),
        )
        ttsReady = true
        pending?.let { (t, r) -> speakNow(engine, t, r) }
        pending = null
    }

    private fun speakNow(engine: TextToSpeech, text: String, rate: Float): Boolean {
        engine.setSpeechRate(rate)
        val ok = engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, UTTERANCE) ==
            TextToSpeech.SUCCESS
        // A dead engine (killed by the system, uninstalled) answers ERROR for
        // ever: drop it so the next cue binds a new one.
        if (!ok) resetTts()
        return ok
    }

    private fun resetTts() {
        tts?.shutdown()
        tts = null
        ttsReady = false
        pending = null
    }

    // ---- ringer and wake lock ----------------------------------------------

    private fun ringerMode(): String {
        val audio = app.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return when (audio.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> "silent"
            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            else -> "normal"
        }
    }

    /**
     * Held only while a timer is counting: the Dart service handler takes it
     * on a running run and drops it on pause or stop. The timeout is a safety
     * net for a crashed isolate, far above any workout.
     */
    private fun setWakeLock(on: Boolean) {
        if (!on) {
            wake?.let { if (it.isHeld) it.release() }
            wake = null
            return
        }
        if (wake?.isHeld == true) return
        val pm = app.getSystemService(Context.POWER_SERVICE) as PowerManager
        wake = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "sinew:timer").apply {
            setReferenceCounted(false)
            acquire(WAKE_TIMEOUT_MS)
        }
    }

    /** Safety net for a service that ends without its Dart side letting go. */
    fun releaseWakeLock() = setWakeLock(false)

    private fun release() {
        setWakeLock(false)
        resetTts()
        pool?.release()
        pool = null
        soundIds.clear()
        readyIds.clear()
    }

    companion object {
        const val CHANNEL = "com.grs.sinew/cues"
        private const val UTTERANCE = "sinew"
        private const val MAX_STREAMS = 4
        private const val NO_REPEAT = -1
        private const val WAKE_TIMEOUT_MS = 6L * 60 * 60 * 1000

        @Volatile
        private var instance: CueChannel? = null

        fun shared(context: Context): CueChannel =
            instance ?: synchronized(this) {
                instance ?: CueChannel(context).also { instance = it }
            }
    }
}
