import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ironbreeze/src/util/animations.dart';
import 'package:ironbreeze/src/util/app_observer.dart';
import 'package:ironbreeze/src/util/utils.dart';

/// This is an experimental attempt to make a confetti widget that wraps other widgets.
/// Due to a lack of time I stopped this feature's development.
class Confettible extends StatefulWidget {
  final Widget Function(BuildContext) childBuilder;

  static const Duration ConfettiAnimationDuration =
      const Duration(milliseconds: 3000);

  const Confettible({Key key, this.childBuilder}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConfettibleState();
  }
}

class _ConfettibleState extends State<Confettible> {
  AppObserver _observer;
  List<Widget> _children;

  @override
  void initState() {
    _reset();

    _children = [];
    _observer = LocalBroadcast.observe(
        eventName: LocalBroadcast.Key_ThrowConfetti,
        onEvent: (data, name) {
          _refreshUi();
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[widget.childBuilder(context)];
    children.addAll(_children);

    return Stack(
      children: children,
    );
  }

  Widget _generateParticle({Duration duration}) {
    return ConfettiParticle(
      duration: duration,
    );
  }

  @override
  void dispose() {
    _observer?.remove();

    super.dispose();
  }

  void _refreshUi() {
    if (!mounted) return;

//    if (_top == 0) {
//      setState(() {
//        _reset();
//      });
//    } else {
    var particle =
        _generateParticle(duration: Confettible.ConfettiAnimationDuration);

    Future.delayed(Confettible.ConfettiAnimationDuration, () {
      _children.remove(particle);
    });

    setState(() {
      _children.add(particle);
    });
//    }
  }

  void _reset() {}
}

class ConfettiParticle extends StatefulWidget {
  final Duration duration;
  const ConfettiParticle({this.duration, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ConfettiParticleState();
  }
}

class ConfettiParticleState extends State<ConfettiParticle> {
  double _top;
  double _opacity;
  double _right;
  double _scale;
  Alignment _alignment;

  @override
  void initState() {
    _reset();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_top == null) {
      // if (_top == null || _top != 0) {
      _top = 0;
      Future.delayed(Duration(milliseconds: 500), () {
        //setState(() {});
        _refreshUi();
      });
    }

    return AnimatedPositioned(
      child: SizedBox(
        width: Utils.screenSize().width,
        height: Utils.screenSize().height,
        child: AnimatedOpacity(
          duration: Duration(
              milliseconds: (widget.duration.inMilliseconds / 3).floor()),
          opacity: _opacity,
          child: AnimatedScale(
            duration: Duration(milliseconds: widget.duration.inMilliseconds),
            scale: _scale,
//          child: Transform.scale(
            child: AnimatedAlign(
              alignment: _alignment,
              duration: Duration(milliseconds: widget.duration.inMilliseconds),
              child: AnimatedOpacity(
                child: Text(
                  '🤗',
                  style: TextStyle(decoration: TextDecoration.none),
                ),
                duration: Duration(
                    milliseconds: (widget.duration.inMilliseconds).floor()),
                opacity: 1,
              ),
              curve: Curves.easeIn,
            ),
//          ),
            curve: Curves.easeIn,
          ),
        ),
      ),
      duration: Duration(milliseconds: widget.duration.inMilliseconds),
      top: _top,
      right: 10,
    );
  }

  void _refreshUi() {
    if (!mounted) return;

//    if (_top == 0) {
//      setState(() {
//        _reset();
//      });
//    } else {
    setState(() {
      _top = 0;
      _scale = 1.0;
      _opacity = 1;
      _right = 100;
      _alignment = Alignment.topRight;
    });
    Future.delayed(widget.duration, () {
      if (_opacity == 0) return;
      setState(() {
        _opacity = 0;
      });
    });
//    }
  }

  void _reset() {
    //_top = Utils.screenSize().height;
    _right = 10;
    _opacity = 0;
    _scale = 0.1;
    _alignment = Alignment.bottomCenter;
  }
}
