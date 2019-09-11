package com.example.ironbreeze.util

// TEST
import android.widget.Toast
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import com.example.ironbreeze.SingleApplication
import com.example.ironbreeze.utils.Utils
import com.example.ironbreeze.utils.Constants

class FlutterNativeBridge(): MethodChannel.MethodCallHandler {
    @Suppress("NO_REFLECTION_IN_CLASS_PATH")
    private val TAG: String = FlutterNativeBridge::class.simpleName.toString()
    private val CHANNEL_NAME: String = "main.ironbreeze/flutter_channel"

    private lateinit var flutterBridgeHandler: FlutterBridgeHandler
    private lateinit var methodChannel: MethodChannel
    constructor(flutterBridgeHandler: FlutterBridgeHandler) : this() {
        this.flutterBridgeHandler = flutterBridgeHandler
        methodChannel = MethodChannel(flutterBridgeHandler.getFlutterView(), CHANNEL_NAME)
        // [Android] method channel works now in both directions
        methodChannel.setMethodCallHandler { call, result ->
            onMethodCall(call, result)
        }
    }

    fun callFlutter(methodName: String, args: Any? = null, callback: ChannelCallback? = null) {
        callback?.let {
            methodChannel.invokeMethod(methodName, args, it)
        } ?: run {
            methodChannel.invokeMethod(methodName, args)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        //TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
        AppLogger.log(this, "called native bridge: ${call.method}(${call.arguments})")

        // Nullify in case the result will be called asynchronously
        var nativeChannelResult: String? = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT

        when (call.method) {
            "on_flutter_ready" -> {
                if (Utils.isRunningOnSimulator()) {
                    callFlutter("is_running_on_simulator", hashMapOf<String, Any?>("isRunningOnSimulator" to true), object : ChannelCallback("is_running_on_simulator") {
                        override fun onResult(result: Any?) {
                            AppLogger.log("FlutterMethod", "$methodName returned result: $result")
                        }
                    })
                }

                flutterBridgeHandler.onFlutterReady()

                nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
            }

            "open_maps" -> {
                //flutterBridgeHandler.openMapScreen()
                nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
            }

            "share_text" -> {
                call.arguments?.let { args ->
                    AppLogger.log("Sharing text, arguments: $args")
                    when (args) {
                        is HashMap<*, *> -> {
                            val subjectString: String? = args["subject"]?.toString()
                            subjectString.let { subject ->
                                val bodyString: String? = args["body"]?.toString()
                                bodyString.let { body ->
                                    if (body != null && subject != null) {
                                        flutterBridgeHandler.share(subject, body)
                                    }
                                }
                            }
                            //nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
                        }
                    }
                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
                } ?: run {
                    AppLogger.error(TAG ,"Missing call arguments in ${call.method}!")
                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
                }
            }
            "show_toast" -> {
                call.arguments?.let { args ->
                    AppLogger.log("Showing toast a message, arguments: $args")
                    when (args) {
                        is HashMap<*, *> -> {
                            val toastMessage: String? = args["toastMessage"]?.toString()
                            toastMessage.let {  msg ->
                                Toast.makeText(SingleApplication.getInstance(), msg, Toast.LENGTH_SHORT).show()
                            }
                            //nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
                        }
                    }
                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
                } ?: run {
                    AppLogger.error(TAG ,"Missing call arguments in ${call.method}!")
                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
                }
            }

//            "get_env" -> {
//                nativeChannelResult = Environment.currentEnvironment().toString()
//            }

            "go_to_store_rating" -> {
                SingleApplication.getInstance()?.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=${Constants.APP_ID}")))

                nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
            }

//            "is_location_sensor_enabled" -> {
//                val isLocationSensorEnabled: Boolean = LocationHelper.instance.isSensorEnabled()
//                nativeChannelResult = if (isLocationSensorEnabled) {
//                    "is_on"
//                } else {
//                    "is_off"
//                }
//            }

            "open_device_settings" -> {
                AppLogger.log(this, "There's no good reason to go to device setting in Android, needed only in iOS")
                // This opens the general settings, not the app's screen in the settings
                //Application.shared()?.topActivity()?.startActivityForResult(Intent(Settings.ACTION_SETTINGS), 0)
                nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
            }
            "are_general_notifications_enabled" -> {
                nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
                // From: https://stackoverflow.com/questions/11649151/android-4-1-how-to-check-notifications-are-disabled-for-the-application
                //Utils.debugToast(NotificationManagerCompat.from(Application.shared()).areNotificationsEnabled().toString())
            }

//            "address_autocomplete" -> {
//                call.arguments?.let { args ->
//                    when (args) {
//                        is HashMap<*, *> -> {
//                            val phrase: String? = args["phrase"] as? String
//                            phrase?.let {
//                                nativeChannelResult = null
//
//                                LocationHelper.instance.addressAutocomplete(phrase) { addresses ->
//                                    val gson = Gson()
//                                    // TODO: Check this scenrario: `gson.toJson("{}").toString()`
//                                    val addressesJsonString = gson.toJson(addresses ?: "{}").toString()
//                                    result.success(addressesJsonString)
//                                }
//                            } ?: run {
//                                nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                            }
//                        }
//                        else -> {
//                            nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                        }
//                    }
//                } ?: run {
//                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                }
//            }

//            "fetch_place_location" -> {
//                call.arguments?.let { args ->
//                    when (args) {
//                        is HashMap<*, *> -> {
//                            val placeId: String? = args["placeId"] as? String
//                            placeId?.let {
//                                nativeChannelResult = null
//
//                                LocationHelper.instance.fetchPlaceLocation(placeId) { addressDetails ->
//                                    var addressesJsonString: String = "{}"
//                                    addressDetails?.let {
//                                        addressesJsonString = addressDetails.toString()
//                                    }
//
//                                    result.success(addressesJsonString)
//                                }
//                            } ?: run {
//                                nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                            }
//                        }
//                        else -> {
//                            nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                        }
//                    }
//                } ?: run {
//                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                }
//            }

//            "reverse_geocode" -> {
//                call.arguments?.let { args ->
//                    when (args) {
//                        is HashMap<*, *> -> {
//                            val latitude = args["latitude"] as? Double
//                            val longitude = args["longitude"] as? Double
//                            if (latitude != null && longitude != null) {
//                                val coordinate = LatLng(latitude, longitude)
//                                nativeChannelResult = null
//
//                                LocationHelper.instance.reverseGeocode(coordinate) { addressTupleAsArray ->
//                                    val gson = Gson()
//                                    var addressJsonString: String = "{}"
//                                    addressTupleAsArray?.let {
//                                        addressJsonString = gson.toJson(addressTupleAsArray).toString()
//                                    }
//
//                                    result.success(addressJsonString)
//                                }
//                            }
//                        }
//                        else -> {
//                            nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                        }
//                    }
//                } ?: run {
//                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                }
//            }

//            "open_webview" -> {
//                call.arguments?.let {
//                    AppLogger.log("Opening web view with URL: $it")
//                    when (it) {
//                        is HashMap<*, *> -> {
//                            val urlString: String = it["urlString"].toString()
//                            flutterBridgeHandler.openWebView(urlString)
//                        }
//                    }
//                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.SUCCESS_RESULT
//                } ?: run {
//                    AppLogger.error(TAG ,"Missing call arguments in ${call.method}!")
//                    nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//                }
//            } else -> {
//                AppLogger.error(TAG, "Missing handling for method channel named: " + call.method)
//            nativeChannelResult = Constants.FlutterMethodChannel.Keys.FAILURE_RESULT
//            }
        }

        nativeChannelResult?.let {
            result.success(nativeChannelResult)
        }
    }

}

//fun SingleApplication.notifyMapTap(coordinates: LatLng) {
//    val details = Bundle()
//    val gson = Gson()
//    details.putString(PrivateEventBus.Parameter.COORDINATES, gson.toJson(coordinates))
//    PrivateEventBus.notify(PrivateEventBus.Action.MAP_TAP, details)
//}

fun <T1: Any, T2: Any, R: Any> safeLet(p1: T1?, p2: T2?, block: (T1, T2)->R?): R? {
    return if (p1 != null && p2 != null) block(p1, p2) else null
}
fun <T1: Any, T2: Any, T3: Any, R: Any> safeLet(p1: T1?, p2: T2?, p3: T3?, block: (T1, T2, T3)->R?): R? {
    return if (p1 != null && p2 != null && p3 != null) block(p1, p2, p3) else null
}
fun <T1: Any, T2: Any, T3: Any, T4: Any, R: Any> safeLet(p1: T1?, p2: T2?, p3: T3?, p4: T4?, block: (T1, T2, T3, T4)->R?): R? {
    return if (p1 != null && p2 != null && p3 != null && p4 != null) block(p1, p2, p3, p4) else null
}
fun <T1: Any, T2: Any, T3: Any, T4: Any, T5: Any, R: Any> safeLet(p1: T1?, p2: T2?, p3: T3?, p4: T4?, p5: T5?, block: (T1, T2, T3, T4, T5)->R?): R? {
    return if (p1 != null && p2 != null && p3 != null && p4 != null && p5 != null) block(p1, p2, p3, p4, p5) else null
}