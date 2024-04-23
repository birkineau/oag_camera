import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';

class CameraOrientationRotator extends StatefulWidget {
  const CameraOrientationRotator({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<CameraOrientationRotator> createState() =>
      _CameraOrientationRotatorState();
}

class _CameraOrientationRotatorState extends State<CameraOrientationRotator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _curvedAnimation;

  late Tween<double> _rotationTween;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
    );

    final orientationAngle = _getAngleForOrientation(
      context.read<CameraStateBloc>().state.orientation,
    );

    _rotationTween = Tween(begin: orientationAngle, end: orientationAngle);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraStateBloc, CameraState>(
      listenWhen: _orientationChanged,
      listener: _animateToNewOrientation,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.rotate(
          angle: _rotationTween.evaluate(_curvedAnimation),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }

  bool _orientationChanged(CameraState previous, CameraState current) {
    return previous.orientation != current.orientation;
  }

  void _animateToNewOrientation(BuildContext context, CameraState state) {
    if (!mounted) {
      return;
    }

    _rotationTween = Tween(
      begin: _rotationTween.end,
      end: _getAngleForOrientation(state.orientation),
    );

    _animationController.forward(from: .0);
  }
}

double _getAngleForOrientation(DeviceOrientation orientation) {
  return switch (orientation) {
    DeviceOrientation.portraitUp || DeviceOrientation.portraitDown => .0,
    DeviceOrientation.landscapeLeft => math.pi / 2.0,
    DeviceOrientation.landscapeRight => -math.pi / 2.0,
  };
}
