import 'package:flutter/animation.dart';

class CurvedRectTween extends RectTween {
  CurvedRectTween({required this.curve, super.begin, super.end});

  final Curve curve;

  @override
  Rect? lerp(double t) => super.lerp(curve.transform(t));
}
