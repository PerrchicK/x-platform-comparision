class ImageData {
  final String imageUrl;
  final String imageName;

  ImageData({this.imageUrl, this.imageName});

  bool get isValid => imageUrl == null || imageName == null;
}
