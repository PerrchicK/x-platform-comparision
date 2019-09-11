package com.example.ironbreeze.util

//import com.google.android.gms.maps.model.LatLng
import io.flutter.view.FlutterView

interface FlutterBridgeHandler {
//    fun openMapScreen(location: LatLng? = null)
    fun share(subject: String, body: String)
    fun getFlutterView(): FlutterView
    fun onFlutterReady()
}
