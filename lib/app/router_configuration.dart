import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oag_camera/app/app.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/oag_camera.dart';

typedef _NavigatorKey = GlobalKey<NavigatorState>;

/// This application is fairly simple, so the router configuration is also
/// simple. The [CameraScreenPage], and the [CameraRollPage] are the only routes
/// in the application.
GoRouter createRouterConfiguration(CameraRollBloc cameraRollBloc) {
  final navigatorKey = registerDependency(
    _NavigatorKey(),
    instanceName: navigatorInstanceKey,
  );

  final showCameraRoll = di<CameraConfiguration>().showCameraRollOnStartup;
  final String initialLocation;

  /// The initial location is dependent on the configuration. If the app was
  /// started with initial items, and the camera roll is set to show on startup,
  /// then the initial location is the [CameraRollPage].
  ///
  /// Otherwise, the initial location is the [CameraScreenPage].
  if (showCameraRoll && !cameraRollBloc.state.isEmpty) {
    initialLocation = "${CameraScreenPage.path}/${CameraRollPage.path}";
  } else {
    initialLocation = CameraScreenPage.path;
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: CameraScreenPage.path,
        pageBuilder: CameraScreenPage.pageBuilder,
        routes: [
          GoRoute(
            path: _getLastNestedPath(CameraRollPage.path),
            pageBuilder: CameraRollPage.pageBuilder,
          ),
        ],
      ),
    ],
  );
}

/// Returns the navigator context from the dependency injector.
BuildContext get navigationContext {
  assert(
    di.isRegistered<_NavigatorKey>(instanceName: navigatorInstanceKey),
    "GlobalKey<NavigatorState> instance is not registered with the dependency "
    "injector.",
  );

  final navigatorKey = di<_NavigatorKey>(instanceName: navigatorInstanceKey);
  final context = navigatorKey.currentContext;

  assert(
    context != null,
    "Navigator key does not have a current context. "
    "Did you forget to add the navigator key to the GoRouter instance?",
  );

  return context!;
}

/// Returns the last path component from a path string.
///
/// For example, if the path is "/camera_application/camera_roll", then the
/// last path component is "camera_roll". The path separator '/' is excluded
/// because [GoRouter] nested paths must not start with a '/'.
String _getLastNestedPath(String path) {
  final subpath = path.split("/");

  if (subpath.length <= 1) {
    throw ArgumentError("Path must have at least one nested path.");
  }

  return subpath.last;
}
