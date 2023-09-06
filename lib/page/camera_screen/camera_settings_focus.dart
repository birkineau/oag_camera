import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_settings_bloc.dart';
import 'camera_screen.dart';

class CameraSettingsFocus extends StatefulWidget {
  const CameraSettingsFocus({
    super.key,
    required this.cameraScreen,
  });

  final CameraScreen cameraScreen;

  @override
  State<CameraSettingsFocus> createState() => _CameraSettingsFocusState();
}

class _CameraSettingsFocusState extends State<CameraSettingsFocus> {
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // onTapUp: (details) {
      //   final offset = Offset(
      //     details.globalPosition.dx / mediaQuery.size.width,
      //     details.globalPosition.dy / mediaQuery.size.height,
      //   );

      //   log("focus point offset: $offset");

      //   final cameraSettingsBloc = context.read<CameraSettingsBloc>();
      //   cameraSettingsBloc.add(CameraSetFocusOffsetEvent(offset: offset));
      // },
      child: widget.cameraScreen,
    );
  }
}
