import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/camera_zoom.dart';

class CameraZoomBloc extends Bloc<CameraZoomEvent, CameraZoom> {
  CameraZoomBloc() : super(CameraZoom.clamped) {
    on<InitializeCameraZoomLevels>(_initialize);
    on<SetCameraZoomByValue>(_setByValue);
    on<SetCameraZoomByScale>(_setByScale);
    on<SaveCameraZoom>(_save);
    on<ResetCameraZoom>(_resetZoom);
  }

  late CameraController _camera;

  /// Initializes the minimum and maximum zoom levels for the camera.
  void _initialize(
    InitializeCameraZoomLevels event,
    Emitter<CameraZoom?> emit,
  ) async {
    _camera = event.camera;

    var [min, max] = await Future.wait(
      [
        event.camera.getMinZoomLevel(),
        event.camera.getMaxZoomLevel(),
      ],
    );

    /// Verify that the custom minimum zoom level is within the camera's
    /// supported range.
    if (event.minimum != null) {
      assert(event.minimum! >= min);
      min = event.minimum!;
    }

    /// Verify that the custom maximum zoom level is within the camera's
    /// supported range.
    if (event.maximum != null) {
      assert(event.maximum! <= max);
      max = event.maximum!;
    }

    log(
      "Initialized camera zoom levels; min: $min, max: $max",
      name: "$CameraZoomBloc._initialize",
    );

    emit(CameraZoom(min: min, max: max, previous: min, current: min));
  }

  /// Sets the camera zoom level by a specific value.
  void _setByValue(SetCameraZoomByValue event, Emitter<CameraZoom> emit) {
    if (_isAtBoundary(event.value) && _isAtBoundary(state.current)) return;
    _camera.setZoomLevel(event.value.clamp(state.min, state.max));
    emit(state.copyWith(previous: event.value, current: event.value));
  }

  /// Sets the camera zoom level by applying a scale to the current zoom level.
  void _setByScale(SetCameraZoomByScale event, Emitter<CameraZoom> emit) async {
    final clampedZoom = (state.previous * event.scale).clamp(
      state.min,
      state.max,
    );

    await _camera.setZoomLevel(clampedZoom);
    emit(state.copyWith(current: clampedZoom));
  }

  /// Saves the current zoom level as the previous zoom level for future scale
  /// calculations.
  void _save(SaveCameraZoom event, Emitter<CameraZoom?> emit) =>
      emit(state.copyWith(previous: state.current));

  void _resetZoom(ResetCameraZoom event, Emitter<CameraZoom> emit) {
    if (state.current != 1.0 || state.current == 1.5) {
      add(SetCameraZoomByValue(value: state.min));
    } else if (state.current == 1.0) {
      add(const SetCameraZoomByScale(scale: 1.5));
    } else if (state.current == 2.0) {
      add(const SetCameraZoomByValue(value: 1.0));
    }
  }

  bool _isAtBoundary(double value) => value == state.min || value == state.max;
}

abstract class CameraZoomEvent {
  const CameraZoomEvent();
}

class InitializeCameraZoomLevels extends CameraZoomEvent {
  const InitializeCameraZoomLevels({
    required this.camera,
    this.minimum,
    this.maximum,
  }) : assert(minimum == null || maximum == null || minimum <= maximum);

  final CameraController camera;
  final double? minimum;
  final double? maximum;
}

class SetCameraZoomByValue extends CameraZoomEvent {
  const SetCameraZoomByValue({required this.value});

  final double value;
}

class SetCameraZoomByScale extends CameraZoomEvent {
  const SetCameraZoomByScale({required this.scale});

  final double scale;
}

class SaveCameraZoom extends CameraZoomEvent {
  const SaveCameraZoom();
}

class ResetCameraZoom extends CameraZoomEvent {
  const ResetCameraZoom();
}
