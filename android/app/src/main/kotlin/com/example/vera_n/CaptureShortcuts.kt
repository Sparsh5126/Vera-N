package com.example.vera_n

import android.content.Context
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build

/**
 * App-icon long-press shortcuts (UI spec §5): New note (always first),
 * Search, and Review connections only while suggestions are waiting.
 * Published at run time rather than in XML so they point at this build's
 * own package. No counts or badges.
 */
object CaptureShortcuts {
    fun publish(context: Context, reviewWaiting: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return
        val manager = context.getSystemService(ShortcutManager::class.java) ?: return
        val list = mutableListOf(
            shortcut(context, "new_note", R.string.shortcut_new_note,
                R.drawable.ic_shortcut_new_note, CaptureIntents.ACTION_NEW_NOTE, 0),
            shortcut(context, "search", R.string.shortcut_search,
                R.drawable.ic_shortcut_search, CaptureIntents.ACTION_SEARCH, 1),
        )
        if (reviewWaiting) {
            list += shortcut(context, "review", R.string.shortcut_review,
                R.drawable.ic_shortcut_review, CaptureIntents.ACTION_REVIEW, 2)
        }
        manager.dynamicShortcuts = list
    }

    private fun shortcut(
        context: Context,
        id: String,
        label: Int,
        icon: Int,
        action: String,
        rank: Int,
    ): ShortcutInfo =
        ShortcutInfo.Builder(context, id)
            .setShortLabel(context.getString(label))
            .setIcon(Icon.createWithResource(context, icon))
            .setIntent(CaptureIntents.open(context, action))
            .setRank(rank)
            .build()
}
