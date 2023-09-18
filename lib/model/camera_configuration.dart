import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

import '../page/camera_roll/camera_roll_button.dart';

class CameraConfiguration extends Equatable {
  static CameraConfiguration defaultCameraConfiguration({
    required VoidCallback onBackButtonPressed,
  }) {
    return CameraConfiguration(
      onBackButtonPressed: onBackButtonPressed,
      resolutionPreset: ResolutionPreset.max,
      compressionQuality: 50,
      maxPhotoItems: 5,
      initialLensDirection: CameraLensDirection.back,
      allowLensDirectionChange: true,
      showCameraRoll: true,
      cameraRollType: CameraRollMode.multiple,
      openCameraRollOnPhotoTaken: false,
      openCameraRollWhenFull: true,
    );
  }

  static CameraConfiguration defaultSinglePortraitCamera({
    required VoidCallback onBackButtonPressed,
  }) {
    return CameraConfiguration(
      onBackButtonPressed: onBackButtonPressed,
      resolutionPreset: ResolutionPreset.max,
      compressionQuality: 50,
      maxPhotoItems: 1,
      initialLensDirection: CameraLensDirection.front,
      allowLensDirectionChange: false,
      showCameraRoll: false,
      cameraRollType: CameraRollMode.single,
      openCameraRollOnPhotoTaken: true,
      openCameraRollWhenFull: true,
    );
  }

  const CameraConfiguration({
    required this.onBackButtonPressed,
    required this.resolutionPreset,
    required this.compressionQuality,
    required this.maxPhotoItems,
    required this.initialLensDirection,
    required this.allowLensDirectionChange,
    required this.showCameraRoll,
    required this.openCameraRollOnPhotoTaken,
    required this.cameraRollType,
    required this.openCameraRollWhenFull,
  });

  CameraConfiguration copyWith({
    VoidCallback? onBackButtonPressed,
    ResolutionPreset? resolutionPreset,
    int? compressionQuality,
    int? maxPhotoItems,
    CameraLensDirection? initialLensDirection,
    CameraRollMode? cameraRollType,
    bool? allowLensDirectionChange,
    bool? showCameraRoll,
    bool? openCameraRollOnPhotoTaken,
    bool? openCameraRollWhenFull,
  }) {
    return CameraConfiguration(
      onBackButtonPressed: onBackButtonPressed ?? this.onBackButtonPressed,
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      compressionQuality: compressionQuality ?? this.compressionQuality,
      maxPhotoItems: maxPhotoItems ?? this.maxPhotoItems,
      initialLensDirection: initialLensDirection ?? this.initialLensDirection,
      cameraRollType: cameraRollType ?? this.cameraRollType,
      allowLensDirectionChange:
          allowLensDirectionChange ?? this.allowLensDirectionChange,
      showCameraRoll: showCameraRoll ?? this.showCameraRoll,
      openCameraRollOnPhotoTaken:
          openCameraRollOnPhotoTaken ?? this.openCameraRollOnPhotoTaken,
      openCameraRollWhenFull:
          openCameraRollWhenFull ?? this.openCameraRollWhenFull,
    );
  }

  /// The callback for when the back button is pressed from the camera preview
  /// screen.
  ///
  /// This is also called when the user presses the close button from a single
  /// camera item screen.
  final VoidCallback? onBackButtonPressed;

  /// The resolution preset.
  final ResolutionPreset resolutionPreset;

  /// The compression quality of the photo in the range 0..100.
  final int compressionQuality;

  /// The maximum number of photos that can be taken.
  final int maxPhotoItems;

  /// The initial lens direction.
  final CameraLensDirection initialLensDirection;

  /// The type of camera roll.
  ///
  /// * [CameraRollMode.single] - The camera roll is used to display a single
  /// camera item.
  /// * [CameraRollMode.multiple] - The camera roll is used to display multiple
  /// camera items.
  final CameraRollMode cameraRollType;

  /// Whether the lens direction can be changed.
  final bool allowLensDirectionChange;

  /// Whether the camera roll button is visible.
  final bool showCameraRoll;

  /// Whether to open the camera roll when a photo is taken.
  final bool openCameraRollOnPhotoTaken;

  /// Whether to open the camera roll when the camera roll is full and the user
  /// attemps to take a photo/video.
  final bool openCameraRollWhenFull;

  @override
  List<Object?> get props => [
        onBackButtonPressed,
        resolutionPreset,
        compressionQuality,
        maxPhotoItems,
        initialLensDirection,
        allowLensDirectionChange,
        showCameraRoll,
        openCameraRollOnPhotoTaken,
        cameraRollType,
        openCameraRollWhenFull,
      ];
}
