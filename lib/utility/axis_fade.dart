import 'package:flutter/material.dart';

/// Fades the [child] along 4 points ([stops]) of the [axis].
///
/// This is used to fade the edges of the [child].
class AxisFade extends StatelessWidget {
  const AxisFade({
    super.key,
    required this.axis,
    this.stops = const [.0, .25, .75, 1.0],
    required this.child,
  });

  final Axis axis;
  final List<double> stops;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final alignment = _axisToAlignmentPair(axis);

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: alignment.begin,
        end: alignment.end,
        colors: const [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: stops,
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

({Alignment begin, Alignment end}) _axisToAlignmentPair(Axis axis) {
  return switch (axis) {
    Axis.horizontal => (
        begin: Alignment.centerLeft,
        end: Alignment.centerRight
      ),
    Axis.vertical => (
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
  };
}
