import 'package:flutter/material.dart';
import 'package:ironbreeze/src/bl/strings.dart';
import 'package:ironbreeze/src/dl/data_manager.dart';
import 'package:ironbreeze/src/ui/home_page.dart';
import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:ironbreeze/src/util/utils.dart';

Future main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details?.stack == null) return;
    AppLogger.log(details.exception, withStackTrace: false);
    AppLogger.log(details.stack, withStackTrace: false);
    Utils.debugToast(
        "Crash details: ${details.exception}\n\nhere: ${details.stack}");
  };

  await DataManager.shared.init();

  Utils.init();

  runApp(TheApp());
}

class TheApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: HomePage(title: Strings.homePageTitle),
    );
  }
}
