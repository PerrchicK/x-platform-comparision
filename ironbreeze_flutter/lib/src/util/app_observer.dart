import 'package:ironbreeze/src/util/app_logger.dart';
//import 'package:logging/logging.dart';

class AppObserver {
  static const String Key_FAVORITE_SELECTED = "FAVORITE_SELECTED";
  static const String Key_ON_ADD_NEW_FAVORITE = "ON_ADD_NEW_FAVORITE";
  static const String Key_ON_DEVICE_LOCATION_IS_INSIDE_CHINA =
      "ON_DEVICE_LOCATION_IS_INSIDE_CHINA";
  static const String Key_DID_CHANGE_SCREEN_ROTATION =
      "DID_CHANGE_SCREEN_ROTATION";
  static const String Key_KEYBOARD_DID_CHANGE = "KEYBOARD_DID_CHANGE";
  static const String Key_IS_CONNECTED_TO_INTERNET_OR_WIFI = "IS_CONNECTED";
  static const String Key_WELCOME_MESSAGE_ARRIVED = "WELCOME_MESSAGE_ARRIVED";
  static const String Key_NATIVE_MAP_LOCATION_TAP = "map_tap";
  static const String Key_APP_VERSION_DID_CHANGE = "APP_VERSION_DID_CHANGE";
  static const String Key_SOCKET_EXCEPTION = "SOCKET_EXCEPTION";
  static const String Key_TEMPERATURE_UNITS_CHANGED =
      "TEMPERATURE_UNITS_CHANGED";
  static const String Key_ALERT_NOTIFICATIONS_SETTING_CHANGED =
      "ALERT_NOTIFICATIONS_SETTING_CHANGED";
  static const String Key_REPORT_NOTIFICATIONS_SETTING_CHANGED =
      "REPORT_NOTIFICATIONS_SETTING_CHANGED";
  static const String Key_CLEAR_SEARCH_BEEN_PRESSED =
      "CLEAR_SEARCH_BEEN_PRESSED";
  static const String Key_APP_FIRST_RUN = "FIRST_RUN";
  static const String Key_ON_NEW_FORECAST_ARRIVED = "ON_NEW_FORECAST_ARRIVED";
  static const String Key_ON_BANNER_HEIGHT_UPDATE = "ON_BANNER_HEIGHT_UPDATE";

  static const String Key_ON_APPLICATION_ENTERED_BACKGROUND =
      "ON_APPLICATION_ENTERED_BACKGROUND";
  static const String Key_ON_APPLICATION_BACK_FROM_BACKGROUND_TO_FOREGROUND =
      "ON_BACK_FROM_BACKGROUND";

  static const String Key_SHOW_CARD_BUMP_HINT = "SHOW_CARD_BUMP_HINT";
//  static const String Key_RESET_CARD_BUMP_HINT = "RESET_CARD_BUMP_HINT";
  static const String Key_SHOW_CARD_COLOR_HINT = "SHOW_CARD_COLOR_HINT";

  static const String Key_ON_FIRST_SESSION = "ON_FIRST_SESSION";

  static const String Key_ON_LOCATION_SENSOR_CHANGED =
      "ON_LOCATION_SENSOR_CHANGED";

  static const String Key_ON_LOCATION_PERMISSION_CHANGED =
      "ON_LOCATION_PERMISSION_CHANGED";
  static const String Key_ON_NOTIFICATIONS_PERMISSION_CHANGED =
      "ON_NOTIFICATIONS_PERMISSION_CHANGED";

  static const String Key_NATIVE_PASTED_SEARCH = "NATIVE_PASTED_SEARCH";
  static const String Key_NATIVE_USE_CURRENT_LOCATION =
      "NATIVE_USE_CURRENT_LOCATION";

  String _eventName;
  String get eventName => _eventName;
  bool isEnabled;

  Function(String eventName, dynamic data) _onEvent;

  // Private constructor
  AppObserver._internal() {
    isEnabled = true;
  }

  void remove() {
    isEnabled = false;
    LocalBroadcast._observers[eventName].remove(this);
  }
}

class LocalBroadcast {
  static Map<String, List<AppObserver>> _observers = Map();

  static const String Key_ThrowConfetti = "ThrowConfetti";
  static const String Key_ImagesListUpdated = "ImagesListUpdated";

  static AppObserver observe(
      {String eventName, Function(String eventName, dynamic data) onEvent}) {
    AppObserver observer = AppObserver._internal();
    observer._eventName = eventName;
    observer._onEvent = onEvent;

    if (observer._eventName == null) {
      AppLogger.error("this.eventName cannot be NULL!!");
    } else {
      List<AppObserver> observersList =
          LocalBroadcast._observers[observer._eventName];
      if (observersList == null) {
        observersList = new List<AppObserver>();
        LocalBroadcast._observers[eventName] = observersList;
      }
      LocalBroadcast._observers[eventName].add(observer);
    }

    return observer;
  }

  static void notifyEvent(String eventName, [dynamic data]) {
    List<AppObserver> observersList = _observers[eventName];
    if (observersList != null) {
      for (AppObserver observer in observersList) {
        if (!observer.isEnabled) continue;
        observer._onEvent(eventName, data);
      }
    }
  }
}
