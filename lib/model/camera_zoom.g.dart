// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_zoom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CameraZoomImpl _$$CameraZoomImplFromJson(Map<String, dynamic> json) =>
    _$CameraZoomImpl(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      previous: (json['previous'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
    );

Map<String, dynamic> _$$CameraZoomImplToJson(_$CameraZoomImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'previous': instance.previous,
      'current': instance.current,
    };
