package com.example.vera_n

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var notesFolder: NotesFolderBridge? = null
    private var launch: LaunchBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val folderBridge = NotesFolderBridge(this)
        notesFolder = folderBridge
        MethodChannel(messenger, NotesFolderBridge.CHANNEL).setMethodCallHandler(folderBridge)

        val launchChannel = MethodChannel(messenger, LaunchBridge.CHANNEL)
        val launchBridge = LaunchBridge(launchChannel)
        launch = launchBridge
        launchChannel.setMethodCallHandler(launchBridge)
    }

    /** Capture entry points start straight in a new note. */
    override fun getInitialRoute(): String? =
        if (LaunchBridge.isNewNote(intent)) LaunchBridge.NEW_NOTE_ROUTE else super.getInitialRoute()

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        launch?.onWindowFocusChanged(hasFocus)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        launch?.onNewIntent(intent)
    }

    @Deprecated("FlutterActivity is not a ComponentActivity; this is its result hook.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (notesFolder?.onActivityResult(requestCode, resultCode, data) == true) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }
}
