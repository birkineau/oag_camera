import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/app/app.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';

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

class CameraLivePreviewState extends State<CameraLivePreview>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);

    final configuration = di<CameraConfiguration>();

    context.read<CameraStateBloc>().add(
          InitializeCameraEvent(
            lensDirection: configuration.initialLensDirection,
            resolutionPreset: configuration.resolutionPreset,
          ),
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraStateBloc = context.read<CameraStateBloc>();
    final controller = cameraStateBloc.state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    final cameraOverlayBloc = context.read<CameraOverlayBloc>();

    final initializer = InitializeCameraEvent.fromController(
      controller,

      /// When the application resumes, wait until the camera is reinitialized
      /// before unblurring the camera preview overlay.
      onInitialized: () => cameraOverlayBloc.add(
        UnblurScreenshotEvent(
          callback: () => CameraStateBloc.dispose(cameraStateBloc),
        ),
      ),
    );

    if (state == AppLifecycleState.inactive) {
      return cameraOverlayBloc.add(
        BlurScreenshotEvent(
          callback: () => CameraStateBloc.dispose(cameraStateBloc),
        ),
      );
    }

    if (state == AppLifecycleState.resumed && !cameraStateBloc.isClosed) {
      return cameraStateBloc.add(initializer);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraStateBloc, CameraState>(
      listenWhen: _cameraControllerChanged,
      listener: _updateCameraController,
      builder: (context, state) {
        final controller = state.controller;
        final isControllerInitialized = controller != null &&
            controller.value.isInitialized &&
            (state.status == CameraStatus.ready ||
                state.status == CameraStatus.takingPhoto);

        final cameraOverlayBloc = context.read<CameraOverlayBloc>();

        if (!isControllerInitialized) {
          return cameraOverlayBloc.state.placeholder ??
              const ColoredBox(color: Colors.black);
        }

        /// If the camera is not ready, display the placeholder.
        final preview = LayoutBuilder(
          key: ValueKey(controller.value.description.name),
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

        return RepaintBoundary(
          key: cameraOverlayBloc.repaintBoundaryKey,
          child: Align(child: preview),
        );
      },
    );
  }

  bool _cameraControllerChanged(CameraState previous, CameraState current) {
    return previous.controller != current.controller && current.isInitialized;
  }

  void _updateCameraController(BuildContext context, CameraState state) {
    context
      ..read<CameraOverlayBloc>().add(const UnblurScreenshotEvent())
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
