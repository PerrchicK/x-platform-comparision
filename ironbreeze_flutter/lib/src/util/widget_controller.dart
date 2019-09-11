import 'package:flutter/widgets.dart';

class ControlledWidget<T> extends StatefulWidget {
  final Widget Function(T) childBuilder;
  final T defaultValue;
  final ControlledWidgetController controller;

  const ControlledWidget(
      {Key key, this.childBuilder, this.controller, this.defaultValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ControlledWidgetState(this);
  }
}

class _ControlledWidgetState<T> extends State<ControlledWidget>
    implements ControllableState<T> {
  T _value;

  Widget Function(int) childBuilder;
  T get value => _value;

  _ControlledWidgetState(ControlledWidget holden) {
    holden.controller.listeningState = this;
    childBuilder = holden.childBuilder ??
        (int) {
          return Container();
        };
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(_value);
  }

  @override
  void refreshUi(T newValue) {
    if (!mounted) return;

    setState(() {
      _value = newValue;
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();

    super.dispose();
  }
}

abstract class ControllableState<T> {
  void refreshUi(T value);
}

class ControlledWidgetController<T> {
  ControllableState listeningState;

  void onChanged(T newValue) {
    _refreshUi(newValue);
  }

  void _refreshUi(T newValue) {
    listeningState?.refreshUi(newValue);
  }

  void dispose() {
    listeningState = null;
  }
}
