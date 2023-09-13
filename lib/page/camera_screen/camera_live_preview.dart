import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_blur_bloc.dart';
import '../../controller/camera_settings_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../controller/camera_zoom_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';

/// Displays a live preview of the camera.
///
/// If the camera is not ready, displays a placeholder, then transitions to the
/// live preview.
///
/// Allows pinch-to-zoom.
class CameraLivePreview extends StatefulWidget {
  const CameraLivePreview({
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.minZoom,
    this.maxZoom,
    this.placeholder,
  });

  final Duration duration;
  final Curve curve;
  final double? minZoom;
  final double? maxZoom;
  final Widget? placeholder;

  @override
  State<CameraLivePreview> createState() => CameraLivePreviewState();
}

class CameraLivePreviewState extends State<CameraLivePreview> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<CameraStateBloc>().add(
          const InitializeCameraEvent(
            lensDirection: CameraLensDirection.back,
            resolutionPreset: ResolutionPreset.max,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraStateBloc, CameraState>(
      listenWhen: (previous, current) {
        return previous.controller != current.controller &&
            current.isInitialized;
      },
      listener: (context, state) {
        context
          ..read<CameraBlurBloc>().add(UnblurPreviewEvent(state.controller!))
          ..read<CameraZoomBloc>().add(
            InitializeCameraZoomLevels(
              camera: state.controller!,
              minimum: widget.minZoom,
              maximum: widget.maxZoom,
            ),
          )
          ..read<CameraSettingsBloc>().add(
            InitializeCameraSettingsEvent(camera: state.controller!),
          );
      },
      builder: (context, state) {
        final Widget child;
        final controller = state.controller;
        final isControllerReady = controller != null &&
            controller.value.isInitialized &&
            state.status == CameraStatus.ready;

        /// If the camera is not ready, display the placeholder.
        if (isControllerReady) {
          child = LayoutBuilder(
            key: const ValueKey("camera_live_preview"),
            builder: (context, constraints) {
              final size =
                  constraints.hasBoundedWidth && constraints.hasBoundedHeight
                      ? Size(constraints.maxWidth, constraints.maxHeight)
                      : MediaQuery.of(context).size;

              /// Calculate scale depending on screen and camera ratios;
              /// this is actually size.aspectRatio / (1 / camera.aspectRatio)
              /// because camera preview size is in landscape but portrait
              /// orientation is used.
              var scale = size.aspectRatio * controller.value.aspectRatio;

              /// Invert the value if it would scale down.
              if (scale < 1.0) scale = 1.0 / scale;

              return GestureDetector(
                onScaleUpdate: _updateCameraZoom,
                onScaleEnd: _saveCameraZoom,
                child: Transform.scale(
                  scale: scale + .001, // prevents borders
                  child: CameraPreview(controller),
                ),
              );
            },
          );
        } else {
          child = SizedBox(
            key: const ValueKey("camera_live_preview_placeholder"),
            child: context.read<CameraBlurBloc>().state.placeholder ??
                widget.placeholder,
          );
        }

        return RepaintBoundary(
          key: context.read<CameraBlurBloc>().repaintBoundaryKey,
          child: Align(child: child),
        );
      },
    );
  }

  void _updateCameraZoom(ScaleUpdateDetails details) {
    context.read<CameraZoomBloc>().add(
          SetCameraZoomByScale(scale: details.scale),
        );
  }

  void _saveCameraZoom(ScaleEndDetails details) {
    context.read<CameraZoomBloc>().add(const SaveCameraZoom());
  }
}
