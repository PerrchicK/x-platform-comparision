import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:ironbreeze/src/util/widget_controller.dart';

class CircularSlider extends StatelessWidget {
  final void Function(int) _onChanged;
  final int _defaultValue;
  final double width;
  final double height;

  CircularSlider(
      {Function(int) onChanged,
      int defaultValue,
      this.width = 100,
      this.height = 100})
      : _onChanged = onChanged ?? (int),
        _defaultValue = defaultValue;

  @override
  Widget build(BuildContext context) {
    ControlledWidgetController<int> controller =
        ControlledWidgetController<int>();

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ControlledWidget(
          childBuilder: (value) {
            return Text('${value == null ? "${_defaultValue ?? 0}" : value}');
          },
          defaultValue: _defaultValue,
          controller: controller,
        ),
        SingleCircularSlider(
          100,
          _defaultValue ?? 0,
          height: height,
          width: width,
          onSelectionChange: (__, newValue, _) {
            // newStartValue, newEndValue, laps
            //Utils.toast(newValue.toString());
            controller?.onChanged(newValue);
            _onChanged(newValue);
          },
          baseColor: Colors.greenAccent,
        )
      ],
    );
  }
}
