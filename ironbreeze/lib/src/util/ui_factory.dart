import 'dart:math';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ironbreeze/src/util/utils.dart';

class UiFactory {
  static Container imageContainer(
      {@required String imageFileName,
      @required double width,
      @required double height,
      AlignmentGeometry alignment = Alignment.center}) {
    imageFileName += imageFileName.endsWith(".png") ||
            imageFileName.endsWith(".jpg") ||
            imageFileName.endsWith(".gif")
        ? ""
        : ".png";

    Container container;
    // fit: BoxFit.cover / BoxFit.contain
    DecorationImage image;
    String imageRelativePath = "lib/resources/img/$imageFileName";

    if (Utils.isInDebugMode) {
      rootBundle.load(imageRelativePath).then((value) {
        return Image.memory(value.buffer.asUint8List());
      }).catchError((error) {
        Utils.debugToast(error.toString());
      });
    }

    image = DecorationImage(
        image: AssetImage(imageRelativePath),
        fit: BoxFit.contain,
        alignment: alignment ?? Alignment.center);

    container = Container(
        width: width, height: height, decoration: BoxDecoration(image: image));
    return container;
  }

  static void showInputDialog(
      {BuildContext context,
      int lines = 1,
      String alertTitle,
      String bodyText,
      bool barrierDismissible = false,
      String hint,
      String actionTitle,
      void Function(String) callback,
      VoidCallback onCancel}) {
    assert(callback != null, "Callback cannot be null!");

    actionTitle ??= Localized.string("Submit");
    TextEditingController textEditingController = TextEditingController();
    TextField textField = TextField(
      controller: textEditingController,
      maxLines: lines,
      autofocus: true,
      decoration: InputDecoration(border: InputBorder.none, hintText: hint),
    );

    alert(
      context: context,
      title: alertTitle,
      actionTitle: actionTitle,
      bodyWidget: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(bodyText),
            textField,
          ],
        ),
      ),
      actionCallback: () {
        callback(textEditingController.text);
      },
      barrierDismissible: barrierDismissible,
    );
  }

  static void alert<T>(
      {@required BuildContext context,
      String title,
      String body,
      Widget bodyWidget,
      String actionTitle = "OK",
      VoidCallback actionCallback,
      bool barrierDismissible = true}) {
    EdgeInsets contentPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0);

    var onPressed = () {
      Navigator.of(context).pop();
      if (actionCallback != null) {
        actionCallback();
      }
    };

    if (bodyWidget == null) {
      bodyWidget = SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(body),
          ],
        ),
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // false ==> user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          contentPadding: contentPadding,
          content: bodyWidget,
          actions: <Widget>[
            FlatButton(
              child: Text(actionTitle),
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }

  static TextStyle styleForButton() {
    return TextStyle(fontSize: 20, fontFamily: 'roboto', color: Colors.black);
  }

  static TextStyle styleForImageCell() {
    return TextStyle(fontSize: 20, fontFamily: 'roboto');
  }

  static TextStyle styleForPreferenceCell() {
    return TextStyle(fontSize: 20);
  }

  static styleForScreenTitle({double fontSize = 14.0}) {
    return TextStyle(color: Colors.black, fontSize: fontSize);
  }

  static Widget generateLogo({String tintColorHexa = "#3083ff"}) {
    if (tintColorHexa == null) return Container();
    if (!tintColorHexa.startsWith("#")) {
      tintColorHexa = "#$tintColorHexa";
    }

    final String rawSvgStringOfIronSourceLogo =
        '<svg xmlns="http://www.w3.org/2000/svg" width="60" height="60"><path fill="$tintColorHexa" fill-rule="evenodd" d="M35.4 45.4c-7 0-10.2-3.7-10.2-8.4v-1.4h7.7v.6c0 1.5.8 2.6 2.3 2.6 1.4 0 2.1-.7 2.1-1.7 0-3.1-11.9-2.6-11.9-11.3 0-4.6 3-8.7 10.4-8.7 6.6 0 9.8 3.8 9.8 8.4V27H38v-.9c0-1.2-.7-2.5-2.2-2.5-1.1 0-1.8.7-1.8 1.7 0 3.4 11.9 2.6 11.9 11.2 0 4.7-3.1 8.9-10.4 8.9zM23.8 22.8h-7.6v-6h7.6v6zm0 6.8c0 2.5-.8 4-2.7 4.5 2 .7 2.7 2.2 2.7 5.2v4.4l-7.7-.1v-5.8c0-1.1-1.2-1.2-2.3-1.6v-4.1c1-.4 2.3-.7 2.3-1.6v-6.1h7.7v5.2zM30 0a30 30 0 1 0 0 60 30 30 0 0 0 0-60z"/></svg>';

    return SvgPicture.string(
      rawSvgStringOfIronSourceLogo,
      alignment: Alignment.center,
      fit: BoxFit.contain,
    );
  }

  Widget confusedDogLookAnimation() {
    return Animator(
      curve: Curves.bounceInOut,
      tween: Tween(begin: 0.0, end: 1.0),
      cycles: 0,
      duration: Duration(seconds: 1),
      builder: (animation) => Transform.rotate(
        child: UiFactory.generateLogo(),
        angle: animation.value,
      ),
    );
  }

  static Widget coinFlipsAnimation({Widget child}) {
    return Animator(
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: 1.0),
      cycles: 0,
      duration: Duration(seconds: 5),
      builder: (animation) => Transform(
        transform: Matrix4.rotationY(Utils.radiansToDegrees(animation.value)),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  static Widget coinFlipAnimation(
      {@required Widget child,
      Duration duration = const Duration(seconds: 2)}) {
    return Animator(
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: pi),
      cycles: 0,
      duration: duration,
      builder: (animation) => Transform(
        transform: Matrix4.rotationY(animation.value),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

//  static Widget coinFlipAnimation(
//      {@required Widget child,
//        Duration duration = const Duration(seconds: 2)}) {
//    return Animator(
//      curve: Curves.easeInOut,
//      tween: Tween(begin: 0.0, end: pi),
//      cycles: 0,
//      duration: duration,
//      builder: (animation) => Transform(
//        transform: Matrix4.rotationY(animation.value),
//        alignment: Alignment.center,
//        child: child,
//      ),
//    );
//  }
}

class Scaled extends StatelessWidget {
  final double scale;
  final Widget child;
  final AlignmentGeometry alignment;

  const Scaled({Key key, this.scale, this.child, this.alignment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double currentScale = scale ?? 1;

    return Transform.scale(
        scale: currentScale,
        child: child,
        alignment: alignment ?? Alignment.center);
  }
}

class Rotated extends StatelessWidget {
  final int degrees;
  final Widget child;

  const Rotated({Key key, this.degrees, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: Utils.degreesToRadians(degrees.toDouble()),
      child: child,
    );
  }
}

class AppColors {
  static const Color main = Colors.lightBlue;
  static const Color white = Colors.white;
  static Color get transparentShade => Colors.black.withOpacity(0.5);
}
