import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/controller.dart';
import '../camera_application.dart';
import 'camera_roll_controls.dart';
import 'camera_roll_screen.dart';

class CameraRollPage extends StatelessWidget {
  const CameraRollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraRollScreen(),
          Hero(
            tag: CameraApplication.heroCameraRollControls,
            flightShuttleBuilder: cameraRollControlsFlightShuttleBuilder,
            child: CameraRollControls(enableListeners: true),
          ),
        ],
      ),
    );
  }
}

Widget cameraRollControlsFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final curve = CurvedAnimation(
    parent: animation,
    curve: const Interval(.25, 1.0, curve: Curves.easeInQuad),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: fromHeroContext.read<CameraStateBloc>()),
      BlocProvider.value(value: fromHeroContext.read<CameraRollBloc>()),
    ],
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: child,
      ),
      child: flightDirection == HeroFlightDirection.push
          ? toHeroContext.widget
          : fromHeroContext.widget,
    ),
  );
}
