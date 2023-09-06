// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CameraState _$$_CameraStateFromJson(Map<String, dynamic> json) =>
    _$_CameraState(
      controller:
          _$JsonConverterFromJson<Map<String, dynamic>, CameraController>(
              json['controller'], const CameraControllerConverter().fromJson),
      status: $enumDecode(_$CameraStatusEnumMap, json['status']),
      orientation: $enumDecode(_$DeviceOrientationEnumMap, json['orientation']),
    );

Map<String, dynamic> _$$_CameraStateToJson(_$_CameraState instance) =>
    <String, dynamic>{
      'controller':
          _$JsonConverterToJson<Map<String, dynamic>, CameraController>(
              instance.controller, const CameraControllerConverter().toJson),
      'status': _$CameraStatusEnumMap[instance.status]!,
      'orientation': _$DeviceOrientationEnumMap[instance.orientation]!,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$CameraStatusEnumMap = {
  CameraStatus.notReady: 'notReady',
  CameraStatus.ready: 'ready',
};

const _$DeviceOrientationEnumMap = {
  DeviceOrientation.portraitUp: 'portraitUp',
  DeviceOrientation.landscapeLeft: 'landscapeLeft',
  DeviceOrientation.portraitDown: 'portraitDown',
  DeviceOrientation.landscapeRight: 'landscapeRight',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
