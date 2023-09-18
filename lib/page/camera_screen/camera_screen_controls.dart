import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../controller/camera_state_bloc.dart';
import '../../model/camera_configuration.dart';
import '../../model/camera_state.dart';
import '../camera_roll/camera_roll_button.dart';
import 'camera_take_photo_button.dart';
import 'camera_toggle_lens_direction_button.dart';
import 'camera_zoom_indicator.dart';

typedef CameraControllerSelector
    = BlocSelector<CameraStateBloc, CameraState, CameraController?>;

/// The camera screen controls.
///
/// The camera screen controls are:
/// * Zoom indicator.
/// * Camera roll button.
/// * Take photo button.
/// * Toggle lens direction button.
class CameraScreenControls extends StatelessWidget {
  const CameraScreenControls({super.key});

  @override
  Widget build(BuildContext context) {
    final configuration = GetIt.I<CameraConfiguration>();

    return Column(
      children: [
        /// Zoom toggle/indicator.
        const SizedBox(
          width: CameraRollButton.kButtonSize,
          height: CameraRollButton.kButtonSize,
          child: CameraZoomIndicator(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Camera roll button.
            if (configuration.showCameraRoll)
              const Stack(
                children: [
                  SizedBox(
                    width: CameraRollButton.kButtonSize,
                    height: CameraRollButton.kButtonSize,
                    child: CameraRollButton(),
                  ),
                ],
              ),
            const Spacer(),

            /// Take photo button.
            const SizedBox(
              width: CameraRollButton.kButtonSize + 16.0,
              height: CameraRollButton.kButtonSize + 16.0,
              child: CameraTakePhotoButton(),
            ),
            const Spacer(),

            /// Toggle lens direction button.
            if (configuration.allowLensDirectionChange)
              const SizedBox(
                width: CameraRollButton.kButtonSize,
                height: CameraRollButton.kButtonSize,
                child: CameraToggleLensDirectionButton(),
              ),
          ],
        ),
      ],
    );
  }
}
