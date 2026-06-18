package com.emilzulufov.flutter_instagram_offline_first_clone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cidentia.live/social_translate_snapshot"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSingleSnapshotPreview" -> result.success(
                    mapOf(
                        "ok" to false,
                        "code" to "SOCIAL_TRANSLATE_SNAPSHOT_STUB_ONLY",
                        "message" to "Native bridge is wired, but screen capture is intentionally not opened in M5H.",
                        "mediaProjectionOpened" to false,
                        "screenCaptured" to false,
                        "ocrStarted" to false,
                        "overlayOpened" to false,
                        "automaticSend" to false
                    )
                )
                else -> result.notImplemented()
            }
        }
    }
}
