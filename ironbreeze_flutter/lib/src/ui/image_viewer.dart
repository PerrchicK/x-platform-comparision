import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;

  const ImageViewer({Key key, this.imageUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            UiFactory.alert(context: context, title: "URL", body: imageUrl);
          },
          child: Text(imageUrl),
        ),
      ),
      body: CachedNetworkImage(
        // More about image downloads without caching: https://www.woolha.com/tutorials/flutter-display-image-from-network-url-show-loading
        cacheManager: DefaultCacheManager(),
        imageUrl: imageUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
      ),
    );
  }
}
