package com.example.vera_n

import android.content.Intent
import android.os.Process
import android.os.SystemClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The `vera_n/launch` channel: capture entry points (app shortcut now;
 * widget and Quick Settings tile later) and startup timing.
 */
class LaunchBridge(private val channel: MethodChannel) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "vera_n/launch"
        const val ACTION_NEW_NOTE = "com.example.vera_n.NEW_NOTE"
        const val NEW_NOTE_ROUTE = "/note/new"

        fun isNewNote(intent: Intent?): Boolean = intent?.action == ACTION_NEW_NOTE
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Milliseconds since this process started, for the startup log.
            "sinceProcessStart" ->
                result.success(SystemClock.uptimeMillis() - Process.getStartUptimeMillis())
            else -> result.notImplemented()
        }
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

    /** A capture entry point was used while the app was already running. */
    fun onNewIntent(intent: Intent) {
        if (isNewNote(intent)) channel.invokeMethod("newNote", null)
    }
}
