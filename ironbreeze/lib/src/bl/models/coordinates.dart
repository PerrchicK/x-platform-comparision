import 'package:ironbreeze/src/bl/parser.dart';
//import 'package:location/location.dart';

class Coordinates {
  static const int DEFAULT_PRECISION = 10000;
  static const int CACHE_PRECISION = 1000;

  operator ==(dynamic other) => (other is Coordinates &&
      other.latitude == latitude &&
      other.longitude == longitude);
  int get hashCode => '${latitude.hashCode},${longitude.hashCode}'.hashCode;

  //double accuracy;
  double latitude;
  double longitude;

  Coordinates({this.latitude, this.longitude});

  bool isValid() {
    return latitude != null && longitude != null;
  }

//  Coordinates.fromData(LocationData locationData)
//      : latitude = locationData.latitude,
//        longitude = locationData.longitude;

  Coordinates.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        //accuracy = json['accuracy'],
        longitude = json['longitude'] {
    if (json['data'] != null) {
      json = json['data'];
    }

    if (latitude == null) {
      latitude = Parser.tryParseDouble(json['lat']?.toString());
    }

    if (longitude == null) {
      longitude = Parser.tryParseDouble(json['lon']?.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        //'accuracy': accuracy,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() {
    return "($latitude,$longitude)";
  }

  bool isMoreOrLessEquals(Coordinates other) {
    return other != null &&
        rounded().latitude == other.rounded().latitude &&
        rounded().longitude == other.rounded().longitude;
    //return (latitude * PRECISION).toInt() ==(other.latitude * PRECISION).toInt() &&(longitude * PRECISION).toInt() == (other.longitude * PRECISION).toInt();
  }

  Coordinates rounded([int precision = DEFAULT_PRECISION]) {
    if (!isValid()) return this;
//    return Coordinates(
//        latitude: (latitude * precision).toInt().toDouble() / precision,
//        longitude: (longitude * precision).toInt().toDouble() / precision);
    return Coordinates(
        latitude: (latitude * precision).toInt().toDouble() / precision,
        longitude: (longitude * precision).toInt().toDouble() / precision);
  }

  /// Instantiates and returns a Coordinates object from a string if the string is valid, otherwise will return null.
  static Coordinates fromString(String coordinatesString) {
    if (coordinatesString == null) return null;
    coordinatesString = coordinatesString
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll(" ", "");

    // From: https://stackoverflow.com/questions/3518504/regular-expression-for-matching-latitude-longitude-coordinates
    // Regex: ^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$
    List<String> latlng = coordinatesString.split(",");
    if (latlng.length != 2) return null;
    double lat = double.tryParse(latlng[0]);
    double lng = double.tryParse(latlng[1]);

    if (lat == null || lng == null) return null;
    if (lat > 100 || lng > 100) return null;
    //if (lat > 100 || lng > 100) return null;

    return Coordinates(latitude: lat, longitude: lng);
  }
}
