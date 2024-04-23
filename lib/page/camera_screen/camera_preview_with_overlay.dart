import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/oag_camera.dart';

class CameraPreviewWithOverlay extends StatelessWidget {
  const CameraPreviewWithOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final blurBloc = context.read<CameraOverlayBloc>();

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraLivePreview(
          key: blurBloc.livePreviewKey,
          maxZoom: 5.5,
        ),

        /// Blurs the camera screen when switching lens direction.
        CameraScreenOverlay(key: blurBloc.blurKey),
      ],
    );
  }
}
