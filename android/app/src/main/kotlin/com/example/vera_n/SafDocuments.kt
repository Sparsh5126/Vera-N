package com.example.vera_n

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document

/**
 * File operations inside the folder the user picked (Storage Access
 * Framework). Paths are relative to that folder and `/`-separated.
 *
 * Each folder is listed with one query that returns name, type, time and
 * size together, instead of one query per file.
 */
class SafDocuments(private val resolver: ContentResolver, private val tree: Uri) {
    private data class Child(
        val id: String,
        val name: String,
        val isDir: Boolean,
        val modified: Long,
        val size: Long,
    )

    private val rootId: String = DocumentsContract.getTreeDocumentId(tree)

    fun hasAccess(): Boolean {
        val granted = resolver.persistedUriPermissions.any {
            it.uri == tree && it.isReadPermission && it.isWritePermission
        }
        return granted && runCatching { displayName() != null }.getOrDefault(false)
    }

    fun displayName(): String? =
        query(docUri(rootId), arrayOf(Document.COLUMN_DISPLAY_NAME)) { it.getString(0) }
            .firstOrNull()

    /** Every `.md` file under [dir], skipping names that start with `.`. */
    fun listMarkdown(dir: String): List<Map<String, Any>> {
        val dirId = findDir(segments(dir)) ?: return emptyList()
        val out = mutableListOf<Map<String, Any>>()
        walk(dirId, "", out)
        return out
    }

    fun stat(path: String): Map<String, Any>? = find(path)?.let(::entry)

    fun read(path: String): String {
        val child = find(path) ?: throw IllegalStateException("missing: $path")
        val stream = resolver.openInputStream(docUri(child.id))
            ?: throw IllegalStateException("can't open: $path")
        return stream.use { it.readBytes().toString(Charsets.UTF_8) }
    }

    /** Writes the whole file, creating it and its folders if needed. */
    fun write(path: String, content: String): Map<String, Any> {
        val parts = segments(path)
        val parentId = ensureDir(parts.dropLast(1))
        val name = parts.last()
        val uri = children(parentId).firstOrNull { it.name == name }?.let { docUri(it.id) }
            // octet-stream keeps the exact name; a text type may get an extension added.
            ?: DocumentsContract.createDocument(
                resolver, docUri(parentId), "application/octet-stream", name,
            ) ?: throw IllegalStateException("can't create: $path")
        val stream = resolver.openOutputStream(uri, "wt")
            ?: throw IllegalStateException("can't write: $path")
        stream.use { it.write(content.toByteArray(Charsets.UTF_8)) }
        return stat(path) ?: throw IllegalStateException("not written: $path")
    }

    /** Copies then deletes, which works with every document provider. */
    fun move(from: String, to: String) {
        write(to, read(from))
        delete(from)
    }

    fun delete(path: String) {
        find(path)?.let { DocumentsContract.deleteDocument(resolver, docUri(it.id)) }
    }

    private fun walk(dirId: String, prefix: String, out: MutableList<Map<String, Any>>) {
        for (child in children(dirId)) {
            if (child.name.startsWith(".")) continue
            val path = if (prefix.isEmpty()) child.name else "$prefix/${child.name}"
            if (child.isDir) {
                walk(child.id, path, out)
            } else if (child.name.endsWith(".md")) {
                out.add(entry(child) + ("path" to path))
            }
        }
    }

    private fun entry(child: Child): Map<String, Any> =
        mapOf("modified" to child.modified, "size" to child.size)

    private fun find(path: String): Child? {
        val parts = segments(path)
        val parentId = findDir(parts.dropLast(1)) ?: return null
        return children(parentId).firstOrNull { it.name == parts.last() }
    }

    private fun findDir(parts: List<String>): String? {
        var id = rootId
        for (part in parts) {
            id = children(id).firstOrNull { it.isDir && it.name == part }?.id ?: return null
        }
        return id
    }

    private fun ensureDir(parts: List<String>): String {
        var id = rootId
        for (part in parts) {
            id = children(id).firstOrNull { it.isDir && it.name == part }?.id
                ?: DocumentsContract.createDocument(
                    resolver, docUri(id), Document.MIME_TYPE_DIR, part,
                )?.let(DocumentsContract::getDocumentId)
                ?: throw IllegalStateException("can't create folder: $part")
        }
        return id
    }

    private fun children(parentId: String): List<Child> {
        val uri = DocumentsContract.buildChildDocumentsUriUsingTree(tree, parentId)
        val columns = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_LAST_MODIFIED,
            Document.COLUMN_SIZE,
        )
        return query(uri, columns) {
            Child(
                id = it.getString(0),
                name = it.getString(1),
                isDir = it.getString(2) == Document.MIME_TYPE_DIR,
                modified = it.getLong(3),
                size = it.getLong(4),
            )
        }
    }

    private fun <T> query(uri: Uri, columns: Array<String>, row: (Cursor) -> T): List<T> {
        val cursor = resolver.query(uri, columns, null, null, null) ?: return emptyList()
        return cursor.use { c -> buildList { while (c.moveToNext()) add(row(c)) } }
    }

    private fun docUri(id: String): Uri = DocumentsContract.buildDocumentUriUsingTree(tree, id)

    private fun segments(path: String): List<String> =
        path.split('/').filter { it.isNotEmpty() }
}
