package com.example.ironbreeze

import android.content.Intent
import android.os.Bundle
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import com.example.ironbreeze.ui.SplashView
import com.example.ironbreeze.util.FlutterBridgeHandler
import com.example.ironbreeze.util.FlutterNativeBridge
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterView


class MainActivity : FlutterActivity(), FlutterBridgeHandler {

    private val splashView: SplashView by lazy {SplashView(this)}
    private lateinit var methodHandler: FlutterNativeBridge

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        methodHandler = FlutterNativeBridge(this)

        //(flutterView.parent as? ViewGroup)?.addView(splashView, ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        addContentView(splashView, ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    override fun onResume() {
        super.onResume()

        splashView.begin()
    }

    //region FlutterBridgeHandler methods
    override fun share(subject: String, body: String) {
        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = "text/plain"
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject)
        shareIntent.putExtra(Intent.EXTRA_TEXT, body)
        startActivity(Intent.createChooser(shareIntent, "Share via"))
    }

    override fun onFlutterReady() {
        splashView.beGone()
    }

    override fun getFlutterView(): FlutterView {
        return super.getFlutterView()
    }
    //endregion

}
