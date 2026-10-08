package com.example.vera_n

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * The `vera_n/export` channel: saves a file the app made (the notes .zip)
 * where the user chooses, with Android's own "save as" screen. The app
 * gets access to that one new file only. Copying runs off the UI thread.
 */
class ExportBridge(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "vera_n/export"
        const val SAVE_REQUEST = 4218
    }

    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pending: Pair<File, MethodChannel.Result>? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "save") return result.notImplemented()
        val file = File(call.argument<String>("file") ?: return result.success(false))
        pending?.second?.success(false)
        pending = file to result
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = call.argument<String>("mime") ?: "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: file.name)
        }
        activity.startActivityForResult(intent, SAVE_REQUEST)
    }

    /**
     * Called from [MainActivity.onActivityResult]. Returns true if handled.
     * Replies true once the file is saved, false if the user backed out,
     * or an error if writing failed.
     */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != SAVE_REQUEST) return false
        val (file, result) = pending ?: return true
        pending = null
        val target = data?.data
        if (resultCode != Activity.RESULT_OK || target == null) {
            result.success(false)
            return true
        }
        io.execute {
            val copied = runCatching { copy(file, target) }
            main.post {
                copied.fold(
                    onSuccess = { result.success(true) },
                    onFailure = { result.error("io", it.message, null) },
                )
            }
        }
        return true
    }

    private fun copy(file: File, target: Uri) {
        val out = activity.contentResolver.openOutputStream(target, "wt")
            ?: throw IllegalStateException("can't open the chosen file")
        out.use { stream -> file.inputStream().use { it.copyTo(stream) } }
    }
}
