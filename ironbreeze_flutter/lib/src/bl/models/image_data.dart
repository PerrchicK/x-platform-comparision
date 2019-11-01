import 'package:ironbreeze/src/ui/image_viewer.dart';

class ImageData {
  final String imageUrl;
  final String imageName;

  ImageData({this.imageUrl, this.imageName});

  bool get isValid => imageUrl == null || imageName == null;
}

class ImageDataExtension {
  List<ImageData> object = [];

  ImageViewer imageViewer() {
    // extended
    return ImageViewer(imageUrl: object.last.imageUrl);
  }
}

class Extend with ImageDataExtension {
  ImageData _extended;
  Extend._create({ImageData withExtended}) : this._extended = withExtended {
    object.add(_extended);
  }

  factory Extend(ImageData extended) {
    return Extend._create(withExtended: extended);
  }
}
