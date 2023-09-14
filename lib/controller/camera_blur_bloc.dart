import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../page/camera_screen/camera_live_preview.dart';
import '../page/camera_screen/camera_screen.dart';
import '../page/camera_screen/camera_screen_blur.dart';

/// Controls the blur effect on the [CameraScreen].
class CameraBlurBloc extends Bloc<CameraBlurEvent, CameraBlurState> {
  CameraBlurBloc() : super(const CameraBlurState.unblurred()) {
    on<BlurPreviewEvent>(_blurPreview);
    on<UnblurPreviewEvent>(_unblurPreview);
    on<BlurScreenshotEvent>(_blurScreenshot);
    on<UnblurScreenshotEvent>(_unblurScreenshot);
  }

  final repaintBoundaryKey = GlobalKey();
  final blurKey = GlobalKey<CameraScreenBlurState>();
  final livePreviewKey = GlobalKey<CameraLivePreviewState>();

  void _blurPreview(BlurPreviewEvent event, Emitter<CameraBlurState> emit) {
    event.controller.pausePreview();
    emit(const CameraBlurState(isBlurred: true));
  }

  Future<void> _unblurPreview(
    UnblurPreviewEvent event,
    Emitter<CameraBlurState> emit,
  ) async {
    if (event.delay != null) await Future.delayed(event.delay!);
    event.controller.resumePreview();
    emit(const CameraBlurState.unblurred());
  }

  Future<void> _blurScreenshot(
    BlurScreenshotEvent event,
    Emitter<CameraBlurState> emit,
  ) async {
    try {
      final image = await _takeScreenshot();

      if (image == null) {
        return;
      }

      emit(
        CameraBlurState(isBlurred: true, placeholder: RawImage(image: image)),
      );
    } on Exception catch (e) {
      addError(e);
      emit(const CameraBlurState.unblurred());
    }
  }

  Future<void> _unblurScreenshot(
    UnblurScreenshotEvent event,
    Emitter<CameraBlurState> emit,
  ) async =>
      emit(const CameraBlurState.unblurred());

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

abstract class CameraBlurEvent {
  const CameraBlurEvent();
}

class BlurPreviewEvent extends CameraBlurEvent {
  const BlurPreviewEvent(this.controller);

  final CameraController controller;
}

class UnblurPreviewEvent extends CameraBlurEvent {
  const UnblurPreviewEvent(this.controller, {this.delay});

  final CameraController controller;
  final Duration? delay;
}

class BlurScreenshotEvent extends CameraBlurEvent {
  const BlurScreenshotEvent();
}

class UnblurScreenshotEvent extends CameraBlurEvent {
  const UnblurScreenshotEvent();
}

class CameraBlurState extends Equatable {
  const CameraBlurState({
    this.placeholder,
    this.isBlurred = false,
  });

  const CameraBlurState.unblurred()
      : placeholder = null,
        isBlurred = false;

  final RawImage? placeholder;
  final bool isBlurred;

  @override
  List<Object?> get props => [placeholder, isBlurred];
}
