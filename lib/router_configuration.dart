import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'model/model.dart';
import 'page/camera_screen/camera_screen_page.dart';

GoRouter createRouterConfiguration(
  GlobalKey<NavigatorState> navigatorKey,
  CameraConfiguration configuration,
) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: CameraScreenPage.routeName,
    routes: [
      CameraScreenPage.route(configuration: configuration),
    ],
  );
}
