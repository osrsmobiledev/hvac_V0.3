package com.example.hvac_app

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.hvac_app/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    val mimeType = call.argument<String>("mimeType") ?: "application/pdf"

                    if (fileName == null || bytes == null) {
                        result.error("INVALID_ARGUMENTS", "fileName and bytes must not be null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = saveFileToDownloads(fileName, bytes, mimeType)
                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, e.stackTraceToString())
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveFileToDownloads(fileName: String, bytes: ByteArray, mimeType: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = applicationContext.contentResolver
            val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)

            // Remove existing entry if present to overwrite cleanly without auto-incrementing filenames
            try {
                val selection = "${MediaStore.MediaColumns.DISPLAY_NAME} = ?"
                val selectionArgs = arrayOf(fileName)
                resolver.delete(collection, selection, selectionArgs)
            } catch (_: Exception) {
                // Ignore if not present
            }

            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val itemUri = resolver.insert(collection, contentValues)
                ?: throw IllegalStateException("Failed to create MediaStore entry in Downloads")

            resolver.openOutputStream(itemUri, "wt")?.use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            } ?: throw IllegalStateException("Failed to open MediaStore output stream")

            contentValues.clear()
            contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(itemUri, contentValues, null, null)

            return "/storage/emulated/0/Download/$fileName"
        } else {
            val downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadDir.exists()) {
                downloadDir.mkdirs()
            }
            val file = File(downloadDir, fileName)
            FileOutputStream(file).use { fos ->
                fos.write(bytes)
                fos.flush()
            }
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(file.absolutePath),
                arrayOf(mimeType),
                null
            )
            return file.absolutePath
        }
    }
}
