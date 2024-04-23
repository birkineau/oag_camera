import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_settings_bloc.dart';
import '../../model/camera_settings_state.dart';
import '../camera_roll/camera_control_button.dart';

/// Allows applications that embed this a way to navigate back to the previous
/// route through the [onPressed] callback.
class CameraBackButton extends StatelessWidget {
  const CameraBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = CameraControlButton(
      onPressed: onPressed,
      backgroundColor: Colors.black54,
      child: const Icon(Icons.arrow_back, color: Colors.white),
    );

    return BlocSelector<CameraSettingsBloc, CameraSettingsState, bool>(
      selector: (state) => state.visible,
      builder: (context, visible) => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,
        opacity: visible ? .0 : 1.0,
        child: button,
      ),
    );
  }
}
