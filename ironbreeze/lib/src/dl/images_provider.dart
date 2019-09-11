import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:ironbreeze/src/bl/models/image_data.dart';
import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:ironbreeze/src/util/utils.dart';

class FlickrImagesProvider {
  final Client client = Client();
  static const int DEFAULT_IMAGES_PER_PAGE = 30;
  static const int DEFAULT_PAGE = 1;

  String getSearchURL(query, page, perPage) {
    return '${Constants.FLICKR_BASE_URL}${Constants.FLICKR_DEFAULT_QUERIES}&api_key=${Constants.FLICKR_API_KEY}&text=$query&page=$page&per_page=$perPage';
  }

  String buildImageURL({int farm, String server, String id, String secret}) {
    if ([farm, server, id, secret].contains(null)) return null;
    return 'https://farm$farm.staticflickr.com/$server/${id}_$secret.jpg';
  }

  Future<List<ImageData>> searchImages(
      {String queryText,
      int page = DEFAULT_PAGE,
      int perPage = DEFAULT_IMAGES_PER_PAGE}) async {
    List<ImageData> images;

    try {
      final response = await client.get(getSearchURL(queryText, page, perPage));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        var jsonObject = json.decode(response.body);
        //AppLogger.log(jsonObject);
        var photosJson = jsonObject["photos"] ?? {};
        List<dynamic> urls = photosJson["photo"]?.map((imageData) {
          var url = buildImageURL(
              farm: imageData["farm"],
              server: imageData["server"],
              id: imageData["id"],
              secret: imageData["secret"]);
          //AppLogger.log(url);
          return url;
        })?.toList();

        // "filter"
        urls?.removeWhere((element) {
          return element == null;
        });

        //AppLogger.log(urls);

        images = urls?.map((e) {
          return ImageData(imageUrl: e.toString(), imageName: queryText);
        })?.toList();
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load images list');
      }
    } catch (exception) {
      AppLogger.error(exception);
    }

    return images;
  }
}
