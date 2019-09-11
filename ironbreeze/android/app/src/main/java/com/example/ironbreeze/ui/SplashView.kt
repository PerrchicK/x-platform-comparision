package com.example.ironbreeze.ui

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.animation.BounceInterpolator
import android.widget.FrameLayout
import android.widget.TextView
import com.example.ironbreeze.R
import com.example.ironbreeze.utils.removeFromSuperView

@SuppressLint("ViewConstructor")
class SplashView(parentActivity: Activity) : FrameLayout(parentActivity) {

    companion object {
        const val MAX_SPLASH_DURATION: Long = 5 * 1000
        private const val scaleSize: Float = 4f
    }

    private var txtSplash: TextView
    var onDone: Runnable? = null

    init {
        val contentView = LayoutInflater.from(parentActivity).inflate(R.layout.splash_view, (parent as? ViewGroup), false)
        txtSplash = contentView.findViewById(R.id.txt_splash_centered_string)
        txtSplash.scaleX = 0f
        txtSplash.scaleY = 0f

        addView(contentView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    }

    fun begin() {
        if (alpha != 1f) return

        txtSplash.animate().setStartDelay(300).scaleX(scaleSize).scaleY(scaleSize).setDuration(800).setInterpolator(BounceInterpolator()).start()

        postDelayed({
            beGone()
        }, MAX_SPLASH_DURATION)

    }

    fun beGone() {
        if (alpha != 1f) return

        animate().alpha(0f).setDuration(500).withEndAction {
            onDone?.run()
            removeFromSuperView()
        }
    }

}
