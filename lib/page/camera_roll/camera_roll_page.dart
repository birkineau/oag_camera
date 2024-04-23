import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oag_camera/app/app.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/oag_camera.dart';

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
            tag: CameraScreenPage.heroCameraRollControls,
            flightShuttleBuilder: cameraRollControlsFlightShuttleBuilder,
            child: CameraRollControls(enableListeners: true),
          ),
        ],
      ),
    );
  }

  /// The path for the [CameraRollPage].
  ///
  /// The [CameraRollPage] is nested under the [CameraScreenPage].
  static const path = "${CameraScreenPage.path}/camera_roll";

  static void go(BuildContext context) {
    context.go(path);
  }

  static Page<void> pageBuilder(BuildContext context, GoRouterState state) {
    const duration = Duration(milliseconds: 400);
    final cameraRollMode = di<CameraConfiguration>().cameraRollMode;

    return CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
      child: cameraRollMode == CameraRollMode.single
          ? const CameraRollSingleItemPage()
          : const CameraRollPage(),
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
