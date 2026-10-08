package com.example.vera_n

import android.annotation.SuppressLint
import android.os.Build
import android.service.quicksettings.TileService

/**
 * Quick Settings tile "New note" (UI spec §5). Tapping closes the shade and
 * opens a blank note. On a locked phone the user unlocks first: capture
 * never bypasses the lock screen, since notes are private.
 */
class NewNoteTileService : TileService() {
    override fun onClick() {
        super.onClick()
        unlockAndRun { openNewNote() }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun openNewNote() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(CaptureIntents.newNote(this, REQUEST_TILE))
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(
                CaptureIntents.open(this, CaptureIntents.ACTION_NEW_NOTE),
            )
        }
    }

    private companion object {
        const val REQUEST_TILE = 30
    }
}
