import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'controller/controller.dart';
import 'model/model.dart';
import 'page/camera_roll/camera_roll_page.dart';
import 'page/camera_screen/camera_screen_page.dart';

GoRouter createRouterConfiguration(
  GlobalKey<NavigatorState> navigatorKey,
  CameraConfiguration configuration,
) {
  final String initialLocation;

  if (configuration.showCameraRollOnStartup &&
      !GetIt.I<CameraRollBloc>().state.isEmpty) {
    initialLocation =
        "${CameraScreenPage.routeName}/" "${CameraRollPage.routeName}";
  } else {
    initialLocation = CameraScreenPage.routeName;
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      CameraScreenPage.route(configuration: configuration),
    ],
  );
}
