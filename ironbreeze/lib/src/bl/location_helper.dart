import 'dart:async';
import 'dart:convert';

import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:ironbreeze/src/util/native_bridge.dart';

import 'models/coordinates.dart';

class LocationHelper {
  static final LocationHelper shared = new LocationHelper._internal();

  double currentLongitude;
  double currentLatitude;

  factory LocationHelper() {
    shared.init();
    return shared;
  }

  void init() {
    //refreshPermissionsAuthorization();
  }

  void stop() {
    //_quitLocationObservation();
  }

  LocationHelper._internal() {
//    _locationManager = new Location();
  }

  void refreshPermissionsAuthorization() {}

  Future<List> addressAutocomplete(String prefix) async {
    List predictions;
//    Geolocator geolocator = Geolocator();
//    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(latitude, longitude);
//    if (placemark != null) {
//      AppLogger.log(placemark);
//    }

//    return [];
    var result = await NativeBridge.invokeNativeMethod(
        "address_autocomplete", {"phrase": prefix});
    var parsedPredictions;
    if ((result?.length ?? 0) > 0) {
      try {
        parsedPredictions = json.decode(result);
      } catch (exception) {
        AppLogger.error(exception);
      }
    }

    if (parsedPredictions != null && parsedPredictions is List) {
      predictions = parsedPredictions;
    } else {
      //tuple = LocationHelper.shared.reverseGeocode(latitude, longitude);
      predictions = [];
    }

    return predictions;
  }

  Future<List> reverseGeocode(double latitude, double longitude) async {
    List tuple;
//    Geolocator geolocator = Geolocator();
//    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(latitude, longitude);
//    if (placemark != null) {
//      AppLogger.log(placemark);
//    }

//    return [];
    var result = await NativeBridge.invokeNativeMethod("reverse_geocode",
        Coordinates(latitude: latitude, longitude: longitude).toJson());
    var parsedTuple = json.decode(result);
    if (parsedTuple != null && parsedTuple is List) {
      tuple = parsedTuple;
    } else {
      //tuple = LocationHelper.shared.reverseGeocode(latitude, longitude);
    }

    return tuple;
  }

  Future<Map> placeLocation(String placeId) async {
    var coordinateJsonString = await NativeBridge.invokeNativeMethod(
        "fetch_place_location", {"placeId": placeId});
    var coordinateJson = json.decode(coordinateJsonString);
    AppLogger.log(coordinateJson);

    if (!(coordinateJson is Map)) {
      coordinateJson = {"stam": "empty"};
    }

    return coordinateJson;
  }
}
/*

  StreamSubscription<LocationData> _locationSubscription;
  Function(double, double) _locationListener;
  double currentLongitude;
  double currentLatitude;
  double currentAccuracy;

  Location _locationManager;
  bool _isForegroundPermissionGranted;
  bool get isForegroundPermissionGranted => _isForegroundPermissionGranted;
  bool _isBackgroundPermissionGranted;
  bool get isBackgroundPermissionGranted => _isBackgroundPermissionGranted;

  Future<bool> isPermissionGranted(
      [bool isBackgroundLocationPermission]) async {
    isBackgroundLocationPermission ??= false;
    bool isCurrentlyOnIos = Utils.currentPlatform == AppPlatform.ios;

    bool isPermissionGranted = false;
    if (isCurrentlyOnIos) {
      String result = await NativeBridge.isLocationPermissionGranted(
          isBackgroundLocationPermission);
      isPermissionGranted = result == "permission is granted";
      if (isBackgroundLocationPermission) {
        _isBackgroundPermissionGranted = isPermissionGranted;
      } else {
        _isForegroundPermissionGranted = isPermissionGranted;
      }

      if (_isBackgroundPermissionGranted) {
        _isForegroundPermissionGranted = true;
      }
    } else {
      _isForegroundPermissionGranted = await _locationManager.hasPermission();
      isPermissionGranted = _isForegroundPermissionGranted;

      if (Utils.currentPlatform == AppPlatform.android) {
        _isBackgroundPermissionGranted = _isForegroundPermissionGranted;
      }
    }

    return isPermissionGranted;
  }

  Future start([Function(double, double) locationListener]) async {
    if (locationListener != null) {
      _locationListener = locationListener;
      LocationData result = await _locationManager.getLocation();
      Coordinates locationParams =
          Coordinates(latitude: result.latitude, longitude: result.longitude);
      currentAccuracy = result.accuracy;
      currentLatitude = locationParams.latitude;
      currentLongitude = locationParams.longitude;

      locationListener(currentLatitude, currentLongitude);
    }

    //_observeLocation();
  }

  Future<void> requestPermissions(BuildContext context,
      [bool isBackgroundLocationPermission]) async {
    isBackgroundLocationPermission ??= false;
    bool shouldGoToSettings;
    bool isCurrentlyOnIos = Utils.currentPlatform == AppPlatform.ios;

    if (isCurrentlyOnIos) {
      // Only in iOS, the app cannot ask for permissions more than once. Otherwise the user needs to approve by himself.
      shouldGoToSettings = await DataManager.shared
          .didAlreadyAskLocationPermissions(isBackgroundLocationPermission);
    } else {
      // If the app's running on Android, there's no need to open settings, simply ask!
      shouldGoToSettings = false;
    }

    if (shouldGoToSettings) {
//      UiFactory.alert(
//          context,
//          Localized.string('Missing permissions'),
//          Localized.string(
//              '${isBackgroundLocationPermission ? 'Background location' : 'Location'} permission is needed, please approve...'),
//          Strings.localized('Go to settings'), () {
//        Utils.goToSettings();
//      });
    } else {
      DataManager.shared
          .onAskedLocationPermissions(isBackgroundLocationPermission);

      if (isCurrentlyOnIos) {
        String stam = await NativeBridge.requestLocationPermission(
            isBackgroundLocationPermission);
      } else {
        // on Android...
        bool didApproveLocationPermission =
            await _locationManager.requestPermission();
        //Utils.debugToast("didApproveLocationPermission == $didApproveLocationPermission");

        _isForegroundPermissionGranted = didApproveLocationPermission;
        if (Utils.currentPlatform == AppPlatform.android) {
          _isBackgroundPermissionGranted = _isForegroundPermissionGranted;
        }
        LocalBroadcast.notifyEvent(AppObserver.Key_ON_LOCATION_PERMISSION_CHANGED);
      }

      return null;
    }
  }

  Future<Coordinates> get currentLocation async {
    if (!_isForegroundPermissionGranted) return null;

    try {
      LocationData locationData = await _locationManager.getLocation();
      Coordinates coordinates = Coordinates.fromData(locationData);
      //Configurations.shared.setDeviceLocation(coordinates);
      return coordinates;
    } catch (error) {
      AppLogger.error(error);
      return null;
    }
  }

  void _quitLocationObservation() {
//    _locationSubscription?.pause();
    _locationSubscription?.cancel();
  }

  void _observeLocation() {
    _locationSubscription = _locationManager.onLocationChanged().listen(
        (LocationData locationData) {
      Coordinates locationParams = Coordinates(
          latitude: locationData.latitude, longitude: locationData.longitude);
      currentAccuracy = locationData.accuracy;
      currentLatitude = locationParams.latitude;
      currentLongitude = locationParams.longitude;

      if (_locationListener != null) {
        _locationListener(currentLatitude, currentLongitude);
      }
    }, onError: (error) {
      AppLogger.error("Error in getting location! Error: $error");
    }, onDone: () {
      //AppLogger.log("Done getting location...");
    }, cancelOnError: false);
  }

  Future<bool> isLocationSensorEnabled() async {
    bool isCurrentlyOnIos = Utils.currentPlatform == AppPlatform.ios;
    if (isCurrentlyOnIos) return true;
    String result =
        await NativeBridge.invokeNativeMethod('is_location_sensor_enabled');
    return result == "is_on";
  }

  Future<List> addressAutocomplete(String prefix) async {
    List predictions;
//    Geolocator geolocator = Geolocator();
//    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(latitude, longitude);
//    if (placemark != null) {
//      AppLogger.log(placemark);
//    }

//    return [];
    var result = await NativeBridge.invokeNativeMethod(
        "address_autocomplete", {"phrase": prefix});
    var parsedPredictions;
    if ((result?.length ?? 0) > 0) {
      try {
        parsedPredictions = json.decode(result);
      } catch (exception) {
        AppLogger.error(exception);
      }
    }

    if (parsedPredictions != null && parsedPredictions is List) {
      predictions = parsedPredictions;
    } else {
      //tuple = LocationHelper.shared.reverseGeocode(latitude, longitude);
      predictions = [];
    }

    return predictions;
  }

  Future<List> reverseGeocode(double latitude, double longitude) async {
    List tuple;
//    Geolocator geolocator = Geolocator();
//    List<Placemark> placemark = await geolocator.placemarkFromCoordinates(latitude, longitude);
//    if (placemark != null) {
//      AppLogger.log(placemark);
//    }

//    return [];
    var result = await NativeBridge.invokeNativeMethod("reverse_geocode",
        Coordinates(latitude: latitude, longitude: longitude).toJson());
    var parsedTuple = json.decode(result);
    if (parsedTuple != null && parsedTuple is List) {
      tuple = parsedTuple;
    } else {
      //tuple = LocationHelper.shared.reverseGeocode(latitude, longitude);
    }

    return tuple;
  }
}
*/
