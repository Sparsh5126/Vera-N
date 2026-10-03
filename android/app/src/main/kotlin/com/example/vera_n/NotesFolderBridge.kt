package com.example.vera_n

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * The `vera_n/notes_folder` channel: pick the notes folder with Android's
 * own picker, and read/write files inside it. File work runs on one
 * background thread, so calls never block the UI or overlap.
 */
class NotesFolderBridge(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "vera_n/notes_folder"
        const val PICK_REQUEST = 4217
        private const val EXTERNAL_STORAGE = "com.android.externalstorage.documents"
    }

    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingPick: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "pick") return pick(result)
        io.execute {
            val reply = runCatching { run(call) }
            main.post {
                reply.fold(
                    // Calls with no result (move, delete) return Unit, which
                    // the channel can't send: reply null instead.
                    onSuccess = { result.success(if (it is Unit) null else it) },
                    onFailure = { result.error("io", it.message, null) },
                )
            }
        }
    }

    private fun run(call: MethodCall): Any? {
        val tree = Uri.parse(call.argument<String>("tree"))
        val docs = SafDocuments(activity.contentResolver, tree)
        val path = call.argument<String>("path") ?: ""
        return when (call.method) {
            "hasAccess" -> docs.hasAccess()
            "displayName" -> docs.displayName()
            "list" -> docs.listMarkdown(path)
            "stat" -> docs.stat(path)
            "read" -> docs.read(path)
            "write" -> docs.write(path, call.argument<String>("content") ?: "")
            "move" -> docs.move(path, call.argument<String>("to") ?: "")
            "delete" -> docs.delete(path)
            else -> throw IllegalArgumentException("unknown method ${call.method}")
        }
    }

    private fun pick(result: MethodChannel.Result) {
        pendingPick?.success(null)
        pendingPick = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION,
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val documents = DocumentsContract.buildDocumentUri(EXTERNAL_STORAGE, "primary:Documents")
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, documents)
            }
        }
        activity.startActivityForResult(intent, PICK_REQUEST)
    }

    /** Called from [MainActivity.onActivityResult]. Returns true if handled. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_REQUEST) return false
        val result = pendingPick ?: return true
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        activity.contentResolver.takePersistableUriPermission(uri, flags)
        result.success(uri.toString())
        return true
    }
}
