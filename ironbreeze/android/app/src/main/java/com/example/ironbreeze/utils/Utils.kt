package com.example.ironbreeze.utils

import com.example.ironbreeze.BuildConfig

class Utils {
    companion object {
        val isReleaseVersion: Boolean = !BuildConfig.DEBUG

        fun isRunningOnSimulator(): Boolean {
            // TODO Perry, complete
            return true
        }
    }
}