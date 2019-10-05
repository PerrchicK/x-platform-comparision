import 'package:flutter/widgets.dart';
import 'package:ironbreeze/src/communication/local_broadcast.dart';
import 'package:ironbreeze/src/util/app_logger.dart';

class ObservingWidget extends StatefulWidget {
  final Iterable<String> observedKeys;
  final bool Function(dynamic) _shouldReload;
  final Widget Function(BuildContext) childBuilder;
  final void Function() _onDisposed;

  ObservingWidget(
      {String observedKey,
      this.childBuilder,
      Iterable<String> observedKeys,
      bool Function(dynamic) shouldReload,
      void Function() onDisposed})
      : this._shouldReload = shouldReload ?? ((_) => true),
        this._onDisposed = onDisposed ?? (() => {}),
        this.observedKeys = observedKeys ?? [observedKey];

  @override
  State<StatefulWidget> createState() {
    return _ObservingWidgetState();
  }

  void onDisposed() {
    _onDisposed();
  }
}

class _ObservingWidgetState extends State<ObservingWidget> {
  AppObserver _observer;

  @override
  void initState() {
    _observer?.remove();

    if (widget.observedKeys != null) {
      _observer = LocalBroadcast.observe(
          eventName: widget.observedKeys.first,
          onEvent: (name, data) {
            refresh(data);
          });
    } else {
      AppLogger.error("ObservingWidget doesn't have observed key");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context);
  }

  @override
  void dispose() {
    _observer?.remove();
    widget.onDisposed();

    super.dispose();
  }

  void refresh(data) {
    if (!mounted) {
      _observer?.remove();
      return;
    }

    if (widget._shouldReload(data)) {
      setState(() {});
    }
  }
}
