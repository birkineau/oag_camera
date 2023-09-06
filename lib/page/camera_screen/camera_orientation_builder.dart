import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';

class CameraOrientationBuilder extends StatelessWidget {
  const CameraOrientationBuilder({
    super.key,
    required this.bloc,
    required this.builder,
  });

  final CameraStateBloc bloc;
  final Widget Function(BuildContext, DeviceOrientation) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraStateBloc, CameraState>(
      bloc: bloc,
      buildWhen: _orientationChanged,
      builder: (context, state) {
        return builder(context, state.orientation);
      },
    );
  }
}

bool _orientationChanged(CameraState previous, CameraState current) {
  return previous.orientation != current.orientation;
}
