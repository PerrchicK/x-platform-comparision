import 'package:flutter/material.dart';
import 'package:ironbreeze/src/bl/strings.dart';
import 'package:ironbreeze/src/ui/animations_screen.dart';
import 'package:ironbreeze/src/ui/comparison_screen.dart';
import 'package:ironbreeze/src/ui/flare_example_penguin.dart';
import 'package:ironbreeze/src/ui/image_viewer.dart';
import 'package:ironbreeze/src/ui/images_screen.dart';
import 'package:ironbreeze/src/util/native_bridge.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';
import 'package:ironbreeze/src/util/utils.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VoidCallback get _onFabPressed => () {
//        LocalBroadcast.notifyEvent(LocalBroadcast.Key_ThrowConfetti);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlareAnimationDemoPenguin(),
//            builder: (context) => FlareAnimationDemoTeddy(),
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    // Tip: In release mode, the UI is presented "too fast" and then the size values are zero: https://github.com/flutter/flutter/issues/25827
    if (!Utils.updateScreenSize(MediaQuery.of(context).size)) {
      // Show an empty screen, either way the app's meanwhile presenting a splash screen.
      Future.delayed(Duration(milliseconds: 180), () {
        refreshUi();
      });
      return Container(color: Colors.white);
    }

    Utils.updateSafeAreaPadding(MediaQuery.of(context).viewInsets);

    // When you all set - let the native know that the splash can be removed
    Future.delayed(Duration(seconds: 1), () {
      NativeBridge.onFlutterPresented();
    });

    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: UiFactory.coinFlipAnimation(
                    child: Container(
                      width: 30,
                      height: 30,
                      child: GestureDetector(
                        onTap: () {
                          UiFactory.showInputDialog(
                              alertTitle: Localized.string("How many coins?"),
                              bodyText: Localized.string("Select coins count"),
                              hint: Localized.string("1000?"),
                              context: context,
                              callback: (data) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimationsScreen(
                                      count: int.tryParse(data),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: UiFactory.generateLogo(tintColorHexa: "fff"),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff3083ff),
                      ),
                    ),
                    duration: Duration(milliseconds: 500),
                  ),
                ),
                RoundButton(
                  size: 50,
                  title: Localized.string("Test"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparisonScreen(),
                      ),
                    );
                  },
                ),
                RoundButton(
                  size: 80,
                  title: Localized.string('Scan'),
                  onPressed: () async {
                    var result = await Utils.scan();
                    if (result == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewer(imageUrl: result),
                      ),
                    );

//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => ScannerScreen(),
//                      ),
//                    );
                  },
                ),
                Hero(
                  tag: Constants.ImagesHeroTag,
                  child: RoundButton(
                    title: Strings.imagesListScreen,
                    size: 150,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagesListScreen(),
                        ),
                      );
                    },
                  ),
                ),
                RoundButton(
                  size: 200,
                  title: Localized.string("Let's Compare"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparisonScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: Localized.string('Animations'),
        child: Text('🎉'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void refreshUi({VoidCallback fn}) {
    if (!mounted) return;

    fn ??= () {};

    setState(fn);
  }
}

class RoundButton extends StatelessWidget {
  final String title;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const RoundButton(
      {Key key,
      this.color = AppColors.main,
      this.onPressed,
      this.title,
      this.size = 100.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: CircleBorder(),
      color: color,
      onPressed: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            title,
            style: UiFactory.styleForButton(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
