package com.example.ironbreeze.util

import android.util.Log
import com.example.ironbreeze.utils.Utils

class AppLogger {
    companion object {
        @Suppress("FunctionName")
        private fun _log(reporter: String, logMessage: Any?) {
            if (Utils.isReleaseVersion) return

            Log.d(reporter, logMessage.toString())
        }

        fun log(reporter: Any, logMessage: Any?) {
            log(reporter.javaClass.simpleName, logMessage.toString())
        }

        fun log(logMessage: Any?) {
            log("Anonymous reporter", logMessage.toString())
        }

        fun error(reporter: Any, logMessage: Any?) {
            error(reporter.javaClass.simpleName, logMessage.toString())
        }

        fun error(reporter: String, throwable: Throwable) {
            if (Utils.isReleaseVersion) return

            Log.e(reporter, throwable.message)
            throwable.printStackTrace()
        }

        fun error(reporter: String, logMessage: Any?) {
            if (Utils.isReleaseVersion) return

            logMessage?.let {
                Log.e(reporter, it.toString())
            }
        }

        @JvmStatic
        fun log(tag: String, msg: String) {
            _log(tag, msg)
        }

        fun error(tag: String, errorMessage: String, throwable: Throwable) {
            if (Utils.isReleaseVersion) return

            Log.e(tag, errorMessage)
            error(tag, throwable)
        }
    }
}
