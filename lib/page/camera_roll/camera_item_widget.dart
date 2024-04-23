import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oag_camera/oag_camera.dart';

/// Displays the image from the [CameraItem].
///
/// If the [CameraItem] is from the front camera, then the image is flipped
/// horizontally or vertically depending on the [DeviceOrientation] of the
/// camera item in order to display the image without mirroring.
class CameraItemWidget extends StatelessWidget {
  const CameraItemWidget({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
    required this.item,
  });

  final double? width;
  final double? height;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final CameraItem item;

  @override
  Widget build(BuildContext context) {
    final isFront = item.lensDirection == CameraLensDirection.front;

    final flipX = isFront &&
        (item.orientation == DeviceOrientation.portraitUp ||
            item.orientation == DeviceOrientation.portraitDown);

    final flipY = isFront &&
        (item.orientation == DeviceOrientation.landscapeLeft ||
            item.orientation == DeviceOrientation.landscapeRight);

    return Transform.flip(
      flipX: flipX,
      flipY: flipY,
      child: Image.memory(
        item.bytes,
        width: width,
        height: height,
        frameBuilder: _frameBuilder,
        fit: fit,
        filterQuality: filterQuality,
      ),
    );
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;

    return AnimatedOpacity(
      opacity: frame == null ? .0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}

class OrientatedCameraItemWidget extends StatelessWidget {
  const OrientatedCameraItemWidget({
    super.key,
    required this.orientation,
    required this.item,
  });

  final DeviceOrientation orientation;
  final CameraItem item;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scaleForItemWithOrientation(context, item, orientation),
      child: Transform.rotate(
        angle: rotationForItemWithOrientation(item, orientation),
        child: CameraItemWidget(item: item),
      ),
    );
  }
}
