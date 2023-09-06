import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;

import '../utility/converter/uint8_list_converter.dart';
import '../utility/converter/utc_date_time_converter.dart';
import 'camera_item_type.dart';

part 'camera_item.freezed.dart';
part 'camera_item.g.dart';

@freezed
class CameraItem with _$CameraItem {
  const factory CameraItem({
    required String name,
    @Uint8ListConverter() required Uint8List bytes,
    required int width,
    required int height,
    required CameraItemType type,
    required CameraLensDirection lensDirection,
    required DeviceOrientation orientation,
    @UtcDateTimeJsonConverter() required DateTime timeStamp,
  }) = _CameraItem;

  factory CameraItem.fromJson(Map<String, dynamic> json) =>
      _$CameraItemFromJson(json);
}

Future<File> moveFile({
  required File source,
  required String newPath,
}) async {
  try {
    /// Attempt to move the file to [newPath].
    return await source.rename(newPath);
  } on FileSystemException {
    // If moving fails, then copy it and delete
    final newFile = await source.copy(newPath);
    if (newFile.existsSync()) await source.delete();
    return newFile;
  } catch (o) {
    throw Exception("Failed to move file.");
  }
}

/// Compresses an image [File] with the specified [quality]. This function
/// appends [nameTag] to the end of the file name. The default value of
/// [nameTag] is "_cmp".
///
/// The compressed file is stored in the same directory as the source file.
///
/// Example: 'my_image.jpg' is compressed and saved as 'my_image_cmp.jpg'.
Future<File?> compressImage(
  File file, {
  required int quality,
  bool allowUncompressed = true,
  CompressFormat format = CompressFormat.jpeg,
  String nameTag = "_cmp",
}) async {
  if (!file.existsSync()) {
    throw Exception("File does not exist.");
  }

  /// Do not compress the file if it already compressed.
  if (path.basename(file.path).contains(nameTag)) return null;

  final name = path.basenameWithoutExtension(file.absolute.path);
  final directory = path.dirname(file.absolute.path);
  final extension = path.extension(file.absolute.path);
  final outputPath = path.join(directory, "$name$nameTag$extension");
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    outputPath,
    quality: quality,
    format: format,
  );

  if (compressedFile == null) {
    return allowUncompressed ? file : null;
  }

  return File(compressedFile.path);
}
