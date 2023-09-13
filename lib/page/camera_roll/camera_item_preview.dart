import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_state_bloc.dart';
import '../../model/camera_item.dart';
import '../../model/camera_state.dart';
import 'camera_item_widget.dart';

/// Displays a preview of the [CameraItem] that automatically adjusts its
/// orientation and scale to fit to the screen.
///
/// Uses `MediaQuery.of(context).size.aspectRatio` to fit the item to the
/// screen.
class CameraItemPreview extends StatefulWidget {
  const CameraItemPreview({
    super.key,
    this.scaleToFit = true,
    this.filterQuality = FilterQuality.medium,
    required this.item,
  });

  final bool scaleToFit;
  final FilterQuality filterQuality;
  final CameraItem item;

  @override
  State<CameraItemPreview> createState() => _CameraItemPreviewState();
}

class _CameraItemPreviewState extends State<CameraItemPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _curvedAnimation;
  late final Tween<double> _scaleTween;
  late final Tween<double> _rotationTween;

  late double _rotation;

  late void Function(BuildContext, CameraState) _listener;
  late Widget Function(BuildContext, Widget?) _builder;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastLinearToSlowEaseIn,
    );

    final orientation = context.read<CameraStateBloc>().state.orientation;

    _rotation = angleForItemWithOrientation(widget.item, orientation, .0);
    _rotationTween = Tween(begin: _rotation, end: _rotation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.scaleToFit) {
      final orientation = context.read<CameraStateBloc>().state.orientation;

      final scale = scaleForItemWithOrientation(
        context,
        widget.item,
        orientation,
      );

      _scaleTween = Tween(begin: scale, end: scale);

      _listener = (context, state) {
        final scale = scaleForItemWithOrientation(
          context,
          widget.item,
          state.orientation,
        );

        _scaleTween.begin = _scaleTween.end;
        _scaleTween.end = scale;

        _rotation = angleForItemWithOrientation(
          widget.item,
          state.orientation,
          _rotation,
        );

        _rotationTween.begin = _rotationTween.end;
        _rotationTween.end = _rotation;

        _animationController.forward(from: .0);
      };

      _builder = (context, child) => Transform.scale(
            scale: _scaleTween.evaluate(_curvedAnimation),
            child: Transform.rotate(
              angle: _rotationTween.evaluate(_curvedAnimation),
              child: child,
            ),
          );
    } else {
      _listener = (context, state) {
        _rotation = angleForItemWithOrientation(
          widget.item,
          state.orientation,
          _rotation,
        );

        _rotationTween.begin = _rotationTween.end;
        _rotationTween.end = _rotation;

        _animationController.forward(from: .0);
      };

      _builder = (context, child) => Transform.rotate(
            angle: _rotationTween.evaluate(_curvedAnimation),
            child: child,
          );
    }
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
      listener: _listener,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: _builder,
        child: CameraItemWidget(item: widget.item),
      ),
    );
  }
}

double scaleForItemWithOrientation(
  BuildContext context,
  CameraItem item,
  DeviceOrientation orientation,
) {
  if (orientation == DeviceOrientation.portraitUp ||
      orientation == DeviceOrientation.portraitDown) {
    return switch (item.orientation) {
      DeviceOrientation.portraitUp || DeviceOrientation.portraitDown => 1.0,
      _ => MediaQuery.of(context).size.aspectRatio,
    };
  } else {
    return switch (item.orientation) {
      DeviceOrientation.landscapeLeft ||
      DeviceOrientation.landscapeRight =>
        1.0,
      _ => MediaQuery.of(context).size.aspectRatio,
    };
  }
}

double rotationForItemWithOrientation(
  CameraItem item,
  DeviceOrientation deviceOrientation,
) {
  const halfPi = math.pi / 2.0;

  if (item.orientation == DeviceOrientation.portraitUp) {
    return switch (deviceOrientation) {
      DeviceOrientation.portraitUp => .0,
      DeviceOrientation.portraitDown => math.pi,
      DeviceOrientation.landscapeLeft => -math.pi / 2.0,
      DeviceOrientation.landscapeRight => math.pi / 2.0,
    };
  } else if (item.orientation == DeviceOrientation.portraitDown) {
    return switch (deviceOrientation) {
      DeviceOrientation.portraitUp => math.pi,
      DeviceOrientation.portraitDown => .0,
      DeviceOrientation.landscapeLeft => math.pi / 2.0,
      DeviceOrientation.landscapeRight => -math.pi / 2.0,
    };
  } else if (item.orientation == DeviceOrientation.landscapeLeft) {
    final isFront = item.lensDirection == CameraLensDirection.front;

    return switch (deviceOrientation) {
      DeviceOrientation.portraitUp => isFront ? -halfPi : halfPi,
      DeviceOrientation.portraitDown => isFront ? halfPi : -halfPi,
      DeviceOrientation.landscapeLeft => isFront ? math.pi : .0,
      DeviceOrientation.landscapeRight => isFront ? .0 : math.pi,
    };
  }
  // DeviceOrientation.landscapeRight
  else {
    final isFront = item.lensDirection == CameraLensDirection.front;

    return switch (deviceOrientation) {
      DeviceOrientation.portraitUp => isFront ? halfPi : -halfPi,
      DeviceOrientation.portraitDown => isFront ? -halfPi : halfPi,
      DeviceOrientation.landscapeLeft => isFront ? .0 : math.pi,
      DeviceOrientation.landscapeRight => isFront ? math.pi : .0,
    };
  }
}

double angleForItemWithOrientation(
  CameraItem item,
  DeviceOrientation cameraOrientation,
  double lastRotation,
) {
  const twoPi = 2.0 * math.pi;

  var intendedRotation = rotationForItemWithOrientation(
    item,
    cameraOrientation,
  );

  final rotationDelta = (intendedRotation - lastRotation).remainder(twoPi);

  // If the rotation difference is more than 180 degrees (π radians),
  // we adjust it to take the shorter rotation path.
  if (rotationDelta.abs() > math.pi) {
    intendedRotation += rotationDelta > .0 ? -twoPi : twoPi;
  }

  return intendedRotation;
}

bool _orientationChanged(CameraState previous, CameraState current) {
  return previous.orientation != current.orientation;
}
