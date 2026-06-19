package com.emilzulufov.flutter_instagram_offline_first_clone

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.common.InputImage
import android.graphics.Bitmap
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val snapshotRequestCode = 52051
    private var pendingSnapshotResult: MethodChannel.Result? = null
    private var activeProjection: MediaProjection? = null
    private var activeProjectionCallback: android.media.projection.MediaProjection.Callback? = null
    private var activeVirtualDisplay: VirtualDisplay? = null
    private var activeImageReader: ImageReader? = null
    private var pendingSocialTarget: PendingSocialTarget? = null
    private var lastApprovedSocialOcrResult: Map<String, Any>? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private data class PendingSocialTarget(
        val packageName: String,
        val fallbackUrl: String,
        val label: String
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cidentia.live/social_translate_snapshot"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSingleSnapshotPreview" -> startSingleSnapshotPreview(result)
                "getLastApprovedSocialOcrResult" ->
                    result.success(
                        readCachedApprovedSocialOcrResult() ?: safeSnapshotResponse(
                            ok = false,
                            code = "SOCIAL_TRANSLATE_NO_CACHED_RESULT",
                            message = "No approved OCR result has been cached yet."
                        )
                    )
                "startApprovedSocialOcrPreview" -> startApprovedSocialOcrPreview(
                    packageName = call.argument<String>("packageName") ?: "",
                    fallbackUrl = call.argument<String>("fallbackUrl") ?: "",
                    label = call.argument<String>("label") ?: "social app",
                    result = result
                )
                "openSocialApp" -> openSocialApp(
                    packageName = call.argument<String>("packageName") ?: "",
                    fallbackUrl = call.argument<String>("fallbackUrl") ?: "",
                    label = call.argument<String>("label") ?: "social app",
                    result = result
                )
                else -> result.notImplemented()
            }
        }
    }



    private fun startApprovedSocialOcrPreview(
        packageName: String,
        fallbackUrl: String,
        label: String,
        result: MethodChannel.Result
    ) {
        if (pendingSnapshotResult != null) {
            result.success(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_ALREADY_PENDING",
                    message = "A snapshot consent flow is already pending."
                )
            )
            return
        }

        clearCachedApprovedSocialOcrResult()

        pendingSnapshotResult = result
        pendingSocialTarget = PendingSocialTarget(packageName, fallbackUrl, label)

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                as MediaProjectionManager

        startActivityForResult(
            projectionManager.createScreenCaptureIntent(),
            snapshotRequestCode
        )
    }

    private fun launchPendingSocialTarget() {
        val target = pendingSocialTarget ?: return

        try {
            val launchIntent = if (target.packageName.isNotBlank()) {
                packageManager.getLaunchIntentForPackage(target.packageName)
            } else {
                null
            }

            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launchIntent)
                return
            }

            if (target.fallbackUrl.isNotBlank()) {
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(target.fallbackUrl))
                webIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(webIntent)
            }
        } catch (_: Throwable) {
        }
    }

    private fun openSocialApp(
        packageName: String,
        fallbackUrl: String,
        label: String,
        result: MethodChannel.Result
    ) {
        try {
            val launchIntent = if (packageName.isNotBlank()) {
                packageManager.getLaunchIntentForPackage(packageName)
            } else {
                null
            }

            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launchIntent)
                result.success(
                    socialAppResponse(
                        ok = true,
                        code = "SOCIAL_APP_OPENED",
                        message = "$label was opened. User remains in control."
                    )
                )
                return
            }

            if (fallbackUrl.isNotBlank()) {
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(fallbackUrl))
                webIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(webIntent)
                result.success(
                    socialAppResponse(
                        ok = true,
                        code = "SOCIAL_APP_FALLBACK_OPENED",
                        message = "$label app was not found. Fallback link was opened."
                    )
                )
                return
            }

            result.success(
                socialAppResponse(
                    ok = false,
                    code = "SOCIAL_APP_NOT_FOUND",
                    message = "$label could not be opened."
                )
            )
        } catch (error: Throwable) {
            result.success(
                socialAppResponse(
                    ok = false,
                    code = "SOCIAL_APP_OPEN_FAILED",
                    message = error.message ?: "$label could not be opened."
                )
            )
        }
    }

    private fun socialAppResponse(
        ok: Boolean,
        code: String,
        message: String
    ): Map<String, Any> {
        return mapOf(
            "ok" to ok,
            "code" to code,
            "message" to message,
            "loginAttempted" to false,
            "ocrStarted" to false,
            "overlayOpened" to false,
            "automaticSend" to false,
            "backendUpload" to false
        )
    }

    private fun startMediaProjectionForegroundService() {
        try {
            val intent = Intent(this, CidentiaMediaProjectionService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } catch (_: Throwable) {
        }
    }

    private fun stopMediaProjectionForegroundService() {
        try {
            stopService(Intent(this, CidentiaMediaProjectionService::class.java))
        } catch (_: Throwable) {
        }
    }

    private fun startSingleSnapshotPreview(result: MethodChannel.Result) {
        if (pendingSnapshotResult != null) {
            result.success(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_ALREADY_PENDING",
                    message = "A snapshot consent flow is already pending."
                )
            )
            return
        }

        pendingSocialTarget = null

        pendingSnapshotResult = result

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                as MediaProjectionManager

        startActivityForResult(
            projectionManager.createScreenCaptureIntent(),
            snapshotRequestCode
        )
    }

    @Deprecated("Deprecated in Java")
    private fun beginMediaProjectionAfterForegroundService(
        resultCode: Int,
        data: Intent
    ) {
        try {
            val projectionManager =
                getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                    as MediaProjectionManager

            val projection = projectionManager.getMediaProjection(resultCode, data)

            if (projection == null) {
                completeSnapshot(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_SNAPSHOT_PROJECTION_NULL",
                        message = "Android did not return a MediaProjection instance."
                    )
                )
                return
            }

            activeProjection = projection

            if (pendingSocialTarget != null) {
                launchPendingSocialTarget()
                mainHandler.postDelayed({ captureOneFrame(projection) }, 1800)
            } else {
                captureOneFrame(projection)
            }
        } catch (error: Throwable) {
            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_START_FAILED",
                    message = error.message ?: "Could not start approved snapshot."
                )
            )
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != snapshotRequestCode) {
            return
        }

        if (resultCode != Activity.RESULT_OK || data == null) {
            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_CANCELLED",
                    message = "Screen capture was cancelled by the user."
                )
            )
            return
        }

        try {
            startMediaProjectionForegroundService()
            mainHandler.postDelayed({
                beginMediaProjectionAfterForegroundService(resultCode, data)
            }, 650)
        } catch (error: Throwable) {
            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_START_FAILED",
                    message = error.message ?: "Could not start foreground capture service."
                )
            )
        }
    }

    private fun registerProjectionCallback(
        projection: android.media.projection.MediaProjection
    ) {
        try {
            activeProjectionCallback?.let { projection.unregisterCallback(it) }
        } catch (_: Throwable) {
        }

        val callback = object : android.media.projection.MediaProjection.Callback() {
            override fun onStop() {
                releaseSnapshotResources(stopProjection = false)
                stopMediaProjectionForegroundService()
            }
        }

        activeProjectionCallback = callback
        projection.registerCallback(callback, mainHandler)
    }

    private fun captureOneFrame(
        projection: android.media.projection.MediaProjection
    ) {
        try {
            registerProjectionCallback(projection)

            val metrics = resources.displayMetrics
            val snapshotWidth = metrics.widthPixels.coerceAtLeast(1)
            val snapshotHeight = metrics.heightPixels.coerceAtLeast(1)
            val density = metrics.densityDpi

            val imageReader = ImageReader.newInstance(
                snapshotWidth,
                snapshotHeight,
                PixelFormat.RGBA_8888,
                2
            )

            activeImageReader = imageReader
            var completed = false

            imageReader.setOnImageAvailableListener(listener@{ reader ->
                if (completed) {
                    return@listener
                }

                val image = try {
                    reader.acquireLatestImage()
                } catch (_: Throwable) {
                    null
                } ?: return@listener

                completed = true

                try {
                    activeImageReader?.setOnImageAvailableListener(null, null)
                } catch (_: Throwable) {
                }

                val capturedWidth = image.width
                val capturedHeight = image.height

                if (pendingSocialTarget != null) {
                    recognizeTextFromImage(
                        image = image,
                        capturedWidth = capturedWidth,
                        capturedHeight = capturedHeight
                    )
                } else {
                    image.close()

                    completeSnapshot(
                        safeSnapshotResponse(
                            ok = true,
                            code = "SOCIAL_TRANSLATE_SINGLE_SNAPSHOT_CAPTURED",
                            message = "One user-approved snapshot was captured and released.",
                            screenCaptured = true,
                            snapshotWidth = capturedWidth,
                            snapshotHeight = capturedHeight
                        )
                    )
                }
            }, mainHandler)

            activeVirtualDisplay = projection.createVirtualDisplay(
                "CidentiaSocialTranslateSnapshot",
                snapshotWidth,
                snapshotHeight,
                density,
                android.hardware.display.DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageReader.surface,
                null,
                mainHandler
            )

            mainHandler.postDelayed({
                if (!completed) {
                    completed = true

                    completeSnapshot(
                        safeSnapshotResponse(
                            ok = false,
                            code = "SOCIAL_TRANSLATE_SNAPSHOT_TIMEOUT",
                            message = "No screen frame was received from the approved capture session."
                        )
                    )
                }
            }, 9000)
        } catch (error: Throwable) {
            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_CAPTURE_FAILED",
                    message = error.message ?: "Could not capture approved snapshot."
                )
            )
        }
    }


    private fun recognizeTextFromImage(
        image: android.media.Image,
        capturedWidth: Int,
        capturedHeight: Int
    ) {
        var bitmap: Bitmap? = null
        val openedApp = pendingSocialTarget?.label ?: ""

        try {
            bitmap = bitmapFromImage(image)
            image.close()

            val inputImage = InputImage.fromBitmap(bitmap, 0)
            val recognizer =
                TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

            recognizer.process(inputImage)
                .addOnSuccessListener { recognizedText ->
                    val text = recognizedText.text.trim()
                    val preview = text
                        .lineSequence()
                        .filter { it.isNotBlank() }
                        .take(8)
                        .joinToString("\n")
                        .ifBlank { "No readable text was detected." }

                    completeSnapshot(
                        safeSnapshotResponse(
                            ok = true,
                            code = "SOCIAL_TRANSLATE_OCR_PREVIEW_READY",
                            message = "Approved snapshot OCR preview is ready.",
                            screenCaptured = true,
                            snapshotWidth = capturedWidth,
                            snapshotHeight = capturedHeight,
                            ocrStarted = true,
                            ocrText = text,
                            ocrPreview = preview,
                            openedSocialApp = openedApp
                        )
                    )
                }
                .addOnFailureListener { error ->
                    completeSnapshot(
                        safeSnapshotResponse(
                            ok = false,
                            code = "SOCIAL_TRANSLATE_OCR_FAILED",
                            message = error.message ?: "OCR failed.",
                            screenCaptured = true,
                            snapshotWidth = capturedWidth,
                            snapshotHeight = capturedHeight,
                            ocrStarted = true,
                            openedSocialApp = openedApp
                        )
                    )
                }
                .addOnCompleteListener {
                    try {
                        bitmap?.recycle()
                    } catch (_: Throwable) {
                    }
                }
        } catch (error: Throwable) {
            try {
                image.close()
            } catch (_: Throwable) {
            }

            try {
                bitmap?.recycle()
            } catch (_: Throwable) {
            }

            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_OCR_PREP_FAILED",
                    message = error.message ?: "Could not prepare OCR image.",
                    screenCaptured = true,
                    snapshotWidth = capturedWidth,
                    snapshotHeight = capturedHeight,
                    ocrStarted = true,
                    openedSocialApp = openedApp
                )
            )
        }
    }

    private fun bitmapFromImage(image: android.media.Image): Bitmap {
        val plane = image.planes.firstOrNull()
            ?: throw IllegalStateException("Snapshot image has no plane.")

        val buffer = plane.buffer
        buffer.rewind()

        val pixelStride = plane.pixelStride.coerceAtLeast(1)
        val rowStride = plane.rowStride
        val rowPadding = rowStride - pixelStride * image.width
        val bitmapWidth = image.width + rowPadding / pixelStride

        val bitmap = Bitmap.createBitmap(
            bitmapWidth.coerceAtLeast(image.width),
            image.height,
            Bitmap.Config.ARGB_8888
        )

        bitmap.copyPixelsFromBuffer(buffer)

        if (bitmap.width == image.width) {
            return bitmap
        }

        val cropped = Bitmap.createBitmap(bitmap, 0, 0, image.width, image.height)
        bitmap.recycle()
        return cropped
    }


    private fun clearCachedApprovedSocialOcrResult() {
        lastApprovedSocialOcrResult = null

        try {
            getSharedPreferences(
                "cidentia_social_translate",
                Context.MODE_PRIVATE
            )
                .edit()
                .remove("lastApprovedSocialOcrResult")
                .apply()
        } catch (_: Throwable) {
        }
    }

    private fun cacheApprovedSocialOcrResult(response: Map<String, Any>) {
        lastApprovedSocialOcrResult = response

        try {
            val json = JSONObject()
            response.forEach { entry ->
                json.put(entry.key, entry.value)
            }

            getSharedPreferences(
                "cidentia_social_translate",
                Context.MODE_PRIVATE
            )
                .edit()
                .putString("lastApprovedSocialOcrResult", json.toString())
                .apply()
        } catch (_: Throwable) {
        }
    }

    private fun readCachedApprovedSocialOcrResult(): Map<String, Any>? {
        lastApprovedSocialOcrResult?.let { return it }

        return try {
            val raw = getSharedPreferences(
                "cidentia_social_translate",
                Context.MODE_PRIVATE
            ).getString("lastApprovedSocialOcrResult", null)
                ?: return null

            val json = JSONObject(raw)
            val result = mutableMapOf<String, Any>()
            val keys = json.keys()

            while (keys.hasNext()) {
                val key = keys.next()
                val value = json.get(key)
                if (value != JSONObject.NULL) {
                    result[key] = value
                }
            }

            lastApprovedSocialOcrResult = result
            result
        } catch (_: Throwable) {
            null
        }
    }

    private fun completeSnapshot(response: Map<String, Any>) {
        cacheApprovedSocialOcrResult(response)

        val result = pendingSnapshotResult
        pendingSnapshotResult = null
        pendingSocialTarget = null
        releaseSnapshotResources(stopProjection = true)
        stopMediaProjectionForegroundService()
        result?.success(response)
    }

    private fun releaseSnapshotResources(stopProjection: Boolean) {
        try {
            activeImageReader?.setOnImageAvailableListener(null, null)
        } catch (_: Throwable) {
        }

        try {
            activeVirtualDisplay?.release()
        } catch (_: Throwable) {
        }

        try {
            activeImageReader?.close()
        } catch (_: Throwable) {
        }

        if (stopProjection) {
            try {
                activeProjection?.stop()
            } catch (_: Throwable) {
            }
        }

        activeVirtualDisplay = null
        activeImageReader = null
        activeProjection = null
    }

    private fun safeSnapshotResponse(
        ok: Boolean,
        code: String,
        message: String,
        screenCaptured: Boolean = false,
        snapshotWidth: Int = 0,
        snapshotHeight: Int = 0,
        ocrStarted: Boolean = false,
        ocrText: String = "",
        ocrPreview: String = "",
        openedSocialApp: String = ""
    ): Map<String, Any> {
        return mapOf(
            "ok" to ok,
            "code" to code,
            "message" to message,
            "mediaProjectionOpened" to ok,
            "screenCaptured" to screenCaptured,
            "snapshotWidth" to snapshotWidth,
            "snapshotHeight" to snapshotHeight,
            "ocrStarted" to ocrStarted,
            "ocrText" to ocrText,
            "ocrPreview" to ocrPreview,
            "openedSocialApp" to openedSocialApp,
            "overlayOpened" to false,
            "automaticSend" to false,
            "snapshotStored" to false,
            "backendUpload" to false
        )
    }

}
