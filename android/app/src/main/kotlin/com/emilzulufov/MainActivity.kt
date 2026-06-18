package com.emilzulufov.flutter_instagram_offline_first_clone

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val snapshotRequestCode = 52051
    private var pendingSnapshotResult: MethodChannel.Result? = null
    private var activeProjection: MediaProjection? = null
    private var activeVirtualDisplay: VirtualDisplay? = null
    private var activeImageReader: ImageReader? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cidentia.live/social_translate_snapshot"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSingleSnapshotPreview" -> startSingleSnapshotPreview(result)
                else -> result.notImplemented()
            }
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
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        if (requestCode != snapshotRequestCode) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        if (resultCode != Activity.RESULT_OK || data == null) {
            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_CANCELLED",
                    message = "The user cancelled Android screen capture consent."
                )
            )
            return
        }

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
                        message = "Android returned no MediaProjection instance."
                    )
                )
                return
            }

            activeProjection = projection
            projection.registerCallback(
                object : MediaProjection.Callback() {
                    override fun onStop() {
                        releaseSnapshotResources(stopProjection = false)
                    }
                },
                mainHandler
            )

            captureOneFrame(projection)
        } catch (error: Throwable) {
            completeSnapshot(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_START_FAILED",
                    message = error.message ?: "Failed to start one-shot capture."
                )
            )
        }
    }

    private fun captureOneFrame(projection: MediaProjection) {
        val width: Int
        val height: Int

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = windowManager.currentWindowMetrics.bounds
            width = bounds.width().coerceAtLeast(1)
            height = bounds.height().coerceAtLeast(1)
        } else {
            val metrics = DisplayMetrics()
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(metrics)
            width = metrics.widthPixels.coerceAtLeast(1)
            height = metrics.heightPixels.coerceAtLeast(1)
        }

        val density = resources.configuration.densityDpi
        val reader = ImageReader.newInstance(
            width,
            height,
            PixelFormat.RGBA_8888,
            2
        )

        activeImageReader = reader

        reader.setOnImageAvailableListener({ imageReader ->
            val image = imageReader.acquireLatestImage() ?: return@setOnImageAvailableListener
            val capturedWidth = image.width
            val capturedHeight = image.height
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
        }, mainHandler)

        activeVirtualDisplay = projection.createVirtualDisplay(
            "CidentiaSocialTranslateSingleSnapshot",
            width,
            height,
            density,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            reader.surface,
            null,
            mainHandler
        )

        mainHandler.postDelayed({
            if (pendingSnapshotResult != null) {
                completeSnapshot(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_SNAPSHOT_TIMEOUT",
                        message = "No snapshot frame arrived before timeout."
                    )
                )
            }
        }, 2200)
    }

    private fun completeSnapshot(response: Map<String, Any>) {
        val result = pendingSnapshotResult
        pendingSnapshotResult = null
        releaseSnapshotResources(stopProjection = true)
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
        snapshotHeight: Int = 0
    ): Map<String, Any> {
        return mapOf(
            "ok" to ok,
            "code" to code,
            "message" to message,
            "mediaProjectionOpened" to ok,
            "screenCaptured" to screenCaptured,
            "snapshotWidth" to snapshotWidth,
            "snapshotHeight" to snapshotHeight,
            "ocrStarted" to false,
            "overlayOpened" to false,
            "automaticSend" to false,
            "snapshotStored" to false,
            "backendUpload" to false
        )
    }
}
