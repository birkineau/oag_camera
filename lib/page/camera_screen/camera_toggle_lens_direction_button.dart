import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_overlay_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';
import 'camera_orientation_rotator.dart';

typedef CameraOrientationSelector
    = BlocSelector<CameraStateBloc, CameraState, DeviceOrientation>;

class CameraToggleLensDirectionButton extends StatefulWidget {
  const CameraToggleLensDirectionButton({super.key});

  @override
  State<CameraToggleLensDirectionButton> createState() =>
      _CameraToggleLensDirectionButtonState();
}

class _CameraToggleLensDirectionButtonState
    extends State<CameraToggleLensDirectionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CameraStateBloc, CameraState, CameraStatus>(
      selector: (state) => state.status,
      builder: (context, status) => GestureDetector(
        onTap: status == CameraStatus.ready ? _toggleLensDirection : null,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: IgnorePointer(
            ignoring: status != CameraStatus.ready,
            child: CameraOrientationSelector(
              selector: (state) => state.orientation,
              builder: (context, orientation) => AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => Transform(
                  transform: _getTransformForOrientation(orientation),
                  alignment: Alignment.center,
                  child: child,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => CameraOrientationRotator(
                    child: Icon(
                      Icons.sync,
                      size: math.max(24.0, constraints.maxWidth * .5),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleLensDirection() async {
    final cameraControllerBloc = context.read<CameraStateBloc>();
    final controller = cameraControllerBloc.state.controller;

    if (controller == null) {
      return;
    }

    HapticFeedback.lightImpact();

    context.read<CameraBlurBloc>().add(const BlurScreenshotEvent());

    final isBack =
        controller.description.lensDirection == CameraLensDirection.back;

    final SetCameraLensDirectionEvent setLensDirection;

    if (isBack) {
      _animationController.forward();
      setLensDirection = const SetCameraLensDirectionEvent(
        lensDirection: CameraLensDirection.front,
      );
    } else {
      _animationController.reverse();
      setLensDirection = const SetCameraLensDirectionEvent(
        lensDirection: CameraLensDirection.back,
      );
    }

    cameraControllerBloc.add(setLensDirection);
  }

  Matrix4 _getTransformForOrientation(DeviceOrientation orientation) {
    final value = _animationController.value * math.pi;

    return switch (orientation) {
      DeviceOrientation.portraitUp ||
      DeviceOrientation.portraitDown =>
        Matrix4.identity()..rotateY(value),
      _ => Matrix4.identity()..rotateX(value)
    };
  }
}
