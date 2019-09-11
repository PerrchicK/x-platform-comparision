import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ironbreeze/src/dl/data_manager.dart';
import 'package:ironbreeze/src/ui/simple_circular_number_picker.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';
import 'package:ironbreeze/src/util/utils.dart';
import 'package:ironbreeze/src/util/widget_controller.dart';

class ComparisonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ControlledWidgetController controller = ControlledWidgetController();

    List<Widget> rows = [
      ControlledWidget(
        controller: controller,
        childBuilder: (value) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Opacity(
                opacity: _evaluate(Framework.cordova),
                child: RawMaterialButton(
                  onPressed: () {
                    // Present Cordova's values
                  },
                  fillColor: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      Text("Cordova"),
                      Text("${_evaluate(Framework.cordova).toStringAsFixed(2)}")
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: _evaluate(Framework.react),
                child: RawMaterialButton(
                  onPressed: () {
                    // Present React Native's values
                  },
                  fillColor: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      Text("React Native"),
                      Text("${_evaluate(Framework.react).toStringAsFixed(2)}")
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: _evaluate(Framework.flutter),
                child: RawMaterialButton(
                  onPressed: () {
                    // Present Flutter's values
                  },
                  fillColor: Colors.blue,
                  child: Column(
                    children: <Widget>[
                      Text("Flutter"),
                      Text("${_evaluate(Framework.flutter).toStringAsFixed(2)}")
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ];

    double sidesPadding = 20;
    double circularSliderSize = 80;
    DataManager.shared.userPreferences.forEach(
      (preference, value) {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sidesPadding),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: Utils.screenSize().width -
                      (circularSliderSize + sidesPadding * 2),
                  child: Text(
                    preference,
                    style: UiFactory.styleForPreferenceCell(),
                  ),
                ),
                CircularSlider(
                  width: circularSliderSize,
                  height: circularSliderSize,
                  defaultValue: (value * 10.0).toInt(),
                  onChanged: (selectedValue) {
                    DataManager.shared.userPreferences[preference] =
                        selectedValue.toDouble() / 10;
                    controller.onChanged(selectedValue);
                  },
                )
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: rows,
            ),
          ),
        ),
        appBar: AppBar(
          title: Text(Localized.string("Comparison")),
        ));
  }

  double _evaluate(Framework framework) {
    var importanceValues = DataManager.shared.importance[framework.index];
    List<double> values = [];
    DataManager.shared.userPreferences.forEach((preference, value) {
      values.add(importanceValues[preference] * value / 10.0);
    });

    double sum = values.reduce((a, b) {
      return a + b;
    });

    return sum;
  }
}
