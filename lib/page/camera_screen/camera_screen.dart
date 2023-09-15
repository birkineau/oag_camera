import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_blur_bloc.dart';
import 'camera_live_preview.dart';
import 'camera_screen_blur.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blurBloc = context.read<CameraBlurBloc>();

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraLivePreview(key: blurBloc.livePreviewKey, maxZoom: 5.5),

        /// Blurs the camera screen when switching lens direction.
        CameraScreenBlur(key: blurBloc.blurKey),
      ],
    );
  }
}
