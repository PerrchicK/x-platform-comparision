//
//  FlutterNativeBridge.swift
//  Runner
//
//  Created by Perry Shalom on 19/03/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import CoreLocation
import UserNotifications

//TODO Perry: WTF is this 'The Chromium Authors'?? How do I remove it when I create a new file in Xcode?
extension AppDelegate {
    func onFlutterCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let resultString: String?
        switch call.method {
        case "show_toast":
            if let args = call.arguments as? [String:String], let toastMessage = args["toastMessage"] {
                ToastMessage.show(messageText: toastMessage)
                resultString = "1"
            } else {
                resultString = "0"
            }
        case "open_maps":
            showMap()
            resultString = "1"
        case "reverse_geocode":
            if let args = call.arguments as? RawJsonFormat,
                let locationCoordinate: LocationCoordinate = LocationCoordinate(json: args) {
                LocationHelper.shared.reverseGeocode(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude) { (tupleAsArray) in
                    result((tupleAsArray ?? []).toJsonString())
                }

                // Returning now `nil` because the real result will be returned later
                resultString = nil
            } else {
                resultString = "0"
            }
        case "request_local_notifications_permissions":
            NotificationsManager.requestPermissionsForLocalNotifications()
            resultString = "1"
        case "go_to_store_rating":
            PerrFuncs.presentAppStoreRating()
            resultString = "1"
        case "is_location_sensor_enabled":
            resultString = "is_on"
        case "are_general_notifications_enabled":
            resultString = nil
            NotificationsManager.shared.localNotificationsPermissionsStatus { (authorizationStatus) in
                result(authorizationStatus == UNAuthorizationStatus.authorized ? "1" : "0")
            }
            //resultString = NotificationsManager.shared.isAuthorizedToShowLocalNotifications ? "1" : "0"
        case "is_location_permission_granted":
            if let args = call.arguments as? [String:Any], let isBackgroundLocationPermission = args["isBackgroundLocationPermission"] as? Bool {
                let isPermissionGranted: Bool = isBackgroundLocationPermission ? LocationHelper.shared.isBackgroundPermissionGranted : LocationHelper.shared.isForegroundPermissionGranted
                resultString = isPermissionGranted ? "permission is granted" : "permission is NOT granted"
            } else {
                resultString = "0"
            }
        case "request_location_permission":
            if let args = call.arguments as? [String:Any], let isBackgroundLocationPermission = args["isBackgroundLocationPermission"] as? Bool {
                LocationHelper.shared.requestPermissionsIfNeeded(type: isBackgroundLocationPermission ? CLAuthorizationStatus.authorizedAlways : CLAuthorizationStatus.authorizedWhenInUse)
                resultString = "1"
            } else {
                resultString = "0"
            }
        case "on_flutter_ready":
            defer {
                isFlutterReady = true
            }
            
            if UtilsObjC.isRunningOnSimulator() {
                flutterViewController.callFlutter(methodName: "is_running_on_simulator", arguments: ["isRunningOnSimulator":true], callback: { result in
                    📗(result)
                })
            }

            NotificationCenter.notify(notificationName: Notification.Name.ON_FLUTTER_IS_READY)

            resultString = "1"
        case "show_confetti":
//            MainNavigationController.shared?.showConfetti()
            resultString = "1"
        case "open_device_settings":
            PerrFuncs.goToSettings()
            resultString = "1"
        case "share_text":
            guard let mostTopViewController = UIApplication.mostTopViewController() else { resultString = "0"; break }
            if let args = call.arguments as? [String:String],
                //let subjectString = args["subject"],
                let bodyString = args["body"],
                let subjectString = args["subject"] {
                PerrFuncs.share(item: bodyString, onViewController: mostTopViewController)
            }
            resultString = "1"
        default:
            📕("Unhandled bridged Flutter method call: \(call.method)")
            resultString = "0" // Never return nil!
        }
        if let resultString = resultString {
            result(resultString)
        } else {
            // Look out! please make sure that this callback will run this closure so the native will return!
        }
    }
}

extension FlutterViewController {
    static var FlutterMethodChannelName: String = "main.ironbreeze/flutter_channel"
    func observeMethodChannel(onFlutterCall: @escaping ((FlutterMethodCall, @escaping FlutterResult) -> Void)) {
        let methodChannel = FlutterMethodChannel(name: FlutterViewController.FlutterMethodChannelName, binaryMessenger: self.binaryMessenger)
        
        methodChannel.setMethodCallHandler(onFlutterCall)
    }
    
    func callFlutter(methodName: String, arguments: Any? = nil, callback: CallbackClosure<Any?>? = nil) {
        let methodChannel = FlutterMethodChannel(name: FlutterViewController.FlutterMethodChannelName, binaryMessenger: self.binaryMessenger)
        methodChannel.invokeMethod(methodName, arguments: arguments) { (callbackData) in
            📗(callbackData)
            callback?(callbackData)
        }
    }
}

extension UIViewController {
//    func showConfetti() {
//        let cheerView = CheerView(frame: CGRect(x: 0, y: 0, width: PerrFuncs.screenSize.width, height: PerrFuncs.screenSize.height))
//        view.addSubview(cheerView)
//        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
//        cheerView.config.colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow]
//        cheerView.start()
//
//        PerrFuncs.runBlockAfterDelay(afterDelay: 2) {
//            cheerView.stop()
//            PerrFuncs.runBlockAfterDelay(afterDelay: 10) {
//                cheerView.removeFromSuperview()
//            }
//        }
//    }
}
