package com.example.vera_n

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.widget.RemoteViews

/**
 * Home-screen widgets (UI spec §5). Each is one tap target that opens a
 * blank note; no data, no loading, nothing to update. Colors follow the
 * system theme through values / values-night.
 */
abstract class CaptureWidget(private val layout: Int, private val request: Int) :
    AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) = draw(context, manager, ids)

    private fun draw(context: Context, manager: AppWidgetManager, ids: IntArray) {
        if (ids.isEmpty()) return
        val views = RemoteViews(context.packageName, layout)
        views.setOnClickPendingIntent(R.id.widget_root, CaptureIntents.newNote(context, request))
        manager.updateAppWidget(ids, views)
    }

    companion object {
        /**
         * Draws every placed widget again. Called when the app starts: if
         * the app was stopped (force stop, some battery savers), Android
         * drops the widget's first update and the launcher shows a blank
         * placeholder until then.
         */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context) ?: return
            for (widget in listOf(QuickNoteWidget(), NewNoteWidget())) {
                val ids = manager.getAppWidgetIds(ComponentName(context, widget.javaClass))
                widget.draw(context, manager, ids)
            }
        }

        /** Asks the launcher to add [provider]; false if it can't ask. */
        fun requestPin(context: Context, provider: Class<out CaptureWidget>): Boolean {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
            val manager = context.getSystemService(AppWidgetManager::class.java) ?: return false
            if (!manager.isRequestPinAppWidgetSupported) return false
            return manager.requestPinAppWidget(ComponentName(context, provider), null, null)
        }
    }
}

/** Quick note bar (4x1): "Write a thought…" with a small amber plus. */
class QuickNoteWidget : CaptureWidget(R.layout.widget_quick_note, 31)

/** New note button (2x1): a large amber plus and "New note". */
class NewNoteWidget : CaptureWidget(R.layout.widget_new_note, 32)
