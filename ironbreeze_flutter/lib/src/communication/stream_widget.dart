import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:ironbreeze/src/communication/local_broadcast.dart';
import 'package:ironbreeze/src/util/app_logger.dart';
import 'package:rxdart/rxdart.dart';

class ObserverWidget<T> extends StatefulWidget {
  final String eventName;
  final Iterable<String> _eventNames;
  final bool Function(T) shouldReload;
  final void Function(T) onNewEvent;
  final void Function() onDisposed;
  final VoidCallback onInit;
  final Widget Function(
      BuildContext /* context */, T /* data */, Object /* error */) builder;
  final List<_ObservingWidgetState<T>> _stateHolder = [];

  ObserverWidget({
    @required this.builder,
    Key key,
    this.eventName,
    Iterable<String> eventNames,
    void Function() onDisposed,
    void Function(T) onNewEvent,
    VoidCallback onInit,
    bool Function(T) shouldReload,
  })  : this.shouldReload = shouldReload ?? ((_) => true),
        this.onDisposed = onDisposed ?? (() => {}),
        this._eventNames = eventNames,
        this.onInit = onInit ?? (() => {}),
        this.onNewEvent = onNewEvent ?? ((_) => {}),
        super(key: key);

  _ObservingWidgetState<T> get _state =>
      (_stateHolder?.isEmpty ?? true) ? null : _stateHolder.last;

  Iterable<String> get eventNames {
    if (_state?._eventNames != null) return _state._eventNames;
    Iterable<String> eventNames = (_eventNames ?? []);
    if (eventNames.isEmpty) {
      eventNames = [eventName];
    }

    _state?._eventNames = eventNames.toSet();

    return _state?._eventNames ?? eventNames.toSet();
  }

  @override
  State<StatefulWidget> createState() {
    return _ObservingWidgetState<T>();
  }

  Widget build(BuildContext context) {
    return builder(context, null, null);
  }

  void refreshUi() {
    _state?.refreshUi();
  }
}

class _ObservingWidgetState<CLASS> extends State<ObserverWidget<CLASS>> {
  PublishSubject<CLASS> _stream;
  AppObserver _observer;

  Set<String> _eventNames;

  @override
  void initState() {
    _stream = PublishSubject<CLASS>();
    _stream.listen((data) {
      AppLogger.log("Stream value has sinked: $data");
      widget.onNewEvent(data);
    });

    widget.onInit();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget._stateHolder.clear();
    widget._stateHolder.add(this);

    _observer?.remove();

    _observer = LocalBroadcast.observe(
        events: widget.eventNames,
        onEvent: (name, data) {
          if (!(widget.eventNames.contains(name))) return;
          if (!(data is CLASS)) return;
          //onNewEvent(data);
          if (!(widget.shouldReload(data))) return;

          _stream?.sink?.add(data);
        });

    if (widget.builder == null) {
      return widget.build(context);
    } else {
      return StreamBuilder<CLASS>(
        stream: _stream,
        builder: (context, AsyncSnapshot<CLASS> snapshot) {
          if (snapshot.hasData) {
            return widget.builder(
                context, snapshot.data, snapshot.error /* probably null */);
          } else if (snapshot.hasError) {
            return widget.builder(
                context, snapshot.data /* probably null */, snapshot.error);
          } else {
            return widget.builder(context, snapshot.data /* probably null */,
                snapshot.error /* probably null */);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _stream?.close();
    _stream = null;
    _observer?.remove();
    _observer = null;
    widget.onDisposed();
    widget._stateHolder.clear();

    super.dispose();
  }

  void refreshUi() {
    if (!mounted) return;
    setState(() {});
  }
}
