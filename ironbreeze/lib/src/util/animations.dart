import 'package:animator/animator.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';

class AnimatedScale extends StatefulWidget {
  final double scale;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedScale(
      {Key key,
      this.scale,
      this.duration,
      this.child,
      this.curve = Curves.linear})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedScaleState();
  }
}

class _AnimatedScaleState extends State<AnimatedScale> {
  double _currentScale;
  @override
  Widget build(BuildContext context) {
    double currentScale = _currentScale ?? 0.0;
    _currentScale = widget.scale;
    return Animator(
      tween: Tween(begin: currentScale, end: widget.scale),
      duration: widget.duration,
      curve: widget.curve,
      builder: (animation) {
        return Scaled(scale: animation.value, child: widget.child);
      },
    );
  }
}
