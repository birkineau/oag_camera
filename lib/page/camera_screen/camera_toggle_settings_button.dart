import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_settings_bloc.dart';
import '../../model/camera_settings_state.dart';
import '../camera_roll/camera_control_button.dart';
import 'camera_settings_flash_mode.dart';

typedef CameraSettingsFlashSelector
    = BlocSelector<CameraSettingsBloc, CameraSettingsState, FlashMode>;

class CameraToggleSettingsButton extends StatelessWidget {
  const CameraToggleSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final button = CameraControlButton(
      onPressed: () {
        final bloc = context.read<CameraSettingsBloc>();
        bloc.add(CameraSettingsSetVisible(visible: !bloc.state.visible));
      },
      child: CameraSettingsFlashSelector(
        selector: (state) => state.flashMode,
        builder: (context, flashMode) => Icon(
          _flashModeToIcon(flashMode),
          color: Colors.white,
        ),
      ),
    );

    return CameraSettingsSelector(
      selector: (state) => state.visible,
      builder: (context, visible) => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,
        opacity: visible ? .0 : 1.0,
        child: button,
      ),
    );
  }

  IconData _flashModeToIcon(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        throw ArgumentError.value(flashMode);
    }
  }
}
