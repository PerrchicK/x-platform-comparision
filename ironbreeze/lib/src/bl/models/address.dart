import 'package:ironbreeze/src/bl/models/coordinates.dart';
import 'package:ironbreeze/src/bl/strings.dart';

class PredictionsModel {
  List<PredictionEntry> get predictions => _predictions;
  List<PredictionEntry> _predictions = List<PredictionEntry>();

  PredictionsModel({List<PredictionEntry> predictions}) {
    _predictions = predictions ?? List<PredictionEntry>();
  }

  PredictionsModel.fromJson(Map<String, dynamic> json) {
    List predictionsJson = json['predictions'];
    List<PredictionEntry> temp = [];
    predictionsJson.forEach((predictionJson) {
      var predictionEntry = PredictionEntry(
          description: predictionJson["description"],
          placeId: predictionJson["place_id"],
          predictionId: predictionJson["id"]);
      if (predictionEntry.placeId != null &&
          predictionEntry.predictionId != null) {
        temp.add(predictionEntry);
      }
    });

    _predictions = temp;
  }

  static PredictionsModel empty() {
    return PredictionsModel();
  }
}

class PredictionEntry {
  String description;
  String predictionId;
  String placeId;

  PredictionEntry({this.description, this.predictionId, this.placeId});
}

class CurrentLocationPredictionEntry extends PredictionEntry {
  CurrentLocationPredictionEntry() {
    description = Strings.localized('Use current location');
  }
}

class CustomLocationPredictionEntry extends PredictionEntry {
  Coordinates _coordinates;
  Coordinates get coordinates => _coordinates;
  CustomLocationPredictionEntry(Coordinates coordinates) {
    description = coordinates.toString();
    _coordinates = coordinates;
  }
}
