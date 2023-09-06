import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_state_bloc.dart';
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
    const secondaryButtonSize = 56.0;
    const primaryButtonSize = secondaryButtonSize + 16.0;

    return const Column(
      children: [
        /// Zoom toggle/indicator.
        SizedBox(
          width: secondaryButtonSize,
          height: secondaryButtonSize,
          child: CameraZoomIndicator(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Camera roll button.
            Stack(
              children: [
                SizedBox(
                  width: secondaryButtonSize,
                  height: secondaryButtonSize,
                  child: CameraRollButton(),
                ),
              ],
            ),

            /// Take photo button.
            SizedBox(
              width: primaryButtonSize,
              height: primaryButtonSize,
              child: CameraTakePhotoButton(),
            ),

            /// Toggle lens direction button.
            SizedBox(
              width: secondaryButtonSize,
              height: secondaryButtonSize,
              child: CameraToggleLensDirectionButton(),
            ),
          ],
        ),
      ],
    );
  }
}
