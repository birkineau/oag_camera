// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CameraItem _$$_CameraItemFromJson(Map<String, dynamic> json) =>
    _$_CameraItem(
      name: json['name'] as String,
      bytes: const Uint8ListConverter().fromJson(json['bytes'] as List<int>),
      width: json['width'] as int,
      height: json['height'] as int,
      type: $enumDecode(_$CameraItemTypeEnumMap, json['type']),
      lensDirection:
          $enumDecode(_$CameraLensDirectionEnumMap, json['lensDirection']),
      orientation: $enumDecode(_$DeviceOrientationEnumMap, json['orientation']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timeStamp: const UtcDateTimeJsonConverter()
          .fromJson(json['timeStamp'] as String),
    );

Map<String, dynamic> _$$_CameraItemToJson(_$_CameraItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'bytes': const Uint8ListConverter().toJson(instance.bytes),
      'width': instance.width,
      'height': instance.height,
      'type': _$CameraItemTypeEnumMap[instance.type]!,
      'lensDirection': _$CameraLensDirectionEnumMap[instance.lensDirection]!,
      'orientation': _$DeviceOrientationEnumMap[instance.orientation]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timeStamp': const UtcDateTimeJsonConverter().toJson(instance.timeStamp),
    };

const _$CameraItemTypeEnumMap = {
  CameraItemType.photo: 'photo',
  CameraItemType.video: 'video',
};

const _$CameraLensDirectionEnumMap = {
  CameraLensDirection.front: 'front',
  CameraLensDirection.back: 'back',
  CameraLensDirection.external: 'external',
};

const _$DeviceOrientationEnumMap = {
  DeviceOrientation.portraitUp: 'portraitUp',
  DeviceOrientation.landscapeLeft: 'landscapeLeft',
  DeviceOrientation.portraitDown: 'portraitDown',
  DeviceOrientation.landscapeRight: 'landscapeRight',
};
