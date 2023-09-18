import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/controller.dart';
import 'camera_control_button.dart';
import 'camera_roll_button.dart';

class CameraRollDeleteSelectedItemButton extends StatelessWidget {
  const CameraRollDeleteSelectedItemButton({super.key});

  @override
  Widget build(BuildContext context) {
    const iconSize = CameraRollButton.kButtonSize / 2.0;

    return CameraControlButton(
      onPressed: () => _deleteSelectedItem(context),
      child: const Icon(
        Icons.delete_outline,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }

  void _deleteSelectedItem(BuildContext context) {
    final cameraRollBloc = context.read<CameraRollBloc>();
    if (cameraRollBloc.state.length == 1) Navigator.pop(context);
    cameraRollBloc.add(const DeleteSelectedItemEvent());

    /// When an item is deleted, ensure that the camera overlay becomes
    /// unblurred.
    ///
    /// This ensures that the user can see the live camera preview when they
    /// exit the camera roll.
    final cameraOverlayBloc = context.read<CameraOverlayBloc>();
    if (cameraOverlayBloc.state.isActive) {
      cameraOverlayBloc.add(const UnblurScreenshotEvent());
    }
  }
}
