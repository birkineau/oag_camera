import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/controller.dart';
import '../camera_screen/camera_screen_page.dart';
import 'camera_roll_button.dart';
import 'camera_roll_controls.dart';
import 'camera_roll_screen.dart';
import 'camera_roll_single_item_page.dart';

class CameraRollPage extends StatelessWidget {
  static const routeName = "camera_roll";

  static void go(
    BuildContext context, {
    required CameraRollMode mode,
    required CameraStateBloc cameraStateBloc,
    required CameraRollBloc cameraRollBloc,
    required CameraOverlayBloc cameraOverlayBloc,
  }) {
    context.go(
      "${CameraScreenPage.routeName}/$routeName",
      extra: [
        mode,
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
        final args = state.extra as List<Object>;

        assert(args.length == 4);
        assert(args[0] is CameraRollMode);
        assert(args[1] is CameraStateBloc);
        assert(args[2] is CameraRollBloc);
        assert(args[3] is CameraOverlayBloc);

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
              BlocProvider.value(value: args[1] as CameraStateBloc),
              BlocProvider.value(value: args[2] as CameraRollBloc),
              BlocProvider.value(value: args[3] as CameraOverlayBloc),
            ],
            child: (args[0] as CameraRollMode) == CameraRollMode.multiple
                ? const CameraRollPage()
                : const CameraRollSingleItemPage(),
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
