package com.example.vera_n

import android.app.PendingIntent
import android.content.Context
import android.content.Intent

/**
 * The intents that open the app at a capture or shortcut target. They name
 * MainActivity directly, so they work for any application id (the test
 * build's too). [LaunchBridge] turns the action into a Flutter route.
 */
object CaptureIntents {
    const val ACTION_NEW_NOTE = "com.example.vera_n.NEW_NOTE"
    const val ACTION_SEARCH = "com.example.vera_n.SEARCH"
    const val ACTION_REVIEW = "com.example.vera_n.REVIEW"

    /** Flutter route for each action; must match lib/core/navigation/routes.dart. */
    val routes = mapOf(
        ACTION_NEW_NOTE to "/note/new",
        ACTION_SEARCH to "/search",
        ACTION_REVIEW to "/review",
    )

    fun open(context: Context, action: String): Intent =
        Intent(context, MainActivity::class.java)
            .setAction(action)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)

    /** For widgets and the tile: opens a blank note. */
    fun newNote(context: Context, requestCode: Int): PendingIntent =
        PendingIntent.getActivity(
            context,
            requestCode,
            open(context, ACTION_NEW_NOTE),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
}
