import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/utility/utility.dart';

part 'camera_state.freezed.dart';
part 'camera_state.g.dart';

@freezed
class CameraState with _$CameraState, EquatableMixin {
  const CameraState._();

  const factory CameraState({
    @CameraControllerConverter() required CameraController? controller,
    required CameraStatus status,
    required DeviceOrientation orientation,
  }) = _CameraState;

  factory CameraState.fromJson(Map<String, dynamic> json) =>
      _$CameraStateFromJson(json);

  bool get isInitialized =>
      controller != null && controller!.value.isInitialized;

  @override
  List<Object?> get props => [controller, status, orientation];
}
