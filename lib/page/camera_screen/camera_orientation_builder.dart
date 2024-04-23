import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';

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
