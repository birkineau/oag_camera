import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_zoom_bloc.dart';
import '../../model/camera_zoom.dart';
import 'camera_orientation_rotator.dart';

class CameraZoomIndicator extends StatelessWidget {
  const CameraZoomIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    const decoration = BoxDecoration(shape: BoxShape.circle);
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
        );

    final button = GestureDetector(
      onTap: () => context.read<CameraZoomBloc>().add(const ResetCameraZoom()),
      child: Container(
        padding: const EdgeInsets.all(3.0),
        margin: const EdgeInsets.all(6.0),
        decoration: decoration.copyWith(color: Colors.black54),
        alignment: Alignment.center,
        child: BlocBuilder<CameraZoomBloc, CameraZoom>(
          builder: (context, zoom) {
            final zoomFactor = ((zoom.current - .5) * 10.0).round() / 10.0;

            return Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    zoomFactor == 1.0 ? "1" : zoomFactor.toString(),
                    style: textStyle,
                  ),
                ),
                const Icon(Icons.close, color: Colors.white, size: 12.0),
              ],
            );
          },
        ),
      ),
    );

    return CameraOrientationRotator(child: button);
  }
}
