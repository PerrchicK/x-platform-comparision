import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:intl/intl.dart';
import 'package:ironbreeze/src/bl/location_helper.dart';
import 'package:ironbreeze/src/bl/models/coordinates.dart';
import 'package:ironbreeze/src/bl/parser.dart';
import 'package:ironbreeze/src/bl/strings.dart';
import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:ironbreeze/src/util/app_observer.dart';
import 'package:ironbreeze/src/util/native_bridge.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:url_launcher/url_launcher.dart';

enum AppPlatform { android, ios }

class Utils {
  // From: https://github.com/flutter/plugins/tree/master/packages/connectivity
  static bool _isConnected = true;

  static bool _isRunningOnSimulator = false;

  static AppPlatform _appPlatform;
  static LocationHelper _locationHelper;

  static double aspectRatio;

  static int _worldClockDiffMilliseconds = 0;

//  static Client client;
  static int get worldClockDiffMilliseconds => _worldClockDiffMilliseconds;

  static AppPlatform get currentPlatform => _appPlatform;

  static bool get isRunningOnSimulator => _isRunningOnSimulator;

  static bool get isIphoneXSize =>
      Utils.safeAreaPadding.bottom > 0 && currentPlatform == AppPlatform.ios;

  static double _screenDensity;

  static bool get isRunningOnIos => currentPlatform == AppPlatform.ios;

  static double screenDensity() => _screenDensity;

  static Size screenSize() => _screenSize;
  static Size _screenSize;
  static EdgeInsets _safeAreaPadding;

  static EdgeInsets get safeAreaPadding => _safeAreaPadding;

  static Size deviceSize() => _deviceSize;
  static Size _deviceSize;

  static double keyboardHeight() => _keyboardHeight;
  static double _keyboardHeight = 0;

  static bool get isKeyboardPresented => _keyboardHeight > 0;

  static final Random _random = Random();

  /// https://gis.stackexchange.com/a/80408
  static bool isInsideChina(Coordinates coordinates) {
    // *China BBOX*
    //[17.9996, 73.4994136, 53.5609739, 134.7754563]
    const List<double> chinaBoundingBox = [
      17.9996,
      73.4994136,
      53.5609739,
      134.7754563
    ];

    return isInsideBoundingBox(
        bbox: chinaBoundingBox,
        lat: coordinates.latitude,
        lon: coordinates.longitude);

    //return 106.38 + coordinates.longitude - 0.666 * coordinates.latitude < 0;
  }

  static bool isInsideBoundingBox({List<double> bbox, double lat, double lon}) {
    /*
    Translated from:

    const inBoundingBox = ({bbox, lat, lon}) => {
      if (!bbox || bbox.length !== 4) throw Error('Bad bounding box');
      if (!lat || !lon) throw Error('Bad lat lon params');
      // minimum latitude, minimum longitude, maximum latitude, maximum longitude
      const [latMin, lonMin, latMax, lonMax] = bbox;
      const latInRange = latMin < lat && lat < latMax;
      const lonInRange = lonMin < lon && lon < lonMax;
      return latInRange && lonInRange
    };
    export default inBoundingBox

    */

    if (bbox == null || bbox.length != 4) {
      AppLogger.log('Bad bounding box');
      return false;
    }

    if (lat == null || lon == null) {
      AppLogger.log('Bad lat lon params');
      return false;
    }

    // minimum latitude, minimum longitude, maximum latitude, maximum longitude
    double latMin = bbox[0];
    double lonMin = bbox[1];
    double latMax = bbox[2];
    double lonMax = bbox[3];

    bool latInRange = latMin < lat && lat < latMax;
    bool lonInRange = lonMin < lon && lon < lonMax;

    return latInRange && lonInRange;
  }

  static bool get isInReleaseMode => !isInDebugMode;

  /// https://github.com/flutter/flutter/wiki/Flutter's-modes
  static bool get isInDebugMode {
    if (_isInDebugMode == null) {
      _isInDebugMode = false;
      // From: https://stackoverflow.com/questions/49707028/check-if-running-app-is-in-debug-mode
      assert(_isInDebugMode = true); // Because assert runs only in debug mode.
    }

    return _isInDebugMode;
  }

  static bool _isInDebugMode;

  // From: https://pub.dartlang.org/packages/fluttertoast
  static void toast(String toastMessage) {
    NativeBridge.showToast(toastMessage);
//    Fluttertoast.showToast(
//        msg: toastMessage,
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.BOTTOM,
//        timeInSecForIos: 3,
//        backgroundColor: Colors.white.withOpacity(0.7),
//        textColor: Colors.black);
  }

  static void init() {
    // Prevent multiple initializations....
    if (_appPlatform != null) return;

    _setCurrentPlatform(Platform.isIOS ? AppPlatform.ios : AppPlatform.android);

    NativeBridge.init();

    _locationHelper = LocationHelper();
  }

  static bool get isLandscapeMode => screenSize().width > screenSize().height;

  static bool get isPortraitMode => !isLandscapeMode;

  static void updateKeyboardHeight(double keyboardHeight) {
    if (_keyboardHeight != keyboardHeight) {
      _keyboardHeight = keyboardHeight;
      LocalBroadcast.notifyEvent(
          AppObserver.Key_KEYBOARD_DID_CHANGE, _keyboardHeight);
    }
  }

  static bool updateScreenDensity(double pixelRatio) {
    if (pixelRatio == null || pixelRatio == 0) return false;

    _screenDensity = pixelRatio;
    return true;
  }

  // Tip: In release mode, the UI is presented "too fast" and then the size values are zero: https://github.com/flutter/flutter/issues/25827
  static bool updateScreenSize(Size screenSize) {
    if (screenSize == null || screenSize.width == 0 || screenSize.height == 0)
      return false;

    if (_screenSize == null) {
      _screenSize = screenSize;
      _deviceSize = _screenSize;
      AppLogger.log("screenSize = $screenSize", withStackTrace: false);
    } else if (_screenSize.width != screenSize.width) {
      // Device is rotated / Changed configuration
      _screenSize = screenSize;
      LocalBroadcast.notifyEvent(
          AppObserver.Key_DID_CHANGE_SCREEN_ROTATION, _screenSize);
    }

    return true;
  }

  static void onAppTerminate() {
    _locationHelper?.stop();
  }

  static void errorVibrate() {
    HapticFeedback.mediumImpact();
  }

  static void feedbackVibrate() {
    HapticFeedback.selectionClick();
  }

  static void doTheHaptic() {
    feedbackVibrate();
  }

  static Future sleep(int milliseconds) async {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  static celsiusToFahrenheit(double c) {
    return (c * 1.8) + 32;
  }

  static fahrenheitToCelsius(double f) {
    return (f - 32) / 1.8;
  }

  static num max(dynamic num1, dynamic num2) {
    return num1 > num2 ? num1 : num2;
  }

  static num min(num num1, num num2) {
    return num1 < num2 ? num1 : num2;
  }

  static num abs(num someNumber) {
    if (someNumber < 0) return someNumber * -1;

    return someNumber;
  }

  // From: https://stackoverflow.com/questions/7490660/converting-wind-direction-in-angles-to-text-words
  static String azimuthDegreesToCardinal(
      {num degrees, bool withAcronyms = false}) {
    if (degrees == null) return "";
    if (degrees < 0) return "";

    List<String> cardinals = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];
    String cardinal;
    // The operator x ~/ y is more efficient than (x / y).toInt().
    int cardinalIndex = ((degrees.toInt() % 360) ~/ 45);
    if (cardinals.length > cardinalIndex) {
      cardinal = cardinals[cardinalIndex];
    } else {
      AppLogger.log(
          "Failed to extract index ($cardinalIndex) from azimuth $degrees");
    }

    //return cardinals[(int)Math.Round(((double)degrees % 360) / 45)];
    return cardinal;
  }

  static String azimuthDegreesToCardinalDetailed(
      {num degrees, bool withAcronyms = false}) {
    if (degrees == null) return "";
    if (degrees < 0) return "";

    degrees *= 10;

    List<String> cardinals = [
      "N",
      "NNE",
      "NE",
      "ENE",
      "E",
      "ESE",
      "SE",
      "SSE",
      "S",
      "SSW",
      "SW",
      "WSW",
      "W",
      "WNW",
      "NW",
      "NNW",
      "N"
    ];
    String cardinal;
    // The operator x ~/ y is more efficient than (x / y).toInt().

    int cardinalIndex = (degrees.toInt() % 3600) ~/ 225;
    if (cardinals.length > cardinalIndex) {
      cardinal = cardinals[cardinalIndex];
    } else {
      AppLogger.log(
          "Failed to extract index ($cardinalIndex) from azimuth $degrees");
    }

    //return cardinals[(int)Math.Round(((double)degrees % 3600) / 225)];
    return cardinal;
  }

  static double degreesToRadians(double degrees) {
    return degrees / 180.0 * pi;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  /// Returns a number between 0.0 - 100.0
  static double percentage(num ofValue, num fromValue) {
    return ofValue / fromValue * 100; // Example: 50 / 2000 * 100 == 2.5%
  }

  static double valueOf(num percentage, num fromValue) {
    percentage = max(0, percentage);
    return fromValue * percentage / 100; // Example: 2000 * 2.5% / 100 == 50
  }

  static void debugToast(dynamic toastMessage) {
    _debugToast(toastMessage?.toString() ?? "null");
  }

  static void _debugToast(String toastMessage) {
    if (!Utils.isInDebugMode) return;
    toast(toastMessage);
  }

  static availableScreenHeight() {
    return screenSize().height - _keyboardHeight;
  }

  static bool isBetween(num number, num x, num y, [bool inclusive]) {
    if (inclusive == null) {
      inclusive = true;
    }
    num min = Utils.min(x, y);
    num max = Utils.max(x, y);

    if (inclusive) {
      return number <= max && number >= min;
    } else {
      return number < max && number > min;
    }
  }

  static void runAfterDelay(Duration duration, VoidCallback closure) {
    if (closure == null) return;
    sleep(duration.inMilliseconds).whenComplete(() {
      closure();
    });
  }

  static void setIsRunningOnSimulator(bool isRunningOnSimulator) {
    _isRunningOnSimulator = isRunningOnSimulator ?? false;
  }

  static bool isRunningOnDevelopmentEnvironment() {
    return true; //_environment == Environment.development;
  }

  static void goToAppStore() async {
//    openAppInStore();
  }

  static void openEmailApp(String subject, String body, [String to]) async {
    if (Utils.isRunningOnSimulator && Utils.isInDebugMode) {
      Utils.debugToast("imagine the email compose screen 🤗");
      return;
    }

    List<String> recipients;

    if (to != null) {
      recipients = [to];
    }

    if (Utils.currentPlatform == AppPlatform.ios) {
      final MailOptions mailOptions = MailOptions(
        body: body,
        subject: subject,
        recipients: recipients,
        isHTML: false,
      );
      await FlutterMailer.send(mailOptions);
    } else {
      String url = "mailto:$to?subject=$subject&body=$body";
      bool isUrlSupported = await canLaunch(url);
      if (isUrlSupported) {
        await launch(url);
      } else {
        AppLogger.error('Failed to launch url: $url');
      }
    }
  }

  static void openAppInStore() async {
    String url = Utils.currentPlatform == AppPlatform.ios
        ? Constants.IOS_APP_STORE_ADDRESS
        : Constants.ANDROID_PLAY_STORE_ADDRESS;
    bool didLaunchUrl = false;
    try {
      if (await canLaunch(url)) {
        didLaunchUrl = await launch(url);
      }
    } catch (exception) {
      AppLogger.error(exception);
    }

    if (!didLaunchUrl) {
      AppLogger.error('Failed to launch url: $url');
    }
  }

  static void _setCurrentPlatform(AppPlatform appPlatform) {
    _appPlatform = appPlatform;
  }

  static String toDateString(DateTime time, String format) {
    if (time == null) {
      AppLogger.error("Time is null!");
      return "";
    }
    // Example: 'yyyy-MM-dd – kk:mm'
    return DateFormat(format).format(time);
  }

//  static Future openWebView(String url) async {
//    //NativeBridge.openWebView(Constants.URL_PRIVACY_POLICY);
//    bool didLaunchUrl = false;
//    try {
//      if (await canLaunch(url)) {
//        didLaunchUrl = await launch(url);
//      }
//    } catch (exception) {
//      AppLogger.error(exception);
//    }
//
//    if (!didLaunchUrl) {
//      AppLogger.error('Failed to launch url: $url');
//    }
//  }

  static void goToSettings() {
    NativeBridge.openDeviceSettings();
  }

  static DateTime now([worldClock = true]) {
    if (_worldClockDiffMilliseconds == 0) {
//      syncWorldClockDiffMilliseconds();
    }

    return DateTime.now().add(
        Duration(milliseconds: worldClock ? _worldClockDiffMilliseconds : 0));
  }

  static void shareAppInstallationLink() {
    String body =
        "How good is your air quality? Check with this app!\n\nInstall through: ${Constants.URL_INSTALLATION_LINK}";
    String subject = '${Constants.APP_NAME} Mobile App';
    shareText(subject, body);
  }

  static void shareText(String subject, [String body]) {
    subject ??= '${Constants.APP_NAME} Mobile App';
    body ??= subject;
    NativeBridge.shareText(subject, body);
  }

  static bool isAppStoreVersion() {
    return !isRunningOnDevelopmentEnvironment() && isInReleaseMode;
  }

  static void updateSafeAreaPadding(EdgeInsets safeAreaPadding) {
    if (_safeAreaPadding == null) {
      _safeAreaPadding = safeAreaPadding;
    }
  }

  static bool xor(bool condition1, bool condition2) {
    return condition1 && !condition2 || condition2 && !condition1;
  }

  /// Randomly chooses a number in the range of a - b, exclusively! (the max value will never be chosen)
  static int random(int a, int b, {bool inclusive = false}) {
    if (a == null) return b;
    if (b == null) return a;

    int _min = min(a, b);
    int _max = max(a, b);

    if (inclusive) {
      _max += 1;
      if (_max == _min) return _min;
    } else {
      if (_max - 1 == _min) return _min;
    }

    int diff = _max - _min;

    return _random.nextInt(diff) + _min;
  }

  static void updateRealTime(DateTime realTime) {
    if (realTime == null) {
      _worldClockDiffMilliseconds = 0;
    } else {
      _worldClockDiffMilliseconds = DateTime.now()
          .subtract(Duration(hours: 3))
          .difference(realTime)
          .inMilliseconds;
      if (_worldClockDiffMilliseconds != 0) {
        // Considering "round trip"?
        //_worldClockDiffMilliseconds = (_worldClockDiffMilliseconds.toDouble() / 2.0).floor();
        var diffMessage =
            "Diff milliseconds is set: $_worldClockDiffMilliseconds";
        AppLogger.log(diffMessage);
        //Utils.debugToast(diffMessage);
      }
    }
  }

//  static void syncWorldClockDiffMilliseconds() async {
//    if (_worldClockDiffMilliseconds > 0) return;
//    _worldClockDiffMilliseconds = 1;
//
//    AppLogger.log("syncWorldClockDiffMilliseconds began...");
//    DateTime time;
//
//    DateTime roundTripStart = DateTime.now();
//    try {
//      final response = await client.get("http://worldclockapi.com/api/json/utc/now");
//
//      if (response.statusCode == 200) {
//        Map<String, dynamic> jsonObject = json.decode(response.body);
//        AppLogger.log(jsonObject);
//        if (jsonObject == null) return;
//        time = Parser.parseDateFromIsoString(jsonObject["currentDateTime"]);
//
//        DateTime roundTripEnd = DateTime.now();
//        Duration roundTripDuration = roundTripEnd.difference(roundTripStart);
//        roundTripDuration = Duration(
//            milliseconds:
//                (roundTripDuration.inMilliseconds.toDouble() / 2.0).floor());
//        time.subtract(roundTripDuration);
//      }
//    } catch (error) {
//      if (error is SocketException) {
//        LocalBroadcast.notifyEvent(AppObserver.Key_SOCKET_EXCEPTION);
//      }
//      AppLogger.error(error);
//    }
//
//    Utils.updateRealTime(time);
//
  //Utils.debugToast(Utils.now().toString());
//  }

  static void test() async {
    if (Utils.isAppStoreVersion()) return;

    //testFiresJsonParsing();

//    for (int i = -10; i < 500; i++) {
//      AppLogger.log(
//          "Azimuth: $i -> ${Strings.toAzimuthString(i, withAcronyms: true)}",
//          withStackTrace: false);
//    }
//
//    for (int i = -10; i < 500; i++) {
//      AppLogger.log("Azimuth: $i -> ${Strings.toAzimuthString(i)}",
//          withStackTrace: false);
//    }

    AppLogger.log(
        "testing Duration to String: ${Utils.toDurationString(Duration(days: 1, hours: 60, minutes: 80, seconds: 70))}");
    AppLogger.log(
        "testing Duration to String: ${Utils.toDurationString(Duration(days: 1, hours: 10, minutes: 80, seconds: 70))}");

    try {
      assert(Parser.parseDateFromIsoString("2019-05-02T14:16Z") != null);
      assert(Parser.parseDateFromIsoString("2019-05-02T14:16") != null);
      assert(Parser.parseDateFromIsoString("2019-05-02T14:16:53Z") != null);
      assert(Parser.parseDateFromIsoString("2019-05-02") != null);

      assert(Parser.tryParseInt("", null) == null);
      assert(Parser.tryParseInt("", -3) == -3);
      assert(Parser.tryParseInt("ds", -3) == -3);
      assert(Parser.tryParseInt("-9", -3) == -9);
      assert(Parser.tryParseDouble("-9", -3) == -9.0);
      assert(Parser.tryParseDouble("sda", -3.0) == -3.0);
    } catch (error) {
      String errorMessage = "Test failed! $error";
      AppLogger.error(errorMessage);
      Utils.debugToast(errorMessage);
    }
  }

  static DateTime ceilHour(DateTime dateTime) {
    if (dateTime == null) return null;

    int secondsForCeiling = 60 - dateTime.second;
    int minutesForCeiling = 59 - dateTime.minute;
    return dateTime
        .add(Duration(minutes: minutesForCeiling, seconds: secondsForCeiling));
  }

  static DateTime floorHour(DateTime dateTime) {
    if (dateTime == null) return null;

    return dateTime
        .add(Duration(minutes: -dateTime.minute, seconds: -dateTime.second));
  }

//  static List<FireModel> testFiresJsonParsing() {
//    Map<String, dynamic> responseJson = json.decode(FireModel.example);
//    Map<String, dynamic> dataJson = responseJson['data'] ?? json;
//    List firesJson = dataJson['fires'];
//    List<FireModel> fires = [];
//    for (dynamic fireJson in firesJson) {
//      FireModel fireModel = FireModel.fromJson(fireJson);
//      //AppLogger.log(fireModel, withStackTrace: false);
//      fires.add(fireModel);
//    }
//
//    return fires;
//  }

  static String toDurationString(Duration duration) {
    int minutes = duration.inMinutes;
    int hours = duration.inHours;
    int days = duration.inDays;

    return "${days > 0 ? days : (hours > 0 ? hours : minutes)} ${days > 0 ? Localized.string('${"day${days == 1 ? '' : 's'}"}') : (hours > 0 ? Localized.string('${"hour${hours == 1 ? '' : 's'}"}') : Localized.string('${"minute${minutes == 1 ? '' : 's'}"}'))}";
  }

  static num kilometersToMiles(num kilometers) {
    return kilometers.toDouble() * 0.621371;
  }

  static num milesToKilometers(num speed) {
    return 1 / kilometersToMiles(speed).toDouble();
  }

  static Future<String> scan() async {
    String barcode;

    try {
      barcode = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        AppLogger.error('The user did not grant the camera permission!');
      } else {
        AppLogger.error('Unknown error: $e');
      }
    } on FormatException {
      AppLogger.error(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      AppLogger.error('Unknown error: $e');
    }

    return barcode;
  }
}

class Constants {
  static const String FLICKR_BASE_URL = 'https://api.flickr.com/services/rest/';
  static const String FLICKR_DEFAULT_QUERIES =
      '?method=flickr.photos.search&safe_search=1&format=json&nojsoncallback=1&content_type=1&is_getty=1';
  static const String FLICKR_API_KEY = 'your_flickr_api_key';

  static const String KeyFirstRun = "isFirstRun";
  static const String APP_NAME = "ironBreeze";
  static const String URL_INSTALLATION_LINK =
      "http://smarturl.it/breezometerapp";

  static const String ANDROID_PLAY_STORE_ADDRESS =
      'https://play.google.com/store/apps/details?id=your.app.id';
  static const String IOS_APP_STORE_ADDRESS =
      'https://itunes.apple.com/us/app/your-app-name/id<your.app.id>?mt=8';

  static const String KeyDidAlreadyAskRemoteNotificationsPermissions =
      "DidAlreadyAskRemoteNotificationsPermissions";
  static const String KeyDidAlreadyAskLocalNotificationsPermissions =
      "DidAlreadyAskLocalNotificationsPermissions";

  static const String KeyDidAlreadyAskBackgroundLocationPermissions =
      "DidAlreadyAskBackgroundLocationPermissions";
  static const String KeyDidAlreadyAskForegroundLocationPermissions =
      "DidAlreadyAskForegroundLocationPermissions";

  static const String MapsApiKey = "google-maps-api-key";

  static const String RequiresSpecialIDE = "Requires a special IDE";
  static const String Performance = "Performance";
  static const String FluentProgrammingExperience =
      "Fluent Programming Experience";
  static const String StrongHardwareRequired = "Strong Hardware Required";
  static const String RemoteUpdatesInjectionable =
      "Remote Updates Injectionable";
  static const String EasyToAdopt = "Easy To Adopt";

  static const String ImagesHeroTag = "doesn't really matters";
}

class Localized {
  static String string(String str) {
    return Strings.localized(str);
  }
}
