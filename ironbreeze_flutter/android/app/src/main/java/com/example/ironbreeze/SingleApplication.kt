package com.example.ironbreeze

import android.app.Application
import android.os.Handler
import android.os.HandlerThread
//import com.example.ironbreeze.util.RunnableWithExtra
import io.flutter.app.FlutterApplication
import java.lang.ref.WeakReference

class SingleApplication: FlutterApplication() {

    companion object {
        private lateinit var _shared: WeakReference<SingleApplication>
        fun getInstance(): SingleApplication? {
            return _shared.get()
        }

        @JvmStatic
        fun sharedInstance(): SingleApplication? {
            return getInstance()
        }

        @JvmStatic
        fun runInBackgroundThread(bgTask: Runnable) {
            getInstance()?.appBackgroundHandler?.post(bgTask)
        }

        @JvmStatic
        fun cancelBackgroundThread(bgTask: Runnable) {
            getInstance()?.appBackgroundHandler?.removeCallbacks(bgTask)
        }
    }

    private lateinit var appBackgroundHandler: Handler
    private lateinit var mainThreadHandler: Handler

    override fun onCreate() {
        super.onCreate()

        _shared = WeakReference(this)

        val appBackgroundThread = HandlerThread(SingleApplication::class.java.simpleName + "_BackgroundThread")
        appBackgroundThread.start()
        appBackgroundHandler = Handler(appBackgroundThread.looper)

        mainThreadHandler = Handler()
    }
}
