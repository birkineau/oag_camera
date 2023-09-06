import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_zoom.freezed.dart';
part 'camera_zoom.g.dart';

@freezed
class CameraZoom with _$CameraZoom {
  static const clamped = CameraZoom(
    min: 1.0,
    max: 1.0,
    previous: 1.0,
    current: 1.0,
  );

  const factory CameraZoom({
    required double min,
    required double max,
    required double previous,
    required double current,
  }) = _CameraZoom;

  factory CameraZoom.fromJson(Map<String, dynamic> json) =>
      _$CameraZoomFromJson(json);
}
