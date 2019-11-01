import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ironbreeze/src/bl/models/image_data.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';
import 'package:ironbreeze/src/util/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ImageCell extends StatefulWidget {
  static const double SIZE = 200;
  final ImageData data;

  ImageCell({@required this.data});

  @override
  State<StatefulWidget> createState() {
    return _ImageCellState();
  }
}

enum ImageCellState { image, qr }

class _ImageCellState extends State<ImageCell> {
  ImageCellState imageCellState;
  @override
  void initState() {
    imageCellState = ImageCellState.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Utils.screenSize().width,
      height: ImageCell.SIZE + 100,
      child: GestureDetector(
        onTap: _toggleQr,
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Extend(widget.data)
                  .imageViewer(), // ImageViewer(imageUrl: widget.data.imageUrl),
            ),
          );
        },
        child: Column(
          children: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: imageCellState == ImageCellState.image
                  ? Container(
                      width: ImageCell.SIZE,
                      height: ImageCell.SIZE,
                      // More about image downloads without caching: https://www.woolha.com/tutorials/flutter-display-image-from-network-url-show-loading
                      child: CachedNetworkImage(
                        fit: BoxFit.contain,
                        cacheManager: DefaultCacheManager(),
                        imageUrl: widget.data.imageUrl,
                        placeholder: (context, url) => Scaled(
                          scale: 0.5,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : QrImage(
                      data: widget.data.imageUrl,
                      size: ImageCell.SIZE,
                    ),
            ),
            Text(
              '${widget.data.imageName}',
              style: UiFactory.styleForImageCell(),
            )
          ],
        ),
      ),
    );
  }

  get _toggleQr => () {
        setState(() {
          imageCellState = imageCellState.index == ImageCellState.image.index
              ? ImageCellState.qr
              : ImageCellState.image;
        });
      };
}
