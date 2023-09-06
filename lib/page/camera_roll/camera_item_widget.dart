import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/camera_item.dart';
import 'camera_item_preview.dart';

/// Displays the image from the [CameraItem].
///
/// If the [CameraItem] is from the front camera, then the image is flipped
/// horizontally or vertically depending on the [DeviceOrientation] of the
/// camera item in order to display the image without mirroring.
class CameraItemWidget extends StatelessWidget {
  const CameraItemWidget({
    super.key,
    this.filterQuality = FilterQuality.medium,
    required this.item,
  });

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
        fit: BoxFit.cover,
        filterQuality: filterQuality,
      ),
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
