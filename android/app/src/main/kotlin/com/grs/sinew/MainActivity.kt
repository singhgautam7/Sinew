package com.grs.sinew

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The app's one activity. `com.grs.sinew/platform` answers the one call that
 * needs Android and does not justify a plugin (see lib/core/platform): the app
 * version. Sound, vibration, speech and the ringer mode live in [CueChannel],
 * shared with the timer service's engine.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        CueChannel.shared(this).attach(messenger)
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "appVersion" -> result.success(appVersion())
                else -> result.notImplemented()
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        CueChannel.shared(this).detach(flutterEngine.dartExecutor.binaryMessenger)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun appVersion(): String {
        val info: PackageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(packageName, 0)
        }
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        return "${info.versionName}+$code"
    }

    companion object {
        private const val CHANNEL = "com.grs.sinew/platform"
    }
}
