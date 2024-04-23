import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/model/model.dart';

class CameraSettingsBloc
    extends Bloc<CameraSettingsEvent, CameraSettingsState> {
  CameraSettingsBloc() : super(const CameraSettingsState.uninitialized()) {
    on<InitializeCameraSettingsEvent>(_initializeCameraSettings);
    on<CameraSettingsSetVisible>(_setSettingsVisible);
    on<CameraSetExposureEvent>(_setExposure);
    on<CameraSetFlashModeEvent>(_setFlashMode);
    on<CameraSetFocusOffsetEvent>(_setFocus);
  }

  late CameraController _camera;

  Future<void> _initializeCameraSettings(
    InitializeCameraSettingsEvent event,
    Emitter<CameraSettingsState> emit,
  ) async {
    _camera = event.camera;

    final [min, max, stepSize] = await Future.wait(
      [
        event.camera.getMinExposureOffset(),
        event.camera.getMaxExposureOffset(),
        event.camera.getExposureOffsetStepSize(),
      ],
    );

    final step = stepSize == .0 ? .5 : stepSize;
    final range = centeredRange(min, max, step).cast<double>();

    assert(range.first == min);
    assert(range.last == max);

    emit(
      state.copyWith(
        initialized: true,
        flashMode: event.camera.value.flashMode,
        exposure: CameraExposure(
          minimum: min,
          maximum: max,
          step: step,
          range: range,
          value: (min + max) / 2.0,
        ),
      ),
    );

    log("Initialized camera settings.", name: "$CameraSettingsBloc");
  }

  void _setSettingsVisible(
    CameraSettingsSetVisible event,
    Emitter<CameraSettingsState> emit,
  ) {
    emit(state.copyWith(visible: event.visible));
  }

  void _setExposure(
    CameraSetExposureEvent event,
    Emitter<CameraSettingsState> emit,
  ) async {
    final value = await _camera.setExposureOffset(event.exposure);
    emit(state.copyWith(exposure: state.exposure.copyWith(value: value)));
  }

  void _setFlashMode(
    CameraSetFlashModeEvent event,
    Emitter<CameraSettingsState> emit,
  ) async {
    await _camera.setFlashMode(event.flashMode);
    emit(state.copyWith(flashMode: event.flashMode));
  }

  /// TODO: implement this when Flutter supports logical cameras; will likely need to do it myself through PlatformChannel.
  void _setFocus(
    CameraSetFocusOffsetEvent event,
    Emitter<CameraSettingsState> emit,
  ) {
    if (!_camera.value.focusPointSupported) {
      log("Focus point not supported.", name: "$CameraSettingsBloc._setFocus");
      return;
    }

    if (event.lock) {
    } else {
      // not locked
    }

    if (event.lock && state.focusMode != FocusMode.locked) {
      _camera.setFocusMode(FocusMode.locked);
    } else if (!event.lock && state.focusMode != FocusMode.auto) {
      _camera.setFocusMode(FocusMode.auto);
    }

    log("Current focus mode: ${_camera.value.focusMode}");
    _camera.setFocusPoint(event.offset!);
  }
}

abstract class CameraSettingsEvent {
  const CameraSettingsEvent();
}

class InitializeCameraSettingsEvent extends CameraSettingsEvent {
  const InitializeCameraSettingsEvent({required this.camera});

  final CameraController camera;
}

class CameraSettingsSetVisible extends CameraSettingsEvent {
  const CameraSettingsSetVisible({required this.visible});

  final bool visible;
}

class CameraSetExposureEvent extends CameraSettingsEvent {
  const CameraSetExposureEvent({required this.exposure});

  final double exposure;
}

class CameraSetFlashModeEvent extends CameraSettingsEvent {
  const CameraSetFlashModeEvent({required this.flashMode});

  final FlashMode flashMode;
}

class CameraSetFocusOffsetEvent extends CameraSettingsEvent {
  const CameraSetFocusOffsetEvent({
    this.lock = false,
    this.lockDuration = const Duration(seconds: 2),
    required this.offset,
  });

  final bool lock;
  final Duration lockDuration;
  final Offset? offset;
}

num roundToDecimal(num number, int places) {
  final mod = math.pow(10.0, places);
  return (number * mod).round().toDouble() / mod;
}

List<num> centeredRange(num start, num end, num step, {int roundTo = 2}) {
  List<num> range = [];

  if (step <= 0) {
    return [];
  }

  // Calculate the number of steps needed to reach 'end' from 0
  final steps = (end.abs() / step).round();

  // Recalculate the exact step needed to fit the range
  final exactStep = end.abs() / steps;

  // Generate the range
  for (int i = -steps; i <= steps; i++) {
    range.add(roundToDecimal(exactStep * i, roundTo));
  }

  return range;
}

({List<double> range, double step}) mapRange({
  required double sourceStart,
  required double sourceEnd,
  required double sourceStep,
  required double targetStart,
  required double targetEnd,
}) {
  final sourceDelta = sourceEnd - sourceStart;
  final targetDelta = targetEnd - targetStart;

  double mapValue(double value) {
    return ((value - sourceStart) / sourceDelta) * targetDelta + targetStart;
  }

  final sourceCount = (sourceDelta / sourceStep).ceil();

  return (
    range: [
      for (var i = 0; i <= sourceCount; i++)
        mapValue(sourceStart + i * sourceStep)
    ],
    step: targetDelta / sourceCount,
  );
}
