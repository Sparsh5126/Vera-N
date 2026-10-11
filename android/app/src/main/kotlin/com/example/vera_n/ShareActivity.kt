package com.example.vera_n

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * The "Share → Vera N" target for text and links. It has no screen: it
 * passes what was shared to [MainActivity], the way widgets and the tile
 * open it, so the app runs once (one database), then closes.
 */
class ShareActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val shared = intent
        if (shared?.action == Intent.ACTION_SEND && shared.type == "text/plain") {
            startActivity(
                CaptureIntents.open(this, CaptureIntents.ACTION_SHARED)
                    .putExtra(Intent.EXTRA_TEXT, shared.getStringExtra(Intent.EXTRA_TEXT))
                    .putExtra(Intent.EXTRA_SUBJECT, shared.getStringExtra(Intent.EXTRA_SUBJECT)),
            )
        }
        finish()
    }
}
