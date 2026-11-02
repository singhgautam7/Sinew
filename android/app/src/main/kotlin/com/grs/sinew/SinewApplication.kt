package com.grs.sinew

import android.app.Application
import android.content.Context
import com.pravera.flutter_foreground_task.FlutterForegroundTaskLifecycleListener
import com.pravera.flutter_foreground_task.FlutterForegroundTaskPlugin
import com.pravera.flutter_foreground_task.FlutterForegroundTaskStarter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger

/**
 * Registers the cue channel on the timer service's Flutter engine.
 *
 * flutter_foreground_task creates a fresh FlutterEngine for its background
 * isolate each time the service starts and tells its lifecycle listeners
 * before the Dart entry point runs (`onEngineCreate`). The listener has to be
 * added here, in `Application.onCreate`, because the system can start the
 * service in a new process with no activity at all.
 */
class SinewApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FlutterForegroundTaskPlugin.addTaskLifecycleListener(ServiceCueListener(this))
    }
}

private class ServiceCueListener(private val context: Context) :
    FlutterForegroundTaskLifecycleListener {
    private var messenger: BinaryMessenger? = null

    override fun onEngineCreate(flutterEngine: FlutterEngine?) {
        val m = flutterEngine?.dartExecutor?.binaryMessenger ?: return
        messenger = m
        CueChannel.shared(context).attach(m)
    }

    override fun onTaskStart(starter: FlutterForegroundTaskStarter) {}

    override fun onTaskRepeatEvent() {}

    override fun onTaskDestroy() {}

    override fun onEngineWillDestroy() {
        CueChannel.shared(context).releaseWakeLock()
        messenger?.let { CueChannel.shared(context).detach(it) }
        messenger = null
    }
}
