import 'package:flutter/material.dart';
import 'package:oag_camera/oag_camera.dart';

/// Generic styled button for camera controls.
class CameraControlButton extends StatelessWidget {
  const CameraControlButton({
    super.key,
    this.onPressed,
    this.backgroundColor = Colors.black54,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: onPressed,
          splashFactory: InkSparkle.splashFactory,
          child: CameraOrientationRotator(child: child),
        ),
      ),
    );
  }
}
