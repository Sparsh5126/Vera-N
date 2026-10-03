package com.example.vera_n

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var notesFolder: NotesFolderBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val bridge = NotesFolderBridge(this)
        notesFolder = bridge
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NotesFolderBridge.CHANNEL)
            .setMethodCallHandler(bridge)
    }

    @Deprecated("FlutterActivity is not a ComponentActivity; this is its result hook.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (notesFolder?.onActivityResult(requestCode, resultCode, data) == true) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }
}
