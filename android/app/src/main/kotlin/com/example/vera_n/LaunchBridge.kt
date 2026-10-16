package com.example.vera_n

import android.app.Activity
import android.app.StatusBarManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Process
import android.os.SystemClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The `vera_n/launch` channel: capture and shortcut entry points (app
 * shortcuts, widgets, Quick Settings tile, links shared to the app), the
 * add prompts for widgets and the tile, opening a link card's address in
 * the browser, startup timing, and the app version for Settings.
 */
class LaunchBridge(
    private val activity: Activity,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "vera_n/launch"

        /** The Flutter route an entry point opens, or null for a normal start. */
        fun routeFor(intent: Intent?): String? =
            if (intent?.action == CaptureIntents.ACTION_SHARED) CaptureIntents.sharedRoute(intent)
            else CaptureIntents.routes[intent?.action]
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Milliseconds since this process started, for the startup log.
            "sinceProcessStart" ->
                result.success(SystemClock.uptimeMillis() - Process.getStartUptimeMillis())
            // Where the sync engine (libsyncthingnative.so) was installed.
            "nativeLibraryDir" -> result.success(activity.applicationInfo.nativeLibraryDir)
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
            "openLink" -> result.success(openLink(call.arguments as String))
            else -> result.notImplemented()
        }
    }

    /**
     * Hands a web address to the browser (or the app that handles it).
     * Vera N itself never goes online, so it needs no internet permission.
     */
    private fun openLink(url: String): Boolean {
        val uri = Uri.parse(url)
        if (uri.scheme != "http" && uri.scheme != "https") return false
        return try {
            activity.startActivity(
                Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE),
            )
            true
        } catch (e: ActivityNotFoundException) {
            false
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
