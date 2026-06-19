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
import android.provider.Settings
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
    private var pendingLiveOcrResult: MethodChannel.Result? = null
    private var pendingLiveOcrTarget: PendingSocialTarget? = null
    private var liveOcrProjection: MediaProjection? = null
    private var liveOcrTarget: PendingSocialTarget? = null
    private var liveOcrRunning = false
    private var liveOcrFrameBusy = false
    private var liveOcrRunnable: Runnable? = null
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
                "requestSocialTranslateOverlayPermission" ->
                    requestSocialTranslateOverlayPermission(result)
                "showSocialTranslateFloatingBubble" ->
                    showSocialTranslateFloatingBubble(
                        text = call.argument<String>("text") ?: "",
                        result = result
                    )
                "hideSocialTranslateFloatingBubble" ->
                    hideSocialTranslateFloatingBubble(result)
                "startLiveSocialOcrLoop" -> startLiveSocialOcrLoop(
                    packageName = call.argument<String>("packageName") ?: "",
                    fallbackUrl = call.argument<String>("fallbackUrl") ?: "",
                    label = call.argument<String>("label") ?: "social app",
                    result = result
                )
                "stopLiveSocialOcrLoop" -> stopLiveSocialOcrLoop(result)
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



    private fun startLiveSocialOcrLoop(
        packageName: String,
        fallbackUrl: String,
        label: String,
        result: MethodChannel.Result
    ) {
        if (pendingSnapshotResult != null || pendingLiveOcrResult != null) {
            result.success(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_SNAPSHOT_ALREADY_PENDING",
                    message = "A screen capture consent flow is already pending."
                )
            )
            return
        }

        if (liveOcrRunning) {
            result.success(
                safeSnapshotResponse(
                    ok = true,
                    code = "SOCIAL_TRANSLATE_LIVE_OCR_LOOP_ALREADY_RUNNING",
                    message = "Live OCR loop is already running.",
                    openedSocialApp = liveOcrTarget?.label ?: label
                )
            )
            return
        }

        clearCachedApprovedSocialOcrResult()

        pendingLiveOcrResult = result
        pendingLiveOcrTarget = PendingSocialTarget(packageName, fallbackUrl, label)

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                as MediaProjectionManager

        startActivityForResult(
            projectionManager.createScreenCaptureIntent(),
            snapshotRequestCode
        )
    }

    private fun stopLiveSocialOcrLoop(result: MethodChannel.Result) {
        liveOcrRunning = false
        liveOcrFrameBusy = false

        liveOcrRunnable?.let { mainHandler.removeCallbacks(it) }
        liveOcrRunnable = null

        try {
            liveOcrProjection?.stop()
        } catch (_: Throwable) {
        }

        liveOcrProjection = null
        liveOcrTarget = null
        pendingLiveOcrResult = null
        pendingLiveOcrTarget = null

        stopMediaProjectionForegroundService()

        result.success(
            safeSnapshotResponse(
                ok = true,
                code = "SOCIAL_TRANSLATE_LIVE_OCR_LOOP_STOPPED",
                message = "Live OCR loop was stopped. Auto send stayed closed."
            )
        )
    }

    private fun completeLiveOcrStart(response: Map<String, Any>) {
        val result = pendingLiveOcrResult
        pendingLiveOcrResult = null
        pendingLiveOcrTarget = null
        result?.success(response)
    }

    private fun beginLiveOcrLoopAfterForegroundService(
        resultCode: Int,
        data: Intent
    ) {
        try {
            val projectionManager =
                getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                    as MediaProjectionManager

            val projection = projectionManager.getMediaProjection(resultCode, data)

            if (projection == null) {
                completeLiveOcrStart(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_LIVE_OCR_PROJECTION_NULL",
                        message = "Android did not return a MediaProjection instance."
                    )
                )
                stopMediaProjectionForegroundService()
                return
            }

            liveOcrProjection = projection
            liveOcrTarget = pendingLiveOcrTarget
            liveOcrRunning = true
            liveOcrFrameBusy = false

            registerProjectionCallback(projection)
            launchLiveOcrTarget()

            val openedLabel = liveOcrTarget?.label ?: ""

            completeLiveOcrStart(
                safeSnapshotResponse(
                    ok = true,
                    code = "SOCIAL_TRANSLATE_LIVE_OCR_LOOP_STARTED",
                    message = "Live OCR loop started. Visible screen only. Auto send stayed closed.",
                    openedSocialApp = openedLabel
                )
            )

            scheduleLiveOcrFrame(1800)
        } catch (error: Throwable) {
            liveOcrRunning = false
            completeLiveOcrStart(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_LIVE_OCR_START_FAILED",
                    message = error.message ?: "Could not start live OCR loop."
                )
            )
            stopMediaProjectionForegroundService()
        }
    }

    private fun launchLiveOcrTarget() {
        val target = liveOcrTarget ?: return

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

    private fun scheduleLiveOcrFrame(delayMs: Long = 3000) {
        if (!liveOcrRunning) {
            return
        }

        liveOcrRunnable?.let { mainHandler.removeCallbacks(it) }

        val runnable = Runnable {
            captureOneLiveOcrFrame()
        }

        liveOcrRunnable = runnable
        mainHandler.postDelayed(runnable, delayMs)
    }

    private fun captureOneLiveOcrFrame() {
        if (!liveOcrRunning || liveOcrFrameBusy) {
            scheduleLiveOcrFrame()
            return
        }

        val projection = liveOcrProjection
        if (projection == null) {
            liveOcrRunning = false
            stopMediaProjectionForegroundService()
            return
        }

        liveOcrFrameBusy = true

        try {
            registerProjectionCallback(projection)

            val metrics = resources.displayMetrics
            val width = metrics.widthPixels.coerceAtLeast(1)
            val height = metrics.heightPixels.coerceAtLeast(1)
            val density = metrics.densityDpi

            val imageReader = ImageReader.newInstance(
                width,
                height,
                PixelFormat.RGBA_8888,
                2
            )

            var virtualDisplay: VirtualDisplay? = null
            var completed = false

            fun cleanupAndSchedule() {
                try {
                    virtualDisplay?.release()
                } catch (_: Throwable) {
                }

                try {
                    imageReader.close()
                } catch (_: Throwable) {
                }

                liveOcrFrameBusy = false

                if (liveOcrRunning) {
                    scheduleLiveOcrFrame()
                }
            }

            imageReader.setOnImageAvailableListener({ reader ->
                if (completed) {
                    return@setOnImageAvailableListener
                }

                val image = try {
                    reader.acquireLatestImage()
                } catch (_: Throwable) {
                    null
                } ?: return@setOnImageAvailableListener

                completed = true
                recognizeLiveTextFromImage(
                    image = image,
                    capturedWidth = image.width,
                    capturedHeight = image.height,
                    onComplete = { cleanupAndSchedule() }
                )
            }, mainHandler)

            virtualDisplay = projection.createVirtualDisplay(
                "CidentiaLiveOcrLoop",
                width,
                height,
                density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageReader.surface,
                null,
                mainHandler
            )

            mainHandler.postDelayed({
                if (!completed && liveOcrRunning) {
                    completed = true
                    cacheApprovedSocialOcrResult(
                        safeSnapshotResponse(
                            ok = false,
                            code = "SOCIAL_TRANSLATE_LIVE_OCR_FRAME_TIMEOUT",
                            message = "Live OCR loop did not receive a screen frame in time.",
                            openedSocialApp = liveOcrTarget?.label ?: ""
                        )
                    )
                    cleanupAndSchedule()
                }
            }, 6000)
        } catch (error: Throwable) {
            liveOcrFrameBusy = false

            cacheApprovedSocialOcrResult(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_LIVE_OCR_FRAME_FAILED",
                    message = error.message ?: "Could not capture live OCR frame.",
                    openedSocialApp = liveOcrTarget?.label ?: ""
                )
            )

            if (liveOcrRunning) {
                scheduleLiveOcrFrame()
            }
        }
    }

    private fun recognizeLiveTextFromImage(
        image: android.media.Image,
        capturedWidth: Int,
        capturedHeight: Int,
        onComplete: () -> Unit
    ) {
        var bitmap: Bitmap? = null
        val openedApp = liveOcrTarget?.label ?: ""

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

                    cacheApprovedSocialOcrResult(
                        safeSnapshotResponse(
                            ok = true,
                            code = "SOCIAL_TRANSLATE_OCR_PREVIEW_READY",
                            message = "Live OCR preview updated.",
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
                    cacheApprovedSocialOcrResult(
                        safeSnapshotResponse(
                            ok = false,
                            code = "SOCIAL_TRANSLATE_LIVE_OCR_FAILED",
                            message = error.message ?: "Live OCR failed.",
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
                        recognizer.close()
                    } catch (_: Throwable) {
                    }

                    try {
                        bitmap?.recycle()
                    } catch (_: Throwable) {
                    }

                    onComplete()
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

            cacheApprovedSocialOcrResult(
                safeSnapshotResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_LIVE_OCR_PREP_FAILED",
                    message = error.message ?: "Could not prepare live OCR image.",
                    screenCaptured = true,
                    snapshotWidth = capturedWidth,
                    snapshotHeight = capturedHeight,
                    ocrStarted = true,
                    openedSocialApp = openedApp
                )
            )

            onComplete()
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

    private fun requestSocialTranslateOverlayPermission(
        result: MethodChannel.Result
    ) {
        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                Settings.canDrawOverlays(this)
            ) {
                result.success(
                    overlayResponse(
                        ok = true,
                        code = "SOCIAL_TRANSLATE_OVERLAY_PERMISSION_READY",
                        message = "Overlay permission is already granted.",
                        overlayOpened = false
                    )
                )
                return
            }

            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)

            result.success(
                overlayResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_OVERLAY_PERMISSION_REQUESTED",
                    message = "Android overlay permission screen was opened.",
                    overlayOpened = false
                )
            )
        } catch (error: Throwable) {
            result.success(
                overlayResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_OVERLAY_PERMISSION_FAILED",
                    message = error.message ?: "Could not open overlay permission settings.",
                    overlayOpened = false
                )
            )
        }
    }

    private fun showSocialTranslateFloatingBubble(
        text: String,
        result: MethodChannel.Result
    ) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                !Settings.canDrawOverlays(this)
            ) {
                result.success(
                    overlayResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_OVERLAY_PERMISSION_REQUIRED",
                        message = "Overlay permission is required before showing the bubble.",
                        overlayOpened = false
                    )
                )
                return
            }

            val intent = Intent(this, CidentiaFloatingBubbleService::class.java)
            intent.putExtra("bubbleText", text)
            startService(intent)

            result.success(
                overlayResponse(
                    ok = true,
                    code = "SOCIAL_TRANSLATE_FLOATING_BUBBLE_OPENED",
                    message = "Cidentia floating bubble is visible and user controlled.",
                    overlayOpened = true
                )
            )
        } catch (error: Throwable) {
            result.success(
                overlayResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_FLOATING_BUBBLE_FAILED",
                    message = error.message ?: "Could not show Cidentia floating bubble.",
                    overlayOpened = false
                )
            )
        }
    }

    private fun hideSocialTranslateFloatingBubble(
        result: MethodChannel.Result
    ) {
        try {
            stopService(Intent(this, CidentiaFloatingBubbleService::class.java))
            result.success(
                overlayResponse(
                    ok = true,
                    code = "SOCIAL_TRANSLATE_FLOATING_BUBBLE_CLOSED",
                    message = "Cidentia floating bubble was closed.",
                    overlayOpened = false
                )
            )
        } catch (error: Throwable) {
            result.success(
                overlayResponse(
                    ok = false,
                    code = "SOCIAL_TRANSLATE_FLOATING_BUBBLE_CLOSE_FAILED",
                    message = error.message ?: "Could not close Cidentia floating bubble.",
                    overlayOpened = false
                )
            )
        }
    }

    private fun overlayResponse(
        ok: Boolean,
        code: String,
        message: String,
        overlayOpened: Boolean
    ): Map<String, Any> {
        return mapOf(
            "ok" to ok,
            "code" to code,
            "message" to message,
            "loginAttempted" to false,
            "ocrStarted" to false,
            "overlayOpened" to overlayOpened,
            "automaticSend" to false,
            "backendUpload" to false,
            "accessibilityAutomation" to false
        )
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
            if (pendingLiveOcrResult != null) {
                completeLiveOcrStart(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_LIVE_OCR_CANCELLED",
                        message = "Live screen capture was cancelled by the user."
                    )
                )
            } else {
                completeSnapshot(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_SNAPSHOT_CANCELLED",
                        message = "Screen capture was cancelled by the user."
                    )
                )
            }
            return
        }

        try {
            startMediaProjectionForegroundService()
            if (pendingLiveOcrResult != null) {
                mainHandler.postDelayed({
                    beginLiveOcrLoopAfterForegroundService(resultCode, data)
                }, 650)
            } else {
                mainHandler.postDelayed({
                    beginMediaProjectionAfterForegroundService(resultCode, data)
                }, 650)
            }
        } catch (error: Throwable) {
            if (pendingLiveOcrResult != null) {
                completeLiveOcrStart(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_LIVE_OCR_START_FAILED",
                        message = error.message ?: "Could not start live foreground capture service."
                    )
                )
            } else {
                completeSnapshot(
                    safeSnapshotResponse(
                        ok = false,
                        code = "SOCIAL_TRANSLATE_SNAPSHOT_START_FAILED",
                        message = error.message ?: "Could not start foreground capture service."
                    )
                )
            }
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
