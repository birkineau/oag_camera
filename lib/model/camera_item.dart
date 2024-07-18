import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/utility/utility.dart';

part 'camera_item.freezed.dart';
part 'camera_item.g.dart';

/// A [CameraItem] represents a single image or video captured by the camera.
@freezed
class CameraItem with _$CameraItem, EquatableMixin {
  const CameraItem._();

  const factory CameraItem({
    required String name,
    @Uint8ListConverter() required Uint8List bytes,
    required int width,
    required int height,
    required CameraItemType type,
    required CameraLensDirection lensDirection,
    required DeviceOrientation orientation,
    required double latitude,
    required double longitude,
    @UtcDateTimeJsonConverter() required DateTime timeStamp,
  }) = _CameraItem;

  factory CameraItem.fromJson(Map<String, dynamic> json) =>
      _$CameraItemFromJson(json);

  @override
  List<Object?> get props => [
        name,
        bytes.length,
        width,
        height,
        type,
        lensDirection,
        orientation,
        timeStamp,
        latitude,
        longitude,
      ];
}

/// Compresses the [CameraItem] to reduce the file size.
///
/// Useful for storage purposes.
Future<CameraItem> compressCameraItem(
  CameraItem item, {
  required int quality,
  // CompressFormat format = CompressFormat.jpeg,
}) async {
  return item;
  // final compressedBytes = await FlutterImageCompress.compressWithList(
  //   item.bytes,
  //   quality: quality,
  //   format: format,
  //   autoCorrectionAngle: false,
  // );

  // return item.copyWith(bytes: compressedBytes);
}

/// Moves the file from [source] to [newPath].
///
/// Useful for moving files from the temporary directory to the application
/// directory.
Future<File> moveFile({
  required File source,
  required String newPath,
}) async {
  try {
    /// Attempt to move the file to [newPath].
    return source.rename(newPath);
  } on FileSystemException {
    // If moving fails, then copy it and delete
    final newFile = await source.copy(newPath);
    if (newFile.existsSync()) await source.delete();
    return newFile;
  } catch (o) {
    throw Exception("Failed to move file.");
  }
}
