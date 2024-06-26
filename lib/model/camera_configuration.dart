import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:oag_camera/oag_camera.dart';

/// Configures camera settings such as resolution, compression quality, and
/// initial lens direction, among other settings.
///
/// See:
/// * [CameraConfiguration.defaultCameraConfiguration]
/// * [CameraConfiguration.defaultSinglePortraitCamera]
class CameraConfiguration extends Equatable {
  /// A default camera configuration for a multi-purpose camera with the
  /// ability to change the lens direction.
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
      cameraRollMode: CameraRollMode.multiple,
      openCameraRollOnPhotoTaken: false,
      openCameraRollWhenFull: true,
      showCameraRollOnStartup: false,
    );
  }

  /// A default camera configuration for a single portrait camera.
  ///
  /// Prevents the user from changing the lens direction, and only allows a
  /// single photo to be taken.
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
      cameraRollMode: CameraRollMode.single,
      openCameraRollOnPhotoTaken: true,
      openCameraRollWhenFull: true,
      showCameraRollOnStartup: true,
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
    required this.cameraRollMode,
    required this.openCameraRollWhenFull,
    required this.showCameraRollOnStartup,
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
    bool? showCameraRollOnStartup,
  }) {
    return CameraConfiguration(
      onBackButtonPressed: onBackButtonPressed ?? this.onBackButtonPressed,
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      compressionQuality: compressionQuality ?? this.compressionQuality,
      maxPhotoItems: maxPhotoItems ?? this.maxPhotoItems,
      initialLensDirection: initialLensDirection ?? this.initialLensDirection,
      cameraRollMode: cameraRollType ?? cameraRollMode,
      allowLensDirectionChange:
          allowLensDirectionChange ?? this.allowLensDirectionChange,
      showCameraRoll: showCameraRoll ?? this.showCameraRoll,
      openCameraRollOnPhotoTaken:
          openCameraRollOnPhotoTaken ?? this.openCameraRollOnPhotoTaken,
      openCameraRollWhenFull:
          openCameraRollWhenFull ?? this.openCameraRollWhenFull,
      showCameraRollOnStartup:
          showCameraRollOnStartup ?? this.showCameraRollOnStartup,
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
  final CameraRollMode cameraRollMode;

  /// Whether the lens direction can be changed.
  final bool allowLensDirectionChange;

  /// Whether the camera roll button is visible.
  final bool showCameraRoll;

  /// Whether to open the camera roll when a photo is taken.
  final bool openCameraRollOnPhotoTaken;

  /// Whether to open the camera roll when the camera roll is full and the user
  /// attemps to take a photo/video.
  final bool openCameraRollWhenFull;

  /// Whether to show the camera roll on startup.
  final bool showCameraRollOnStartup;

  @override
  List<Object?> get props => [
        onBackButtonPressed,
        resolutionPreset,
        compressionQuality,
        maxPhotoItems,
        initialLensDirection,
        allowLensDirectionChange,
        cameraRollMode,
        showCameraRoll,
        openCameraRollOnPhotoTaken,
        openCameraRollWhenFull,
        showCameraRollOnStartup
      ];
}
