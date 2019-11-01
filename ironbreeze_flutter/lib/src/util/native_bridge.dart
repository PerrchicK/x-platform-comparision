import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ironbreeze/src/bl/location_helper.dart';
import 'package:ironbreeze/src/bl/models/coordinates.dart';
import 'package:ironbreeze/src/communication/local_broadcast.dart';
import 'package:ironbreeze/src/dl/data_manager.dart';
import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:ironbreeze/src/util/utils.dart';

/// Inspired from: https://flutter.io/docs/development/platform-integration/platform-channels
/// Read more: https://proandroiddev.com/communication-between-flutter-and-native-modules-9b52c6a72dd2
class NativeBridge {
  static const platform =
      const MethodChannel('main.ironbreeze/flutter_channel');

  static const String SUCCESS_RESULT = "1";
  static const String FAILURE_RESULT = "0";

  static DataManager get dataManager => DataManager();

  static bool _didNotifyFlutterPresented;

  static Future<dynamic> init() async {
    if (_didNotifyFlutterPresented != null) return;

    _didNotifyFlutterPresented = false;

    platform.setMethodCallHandler((MethodCall call) {
      dynamic result = FAILURE_RESULT;
      switch (call.method) {
        case 'did_change_location_authorization':
//          LocationHelper.shared.refreshPermissionsAuthorization().then((_) {
//            LocalBroadcast.notifyEvent(
//                AppObserver.Key_ON_LOCATION_PERMISSION_CHANGED);
//          });
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'location_sensor_toggled':
//          LocationHelper.shared.refreshPermissionsAuthorization().then((_) {
//            LocalBroadcast.notifyEvent(AppObserver.Key_ON_LOCATION_SENSOR_CHANGED);
//          });
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'map_tap':
          var arguments = call.arguments;
          if (arguments != null) {
            var latitude;
            var longitude;
            if (arguments is Map) {
              Map coordinatesJson = arguments;
              latitude = coordinatesJson['latitude'];
              longitude = coordinatesJson['longitude'];
            } else {
              String jsonString = call.arguments?.toString() ?? "{}";

              Map coordinatesJson;
              try {
                coordinatesJson = json.decode(jsonString) ?? {};
              } catch (error) {
                AppLogger.error(error);
                coordinatesJson = {};
              }
              latitude = coordinatesJson['latitude'];
              longitude = coordinatesJson['longitude'];
            }

            if (latitude != null && longitude != null) {
              Coordinates selectedLocation =
                  Coordinates(latitude: latitude, longitude: longitude);

              LocalBroadcast.notifyEvent(
                  AppObserver.Key_NATIVE_MAP_LOCATION_TAP, selectedLocation);
            }

            //Analytics.logEvent(Analytics.EventTapOnMapLocation);
            result = NativeBridge.SUCCESS_RESULT;
          }
          break;
        case "local_notifications_permissions_changed":
          LocalBroadcast.notifyEvent(
              AppObserver.Key_ON_NOTIFICATIONS_PERMISSION_CHANGED);
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'use_current_location':
          LocalBroadcast.notifyEvent(
              AppObserver.Key_NATIVE_USE_CURRENT_LOCATION);
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'perform_search':
          if (call.arguments is Map) {
            var searchPhrase = call.arguments['search_phrase'];
            if (searchPhrase is String) {
              LocalBroadcast.notifyEvent(AppObserver.Key_NATIVE_PASTED_SEARCH,
                  {'searchPhrase': searchPhrase});
              result = NativeBridge.SUCCESS_RESULT;
            }
          }
          break;
        case 'is_running_on_simulator':
          if (call.arguments is Map) {
            Utils.setIsRunningOnSimulator(
                call.arguments["isRunningOnSimulator"]);
          }
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'on_deep_link_pressed':
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'application_entered_background':
          dataManager.lastTimeInForeground = Utils.now(false);
          LocalBroadcast.notifyEvent(
              AppObserver.Key_ON_APPLICATION_ENTERED_BACKGROUND);
          result = NativeBridge.SUCCESS_RESULT;
          break;
        case 'application_entered_foreground':
          LocationHelper.shared.refreshPermissionsAuthorization();

          LocalBroadcast.notifyEvent(AppObserver
              .Key_ON_APPLICATION_BACK_FROM_BACKGROUND_TO_FOREGROUND);
          result = NativeBridge.SUCCESS_RESULT;
          break;
        default:
          Utils.debugToast(
              "Unhandled native bridge call named: '${call.method}'");
          AppLogger.error(
              "Unhandled native bridge call named: '${call.method}'");
          result = NativeBridge.FAILURE_RESULT;
      }

      return new Future.value(result);
    });
  }

  static Future<String> getCurrentEnvironment() async {
    return await invokeNativeMethod('get_env');
  }

  static Future<String> openMaps() async {
    return await invokeNativeMethod('open_maps');
  }

  static Future<String> onFlutterPresented() async {
    if (_didNotifyFlutterPresented) return NativeBridge.FAILURE_RESULT;

    _didNotifyFlutterPresented = true;
    LocationHelper.shared.refreshPermissionsAuthorization();

    String result;
    if (!dataManager.didNotifyFlutterReady) {
      dataManager.didNotifyFlutterReady = true;

      result = await invokeNativeMethod('on_flutter_ready');
    } else {
      result = NativeBridge.SUCCESS_RESULT;
    }

    //AdvertisementsManager.shared.showBanner(5);

    return result;
  }

  static Future<String> openWebView(String urlString) async {
    return await invokeNativeMethod(
        'open_webview', <String, String>{"urlString": urlString});
  }

  static Future<String> updateLocation(Coordinates coordinates) async {
    if (coordinates == null) {
      AppLogger.error("Coordinates are null! Cannot update native.");
      return NativeBridge.FAILURE_RESULT;
    }

    return await invokeNativeMethod('update_location', <String, dynamic>{
      "location": {
        "latitude": coordinates.latitude,
        "longitude": coordinates.longitude
      }
    });
  }

  static Future<String> showToast(String toastMessage) async {
    return await invokeNativeMethod(
        'show_toast', <String, String>{"toastMessage": toastMessage});
  }

  static Future<String> invokeNativeMethod(String methodName,
      [dynamic arguments]) async {
    String result;
    try {
      if (arguments == null) {
        result = await platform.invokeMethod(methodName);
      } else {
        result = await platform.invokeMethod(methodName, arguments);
      }
      AppLogger.log("Native method '$methodName' returned result: $result",
          withStackTrace: false);
    } on PlatformException catch (e) {
      String errorMessageString =
          "Failed to run native method, error: '${e.message}'.";
      AppLogger.log(errorMessageString);
      Utils.debugToast(errorMessageString);
    }

    return result;
  }

  static Future<String> openDeviceSettings() async {
    return await invokeNativeMethod('open_device_settings');
  }

  static Future<String> shareText(String subject, String body) async {
    return await invokeNativeMethod(
        'share_text', <String, String>{'body': body, 'subject': subject});
  }

  static Future<String> showConfetti() async {
    return await invokeNativeMethod('show_confetti');
  }

  static Future updateSplashTips(
      Iterable<Map<String, dynamic>> tipsJson) async {
    dynamic args = <String, dynamic>{"tipsJson": tipsJson};
    return await invokeNativeMethod('update_splash_tips', args);
  }

  static Future requestLocationPermission(
      bool isBackgroundLocationPermission) async {
    dynamic args = <String, dynamic>{
      "isBackgroundLocationPermission": isBackgroundLocationPermission
    };
    return await invokeNativeMethod('request_location_permission', args);
  }

  static Future<String> isLocationPermissionGranted(
      bool isBackgroundLocationPermission) async {
    dynamic args = <String, dynamic>{
      "isBackgroundLocationPermission": isBackgroundLocationPermission
    };
    return await invokeNativeMethod('is_location_permission_granted', args);
  }

  static Future<String> setAlertJobInterval(int intervalValue) async {
    String result;
    if (Utils.currentPlatform == AppPlatform.ios) {
      Utils.debugToast(
          "You cannot set job interval in iOS!! Apple won't allow that... 😣");
      result = NativeBridge.FAILURE_RESULT;
    } else {
      result = await NativeBridge.invokeNativeMethod(
          "set_alert_job_interval", {"intervalInMinutes": intervalValue});
    }

    return result;
  }

  static Future<int> getLastAlertJobRunTimestamp() async {
    String timestampString = await NativeBridge.invokeNativeMethod(
        "get_last_alert_job_service_timestamp_run");
    int timestamp = int.tryParse(timestampString) ?? 0;
    return timestamp;
  }

  static Future<bool> setAlertNotificationsEnabled(
      bool isReportNotificationsOn) async {
    var _isAuthorizedToShowLocalNotifications =
        await isAuthorizedToShowLocalNotifications();
    if (!_isAuthorizedToShowLocalNotifications && isReportNotificationsOn) {
      requestLocalNotificationsPermissions();
    }

    dynamic args = <String, bool>{
      "isAlertNotificationsOn": isReportNotificationsOn
    };
    String result =
        await invokeNativeMethod('set_alert_notifications_enabled', args);

    return result == SUCCESS_RESULT;
  }

  static Future<bool> requestLocalNotificationsPermissions() async {
    if (Utils.currentPlatform == AppPlatform.ios) return true;

    String result =
        await invokeNativeMethod('request_local_notifications_permissions');
    return result == SUCCESS_RESULT;
  }

  /// Returns null if not set
  static Future<bool> isAlertNotificationsEnabled() async {
    String result = await invokeNativeMethod('is_alert_notifications_enabled');
    bool isOn;
    if (result == FAILURE_RESULT) {
      isOn = null;
    } else {
      isOn = result == "is_on";
    }

    return isOn;
  }

  static Future<bool> isAuthorizedToShowLocalNotifications() async {
    // TODO: Add check for android as well!
    if (Utils.currentPlatform != AppPlatform.ios) return true;
    String result =
        await invokeNativeMethod('are_general_notifications_enabled');
    return result == SUCCESS_RESULT;
  }

  static Future<bool> showAppStoreRating() async {
    String result = await invokeNativeMethod('go_to_store_rating');
    return result == SUCCESS_RESULT;
  }
}
