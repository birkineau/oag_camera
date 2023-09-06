import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class CameraDescriptionConverter
    extends JsonConverter<CameraDescription, Map<String, dynamic>> {
  const CameraDescriptionConverter();

  @override
  CameraDescription fromJson(Map<String, dynamic> json) {
    return CameraDescription(
      name: json[CameraDescriptionCodingKey.name] as String,
      lensDirection: CameraLensDirection.values.firstWhereOrNull(
            (value) =>
                value.index ==
                json[CameraDescriptionCodingKey.lensDirection] as int,
          ) ??
          CameraLensDirection.external,
      sensorOrientation:
          json[CameraDescriptionCodingKey.sensorOrientation] as int,
    );
  }

  @override
  Map<String, dynamic> toJson(CameraDescription object) {
    return <String, dynamic>{
      CameraDescriptionCodingKey.name: object.name,
      CameraDescriptionCodingKey.lensDirection: object.lensDirection.index,
      CameraDescriptionCodingKey.sensorOrientation: object.sensorOrientation,
    };
  }
}

class CameraDescriptionCodingKey {
  static const name = "name";
  static const lensDirection = "lensDirection";
  static const sensorOrientation = "sensorOrientation";
}
