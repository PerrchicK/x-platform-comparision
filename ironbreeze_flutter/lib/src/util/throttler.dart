import 'dart:async';

import 'package:ironbreeze/src/util/app_logger.dart';

class Throttler {
  Duration duration;
  void Function() _callbackToExecute;
  int _counter;
  bool _isCanceled;

  static Map<String, Throttler> _throttlers = {};

  Throttler({this.duration}) {
    if (duration == null) {
      duration = Duration(seconds: 2);
    }
    _counter = 0;
    _isCanceled = false;
  }

  Future throttle(void Function() callback) async {
    var currentCounter = ++_counter;
    _callbackToExecute = callback;
    await Future.delayed(duration);
    //sleep(duration);
    if (_isCanceled) return;
    if (currentCounter != _counter) return;
    if (_callbackToExecute != null) {
      _callbackToExecute();
    } else {
      AppLogger.error("Somehow '_callbackToExecute' is null!!!");
    }
  }

  void cancel() {
    _isCanceled = true;
  }

  static void dismiss(throttlingKey) {
    _throttlers[throttlingKey]?.cancel();
    _throttlers.remove(throttlingKey);
  }

  static void throttleWith(
      String throttlingKey, Duration duration, void Function() callback) {
    _throttlers[throttlingKey]?.cancel();
    _throttlers[throttlingKey] = Throttler(duration: duration);
    _throttlers[throttlingKey]?.throttle(() {
      _throttlers.remove(throttlingKey);
      if (callback == null) return;
      callback();
    });
  }
}
