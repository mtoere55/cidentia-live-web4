package com.emilzulufov.flutter_instagram_offline_first_clone

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

class CidentiaMediaProjectionService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startProjectionForeground()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startProjectionForeground()
        return START_NOT_STICKY
    }

    private fun startProjectionForeground() {
        val channelId = "cidentia_social_translate_capture"

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    channelId,
                    "Cidentia screen translate",
                    NotificationManager.IMPORTANCE_LOW
                )
                val manager = getSystemService(NotificationManager::class.java)
                manager?.createNotificationChannel(channel)
            }

            val icon = applicationInfo.icon.takeIf { it != 0 }
                ?: android.R.drawable.ic_menu_view

            val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, channelId)
                    .setSmallIcon(icon)
                    .setContentTitle("Cidentia Social Translate")
                    .setContentText("Approved screen snapshot is active.")
                    .setOngoing(true)
                    .build()
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
                    .setSmallIcon(icon)
                    .setContentTitle("Cidentia Social Translate")
                    .setContentText("Approved screen snapshot is active.")
                    .setOngoing(true)
                    .build()
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    startForeground(
                        52052,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                    )
                } catch (_: Throwable) {
                    startForeground(52052, notification)
                }
            } else {
                startForeground(52052, notification)
            }
        } catch (_: Throwable) {
            stopSelf()
        }
    }

}
