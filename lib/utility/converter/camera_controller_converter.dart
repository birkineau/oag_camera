import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'camera_description_converter.dart';

class CameraControllerConverter
    extends JsonConverter<CameraController, Map<String, dynamic>> {
  const CameraControllerConverter();

  @override
  CameraController fromJson(Map<String, dynamic> json) {
    final resolutionPresetIndex =
        json[CameraControllerCodingKey.resolutionPreset] as int;

    final imageFormatGroupIndex =
        json[CameraControllerCodingKey.imageFormatGroup] as int?;

    return CameraController(
      const CameraDescriptionConverter().fromJson(
        json[CameraControllerCodingKey.description] as Map<String, dynamic>,
      ),
      ResolutionPreset.values.firstWhere(
        (resolutionPreset) => resolutionPreset.index == resolutionPresetIndex,
      ),
      enableAudio: json[CameraControllerCodingKey.enableAudio] as bool,
      imageFormatGroup: ImageFormatGroup.values.firstWhereOrNull(
        (value) => value.index == imageFormatGroupIndex,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(CameraController object) {
    return <String, dynamic>{
      CameraControllerCodingKey.description:
          const CameraDescriptionConverter().toJson(object.description),
      CameraControllerCodingKey.resolutionPreset: object.resolutionPreset.index,
      CameraControllerCodingKey.enableAudio: object.enableAudio,
      CameraControllerCodingKey.imageFormatGroup:
          object.imageFormatGroup?.index,
    };
  }
}

class CameraControllerCodingKey {
  static const description = "description";
  static const resolutionPreset = "resolutionPreset";
  static const enableAudio = "enableAudio";
  static const imageFormatGroup = "imageFormatGroup";
}
