import 'package:flutter/material.dart';
import 'package:ironbreeze/src/bl/models/image_data.dart';
import 'package:ironbreeze/src/bl/strings.dart';
import 'package:ironbreeze/src/communication/local_broadcast.dart';
import 'package:ironbreeze/src/dl/data_manager.dart';
import 'package:ironbreeze/src/ui/refreshable_widget.dart';
import 'package:ironbreeze/src/util/throttler.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';
import 'package:ironbreeze/src/util/utils.dart';

import 'image_cell.dart';

class ImagesListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagesListScreenState();
  }
}

class _ImagesListScreenState extends State<ImagesListScreen> {
  final Throttler throttler = Throttler(duration: Duration(milliseconds: 250));
  final TextEditingController _searchInputText = new TextEditingController();
  TextField _searchInputField;
  FocusNode _searchInputTextFocusNode;

  ScrollController _scrollController;
  DataManager get dataManager => DataManager();

  get _onSearchTextChanged => () {
        throttler.throttle(() async {
          dataManager.fetchImages(queryText: searchText);
        });
      };

  String get searchText => _searchInputText.text;
  List<ImageData> get items => dataManager.flickerImageItems[searchText] ?? [];

  @override
  void initState() {
    _scrollController = ScrollController(debugLabel: "images list");
    _scrollController.addListener(() {
      //AppLogger.log(_scrollController.offset);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreData();
      }
    });
    _searchInputText.addListener(_onSearchTextChanged);
    _searchInputTextFocusNode = FocusNode();

    _searchInputField = TextField(
      onSubmitted: (String searchText) {
        dataManager.fetchImages(queryText: searchText);
      },
      textInputAction: TextInputAction.search,
      textAlign: TextAlign.start,
      focusNode: _searchInputTextFocusNode,
      controller: _searchInputText,
      decoration: new InputDecoration(
        prefixIcon: new Icon(Icons.search),
        hintText: Localized.string("type a word..."),
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Hero(
                tag: Constants.ImagesHeroTag,
                child: Material(
                  child: SizedBox(
                    width: Utils.screenSize().width,
                    child: Text(
                      Strings.imagesListScreen,
                      style: UiFactory.styleForScreenTitle(fontSize: 12),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: Utils.screenSize().width,
                child: _searchInputField,
              ),
            ),
          ],
        ),
      ),
      body: ObservingWidget(
        observedKey: LocalBroadcast.Key_ImagesListUpdated,
        shouldReload: (data) => data == searchText,
        childBuilder: (context) => ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: items.length,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            return ImageCell(
              data: items[index],
            );
          },
        ),
      ),
//      body: ObserverWidget(
//        eventName: LocalBroadcast.Key_ImagesListUpdated,
//        builder: (context, data, error) => ListView.builder(
//          padding: EdgeInsets.all(8.0),
//          itemCount: items.length,
//          controller: _scrollController,
//          itemBuilder: (BuildContext context, int index) {
//            return ImageCell(
//              data: items[index],
//            );
//          },
//        ),
//      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _fetchMoreData() {
    dataManager.fetchImages(queryText: searchText);
  }
}
