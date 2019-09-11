package com.example.ironbreeze.utils

import android.view.View
import android.view.ViewGroup

// Stolen from iOS
fun View.removeFromSuperView() {
    if (parent == null) return
    (parent as? ViewGroup)?.removeView(this)
}
