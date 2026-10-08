package com.example.vera_n

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// A fragment activity: the system fingerprint / PIN prompt for the Locked
// folder (local_auth) needs one.
class MainActivity : FlutterFragmentActivity() {
    private var notesFolder: NotesFolderBridge? = null
    private var launch: LaunchBridge? = null
    private var export: ExportBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // New note and Search; Dart adds Review when suggestions wait.
        CaptureShortcuts.publish(this, reviewWaiting = false)
        CaptureWidget.refreshAll(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val folderBridge = NotesFolderBridge(this)
        notesFolder = folderBridge
        MethodChannel(messenger, NotesFolderBridge.CHANNEL).setMethodCallHandler(folderBridge)

        val launchChannel = MethodChannel(messenger, LaunchBridge.CHANNEL)
        val launchBridge = LaunchBridge(this, launchChannel)
        launch = launchBridge
        launchChannel.setMethodCallHandler(launchBridge)

        val exportBridge = ExportBridge(this)
        export = exportBridge
        MethodChannel(messenger, ExportBridge.CHANNEL).setMethodCallHandler(exportBridge)
    }

    /** Entry points (shortcuts, widgets, tile) start straight at their screen. */
    override fun getInitialRoute(): String? =
        LaunchBridge.routeFor(intent) ?: super.getInitialRoute()

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
        if (export?.onActivityResult(requestCode, resultCode, data) == true) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }
}
