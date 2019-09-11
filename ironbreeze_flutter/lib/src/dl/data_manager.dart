import 'dart:async';

import 'package:ironbreeze/src/bl/models/image_data.dart';
import 'package:ironbreeze/src/bl/parser.dart';
import 'package:ironbreeze/src/dl/images_provider.dart';
import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:ironbreeze/src/util/app_observer.dart';
import 'package:ironbreeze/src/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PersistenceKeys {
  static const String DidShowRateUsPopup = "PersistenceKeys.DidShowRateUsPopup";
  static const String PreviousSessionsCounter =
      "PersistenceKeys.PreviousSessionsCounter";
  static const String CountOfFavoriteClicksFromMenuInSession =
      "PersistenceKeys.CountOfFavoriteClicksFromMenuInSession";
  static const String CountOfMapOpenInSessions =
      "PersistenceKeys.CountOfMapOpenInSessions";
  static const String DidShareTheApp = "PersistenceKeys.DidShareTheApp";

  static const String FireAlertTestingGroup =
      "PersistenceKeys.FireAlertTestingGroup";
  static const String IsFireAlertFeatureEnabled =
      "PersistenceKeys.IsFireAlertFeatureEnabled";
}

class DataManager {
  /// Singleton instantiation, inspired from here: https://github.com/flutter/flutter/blob/b70d260b3c17b4b37e52504b980a146c423320fd/packages/flutter/lib/src/services/raw_keyboard.dart#L460
  static final DataManager _singleton = new DataManager._internal();

  static DataManager get shared => _singleton;

  factory DataManager() {
    return _singleton;
  }

  DataManager._internal() {
    _isReady = false;
  }

  List<ImageData> _imagesData;
  List<ImageData> get imageItems => _imagesData;
  set imageItems(List<ImageData> value) {
    // Do nothing...
  }

  bool _didShareTheApp;
  set didShareTheApp(bool value) {
    if (_didShareTheApp != null) return;

    _didShareTheApp = true;
    DataManager.shared
        .load<bool>(
      PersistenceKeys.DidShareTheApp,
    )
        .then((bool didShare) {
      DataManager.shared.save<bool>(PersistenceKeys.DidShareTheApp, true);
    });
  }

  DateTime lastTimeInForeground;

  bool _isReady;
  bool didNotifyFlutterReady;

  bool get isReady => _isReady;

  Future init() async {
    // TODO Remove this mock:
    _imagesData = [
      ImageData(
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/en/0/02/Homer_Simpson_2006.png",
        imageName: "homer",
      )
    ];

    _isFetching = {};
    _flickerImagesCurrentPage = {};
    _flickerImagesData = {};

    for (var i = 0; i < 100; i++) {
      String url = 'https://picsum.photos/id/${i % 100 + 1}/250/250';
      _imagesData.add(ImageData(imageUrl: url, imageName: "image  number $i"));
    }

    for (var i = 0; i < 10; i++) {
      String url = 'https://picsum.photos/id/${i % 9 + 1}/250/250';
      _imagesData.add(ImageData(imageUrl: url, imageName: "image  number $i"));
    }

    didNotifyFlutterReady = false;

    _isReady = true;
  }

  Map<String, bool> _isFetching;
  Map<String, int> _flickerImagesCurrentPage;
  Map<String, List<ImageData>> _flickerImagesData;

  Map<String, List<ImageData>> get flickerImageItems => _flickerImagesData;

//  List<ImageData> flickerImageItems({String phrase}) {
//    return _flickerImagesData[phrase];
//  }

  Future<List<ImageData>> fetchImages({String queryText}) async {
    if (queryText?.isEmpty ?? true) return [];

    if (_isFetching[queryText] ?? false) return [];
    _isFetching[queryText] = true;

    FlickrImagesProvider flickrImagesRepository = FlickrImagesProvider();

    int flickerImagesCurrentPage =
        (_flickerImagesCurrentPage[queryText] ?? 0) + 1;
    _flickerImagesCurrentPage[queryText] = flickerImagesCurrentPage;

    var images = await flickrImagesRepository.searchImages(
        queryText: queryText, page: flickerImagesCurrentPage);
    if (images != null) {
      _flickerImagesData[queryText] ??= [];
      _flickerImagesData[queryText]?.addAll(images);
      LocalBroadcast.notifyEvent(
          LocalBroadcast.Key_ImagesListUpdated, queryText);
    }

    _isFetching[queryText] = false;

    return _flickerImagesData[queryText];
  }

  Future<bool> setFirstRun() async {
    bool didSave = await LocalStorage.save<bool>(Constants.KeyFirstRun, false);
    return didSave;
  }

  Future<bool> isFirstRun() async {
    bool _isFirstRun =
        await LocalStorage.load<bool>(Constants.KeyFirstRun, true);
    return _isFirstRun;
  }

  Future<bool> didAlreadyAskNotificationsPermissions(
      bool isRemoteNotifications) async {
    isRemoteNotifications ??= false;
    String key = isRemoteNotifications
        ? Constants.KeyDidAlreadyAskRemoteNotificationsPermissions
        : Constants.KeyDidAlreadyAskLocalNotificationsPermissions;
    bool didAskNotificationsPermissions = await LocalStorage.load<bool>(key);
    return didAskNotificationsPermissions ?? false;
  }

  void onAskedNotificationsPermissions(bool isRemoteNotifications) {
    isRemoteNotifications ??= false;
    String key = isRemoteNotifications
        ? Constants.KeyDidAlreadyAskRemoteNotificationsPermissions
        : Constants.KeyDidAlreadyAskLocalNotificationsPermissions;
    LocalStorage.save(key, true);
  }

  Future<bool> didAlreadyAskLocationPermissions(
      bool isBackgroundLocationPermission) async {
    String key = isBackgroundLocationPermission
        ? Constants.KeyDidAlreadyAskBackgroundLocationPermissions
        : Constants.KeyDidAlreadyAskForegroundLocationPermissions;
    bool didAskLocationPermissions = await LocalStorage.load<bool>(key);
    return didAskLocationPermissions ?? false;
  }

  void onAskedLocationPermissions(bool isBackgroundLocationPermission) {
    String key = isBackgroundLocationPermission
        ? Constants.KeyDidAlreadyAskBackgroundLocationPermissions
        : Constants.KeyDidAlreadyAskForegroundLocationPermissions;
    LocalStorage.save(key, true);
  }

  Future<bool> save<T>(String key, T value) async {
    return await LocalStorage.save<T>(key, value);
  }

  Future<T> load<T>(String key, [T defaultValue]) async {
    return await LocalStorage.load<T>(key, defaultValue);
  }

  Future<bool> delete(String key) async {
    return await LocalStorage.remove(key);
  }

  String randomCommunicationErrorSentence() {
    return Localized.string('🐢 Ok, it takes toooo long...');
  }

  String randomMissingDataErrorSentence() {
    return Localized.string('No data yet...');
  }

  Map<int, Map<String, double>> importance = {
    Framework.cordova.index: {
      Constants.Performance: 0.0,
      Constants.FluentProgrammingExperience: 0.2,
      Constants.StrongHardwareRequired: 0.3,
      Constants.RemoteUpdatesInjectionable: 0.2,
      Constants.EasyToAdopt: 0.2,
      Constants.RequiresSpecialIDE: 0.1,
    },
    Framework.react.index: {
      Constants.Performance: 0.3,
      Constants.FluentProgrammingExperience: 0.1,
      Constants.StrongHardwareRequired: 0.3,
      Constants.RemoteUpdatesInjectionable: 0.1,
      Constants.EasyToAdopt: 0.2,
      Constants.RequiresSpecialIDE: 0.0,
    },
    Framework.flutter.index: {
      Constants.Performance: 0.3,
      Constants.FluentProgrammingExperience: 0.3,
      Constants.StrongHardwareRequired: 0.1,
      Constants.RemoteUpdatesInjectionable: 0.0,
      Constants.EasyToAdopt: 0.2,
      Constants.RequiresSpecialIDE: 0.1,
    }
  };

  Map<String, double> userPreferences = {
    Constants.Performance: 0.0,
    Constants.FluentProgrammingExperience: 0.0,
    Constants.StrongHardwareRequired: 0.0,
    Constants.RemoteUpdatesInjectionable: 0.0,
    Constants.EasyToAdopt: 0.0,
    Constants.RequiresSpecialIDE: 0.0,
  };
}

enum Framework { cordova, react, flutter }

class LocalStorage {
  static Future<bool> save<T>(String key, T value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool didSave = false;

    switch (T) {
      case int:
        didSave = await prefs.setInt(key, int.parse('$value'));
        break;
      case bool:
        didSave = await prefs.setBool(key, Parser.tryParseBool('$value'));
        break;
      case String:
        didSave = await prefs.setString(key, '$value');
        break;
      case double:
        didSave = await prefs.setDouble(key, double.tryParse('$value'));
        break;
      default:
        AppLogger.error('Failed to save value: $value');
        break;
//      case int:
//        await prefs.setStringList(key, '$value');
    }

    return didSave;
  }

  static Future<T> load<T>(String key, [T defaultValue]) async {
    T value = defaultValue;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (T) {
      case int:
        value = ((prefs.getInt(key)) as T) ?? defaultValue;
        break;
      case bool:
        value = ((prefs.getBool(key)) as T) ?? defaultValue;
        break;
      case String:
        value = ((prefs.getString(key)) as T) ?? defaultValue;
        break;
      case double:
        value = ((prefs.getDouble(key)) as T) ?? defaultValue;
        break;
      default:
        AppLogger.error('Failed to load value for key: $key');
        value = defaultValue;
        break;
//      case int:
//        await prefs.setStringList(key, '$value');
    }

    return value;
  }

  static Future<bool> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
