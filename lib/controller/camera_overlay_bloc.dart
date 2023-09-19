import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../page/camera_screen/camera_live_preview.dart';
import '../page/camera_screen/camera_screen.dart';
import '../page/camera_screen/camera_screen_overlay.dart';

/// Controls the blur effect on the [CameraScreen].
class CameraOverlayBloc extends Bloc<CameraOverlayEvent, CameraOverlayState> {
  CameraOverlayBloc() : super(const CameraOverlayState.unblurred()) {
    on<ShowFramePlaceholder>(_showFramePlaceholder);
    on<BlurScreenshotEvent>(_blurScreenshot);
    on<UnblurScreenshotEvent>(_unblurScreenshot);
  }

  final repaintBoundaryKey = GlobalKey();
  final blurKey = GlobalKey<CameraScreenOverlayState>();
  final livePreviewKey = GlobalKey<CameraLivePreviewState>();

  Future<void> _showFramePlaceholder(
    ShowFramePlaceholder event,
    Emitter<CameraOverlayState> emit,
  ) async {
    try {
      final image = await _takeScreenshot();
      if (image == null) return;

      emit(
        CameraOverlayState(
          blur: .0,
          placeholder: RawImage(
            image: image,
            filterQuality: event.filterQuality,
          ),
          showOverlay: true,
        ),
      );

      event.callback?.call();
    } on Exception catch (e) {
      addError(e);
      emit(const CameraOverlayState.unblurred());
    }
  }

  Future<void> _blurScreenshot(
    BlurScreenshotEvent event,
    Emitter<CameraOverlayState> emit,
  ) async {
    try {
      final image = await _takeScreenshot();
      if (image == null) return;

      emit(
        CameraOverlayState(
          blur: 8.0,
          showOverlay: true,
          placeholder: RawImage(image: image),
        ),
      );
    } on Exception catch (e) {
      addError(e);
      emit(const CameraOverlayState.unblurred());
    }
  }

  Future<void> _unblurScreenshot(
    UnblurScreenshotEvent event,
    Emitter<CameraOverlayState> emit,
  ) async {
    emit(state.copyWith(showOverlay: false, blur: () => .0));
  }

  /// Takes a screenshot of the live camera preview using [repaintBoundaryKey].
  Future<ui.Image?> _takeScreenshot() async {
    final render = repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (render == null) {
      throw Exception("$RenderRepaintBoundary object not found.");
    }

    assert(
      !render.debugNeedsPaint,
      "The render object has not yet gone through the paint phase.",
    );

    return render.toImage();
  }
}

abstract class CameraOverlayEvent {
  const CameraOverlayEvent({this.callback});

  final VoidCallback? callback;
}

class ShowFramePlaceholder extends CameraOverlayEvent {
  const ShowFramePlaceholder({
    this.filterQuality = FilterQuality.medium,
    super.callback,
  });

  final FilterQuality filterQuality;
}

class BlurScreenshotEvent extends CameraOverlayEvent {
  const BlurScreenshotEvent({super.callback});
}

class UnblurScreenshotEvent extends CameraOverlayEvent {
  const UnblurScreenshotEvent({super.callback});
}

class CameraOverlayState extends Equatable {
  const CameraOverlayState({
    required this.blur,
    this.placeholder,
    this.showOverlay = false,
  });

  bool get isActive =>
      (blur == .0 && showOverlay) || (blur != .0 && showOverlay);

  const CameraOverlayState.unblurred()
      : blur = .0,
        placeholder = null,
        showOverlay = false;

  CameraOverlayState copyWith({
    double Function()? blur,
    RawImage Function()? placeholder,
    bool? showOverlay,
  }) {
    return CameraOverlayState(
      blur: blur != null ? blur() : this.blur,
      placeholder: placeholder != null ? placeholder() : this.placeholder,
      showOverlay: showOverlay ?? this.showOverlay,
    );
  }

  final double blur;
  final RawImage? placeholder;
  final bool showOverlay;

  @override
  List<Object?> get props => [blur, placeholder, showOverlay];
}
