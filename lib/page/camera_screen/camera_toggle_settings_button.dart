import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_settings_bloc.dart';
import '../camera_roll/camera_control_button.dart';
import 'camera_settings_flash_mode.dart';

class CameraToggleSettingsButton extends StatelessWidget {
  const CameraToggleSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final button = CameraControlButton(
      onPressed: () {
        final bloc = context.read<CameraSettingsBloc>();
        bloc.add(CameraSettingsSetVisible(visible: !bloc.state.visible));
      },
      child: const Icon(
        Icons.settings,
        color: Colors.white,
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
}
