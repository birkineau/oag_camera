import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/controller.dart';
import '../camera_screen/camera_screen_page.dart';
import 'camera_roll_controls.dart';
import 'camera_roll_screen.dart';

class CameraRollPage extends StatelessWidget {
  static const routeName = "camera_roll";

  static void go(
    BuildContext context, {
    required CameraStateBloc cameraStateBloc,
    required CameraRollBloc cameraRollBloc,
    required CameraOverlayBloc cameraOverlayBloc,
  }) {
    context.go(
      "${CameraScreenPage.routeName}/$routeName",
      extra: [
        cameraStateBloc,
        cameraRollBloc,
        cameraOverlayBloc,
      ],
    );
  }

  static GoRoute route() {
    return GoRoute(
      path: routeName,
      pageBuilder: (context, state) {
        final providers = state.extra as List<Object>;

        assert(providers.length == 3);
        assert(providers[0] is CameraStateBloc);
        assert(providers[1] is CameraRollBloc);
        assert(providers[2] is CameraOverlayBloc);

        const duration = Duration(milliseconds: 400);

        return CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: providers[0] as CameraStateBloc),
              BlocProvider.value(value: providers[1] as CameraRollBloc),
              BlocProvider.value(value: providers[2] as CameraOverlayBloc),
            ],
            child: const CameraRollPage(),
          ),
        );
      },
    );
  }

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
