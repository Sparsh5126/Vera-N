package com.example.vera_n

import android.app.Activity
import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Process
import android.os.SystemClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The `vera_n/launch` channel: capture and shortcut entry points (app
 * shortcuts, widgets, Quick Settings tile), the add prompts for widgets and
 * the tile, startup timing, and the app version for Settings.
 */
class LaunchBridge(
    private val activity: Activity,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "vera_n/launch"

        /** The Flutter route an entry point opens, or null for a normal start. */
        fun routeFor(intent: Intent?): String? = CaptureIntents.routes[intent?.action]
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Milliseconds since this process started, for the startup log.
            "sinceProcessStart" ->
                result.success(SystemClock.uptimeMillis() - Process.getStartUptimeMillis())
            "versionName" -> result.success(
                activity.packageManager.getPackageInfo(activity.packageName, 0).versionName,
            )
            "setReviewShortcut" -> {
                CaptureShortcuts.publish(activity, call.arguments as Boolean)
                result.success(null)
            }
            "addWidget" -> result.success(
                CaptureWidget.requestPin(
                    activity,
                    if (call.arguments == "bar") QuickNoteWidget::class.java
                    else NewNoteWidget::class.java,
                ),
            )
            "addTile" -> result.success(requestTile())
            else -> result.notImplemented()
        }
    }

    /** Android 13+ can ask to add the tile; older versions can't. */
    private fun requestTile(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return false
        val bar = activity.getSystemService(StatusBarManager::class.java) ?: return false
        bar.requestAddTileService(
            ComponentName(activity, NewNoteTileService::class.java),
            activity.getString(R.string.tile_new_note),
            Icon.createWithResource(activity, R.drawable.ic_tile_new_note),
            activity.mainExecutor,
        ) {}
        return true
    }

    private var windowFocusedOnce = false

    /**
     * The window got input focus for the first time in this process. On a
     * cold start Flutter asks for the keyboard before this, and Android
     * ignores that request, so Dart asks again now.
     */
    fun onWindowFocusChanged(hasFocus: Boolean) {
        if (!hasFocus || windowFocusedOnce) return
        windowFocusedOnce = true
        channel.invokeMethod("windowFocused", null)
    }

    /** An entry point was used while the app was already running. */
    fun onNewIntent(intent: Intent) {
        routeFor(intent)?.let { channel.invokeMethod("open", it) }
    }
}
