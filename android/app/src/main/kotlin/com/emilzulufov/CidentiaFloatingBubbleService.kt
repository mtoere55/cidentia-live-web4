package com.emilzulufov.flutter_instagram_offline_first_clone

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView

class CidentiaFloatingBubbleService : Service() {
    private var windowManager: WindowManager? = null
    private var bubbleView: View? = null
    private var bubbleTextView: TextView? = null
    private var params: WindowManager.LayoutParams? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val text = intent?.getStringExtra("bubbleText")?.trim().orEmpty()
        showOrUpdateBubble(text)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        removeBubble()
        super.onDestroy()
    }

    private fun showOrUpdateBubble(text: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(this)
        ) {
            stopSelf()
            return
        }

        if (bubbleView != null) {
            bubbleTextView?.text = if (text.isNotBlank()) {
                text
            } else {
                "Çeviri bekleniyor."
            }
            return
        }

        val container = LinearLayout(this)
        container.orientation = LinearLayout.VERTICAL
        container.setPadding(22, 18, 22, 18)

        val background = GradientDrawable()
        background.cornerRadius = 34f
        background.setColor(Color.argb(232, 18, 24, 38))
        background.setStroke(2, Color.argb(120, 255, 255, 255))
        container.background = background

        val close = TextView(this)
        close.text = "×"
        close.setTextColor(Color.WHITE)
        close.textSize = 16f
        close.gravity = Gravity.END
        close.setOnClickListener { stopSelf() }

        val body = TextView(this)
        body.text = if (text.isNotBlank()) {
            text
        } else {
            "Çeviri bekleniyor."
        }
        body.setTextColor(Color.WHITE)
        body.textSize = 12f
        body.maxLines = 5
        body.setPadding(0, 8, 0, 0)

        container.addView(close)
        container.addView(body)

        bubbleTextView = body
        bubbleView = container

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val layoutParams = WindowManager.LayoutParams(
            760,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        layoutParams.gravity = Gravity.TOP or Gravity.END
        layoutParams.x = 24
        layoutParams.y = 180
        params = layoutParams

        var startX = 0
        var startY = 0
        var touchX = 0f
        var touchY = 0f

        container.setOnTouchListener { _, event ->
            val currentParams = params ?: return@setOnTouchListener false

            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    startX = currentParams.x
                    startY = currentParams.y
                    touchX = event.rawX
                    touchY = event.rawY
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    currentParams.x = startX - (event.rawX - touchX).toInt()
                    currentParams.y = startY + (event.rawY - touchY).toInt()
                    windowManager?.updateViewLayout(container, currentParams)
                    true
                }

                else -> false
            }
        }

        try {
            windowManager?.addView(container, layoutParams)
        } catch (_: Throwable) {
            stopSelf()
        }
    }

    private fun removeBubble() {
        val view = bubbleView ?: return

        try {
            windowManager?.removeView(view)
        } catch (_: Throwable) {
        }

        bubbleView = null
        bubbleTextView = null
        params = null
    }
}
