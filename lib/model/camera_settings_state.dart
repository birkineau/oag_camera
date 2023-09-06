import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class CameraExposure extends Equatable {
  const CameraExposure({
    required this.minimum,
    required this.maximum,
    required this.step,
    required this.range,
    required this.value,
  });

  const CameraExposure.uninitialized()
      : this(
          minimum: .0,
          maximum: .0,
          step: .0,
          range: const [],
          value: .0,
        );

  final double minimum;
  final double maximum;
  final double step;
  final List<double> range;
  final double value;

  CameraExposure copyWith({
    double? minimum,
    double? maximum,
    double? step,
    List<double>? range,
    double? value,
  }) {
    return CameraExposure(
      minimum: minimum ?? this.minimum,
      maximum: maximum ?? this.maximum,
      step: step ?? this.step,
      range: range ?? this.range,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [minimum, maximum, step, range, value];
}

class CameraSettingsState extends Equatable {
  const CameraSettingsState({
    this.initialized = false,
    required this.flashMode,
    required this.exposure,
    required this.focusMode,
    required this.focusPoint,
    this.visible = false,
  });

  const CameraSettingsState.uninitialized()
      : this(
          initialized: false,
          flashMode: FlashMode.auto,
          focusMode: FocusMode.auto,
          exposure: const CameraExposure.uninitialized(),
          focusPoint: Offset.zero,
        );

  final bool initialized;
  final FlashMode flashMode;
  final CameraExposure exposure;
  final FocusMode focusMode;
  final Offset focusPoint;
  final bool visible;

  CameraSettingsState copyWith({
    bool? initialized,
    FlashMode? flashMode,
    CameraExposure? exposure,
    FocusMode? focusMode,
    Offset? focusPoint,
    bool? visible,
  }) {
    return CameraSettingsState(
      initialized: initialized ?? this.initialized,
      flashMode: flashMode ?? this.flashMode,
      exposure: exposure ?? this.exposure,
      focusMode: focusMode ?? this.focusMode,
      focusPoint: focusPoint ?? this.focusPoint,
      visible: visible ?? this.visible,
    );
  }

  @override
  List<Object?> get props => [
        initialized,
        flashMode,
        exposure,
        focusMode,
        focusPoint,
        visible,
      ];
}
