import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'oag_camera.dart';
import 'page/camera_screen/camera_screen_page.dart';
import 'router_configuration.dart';

class Camera extends StatefulWidget {
  const Camera({
    super.key,
    required this.configuration,
    this.initialItems,
  });

  final CameraConfiguration configuration;
  final List<CameraItem>? initialItems;

  @override
  State<Camera> createState() => CameraState();
}

class CameraState extends State<Camera> {
  List<CameraItem> get items {
    final state = _cameraScreenPageKey.currentState;
    if (state == null) return [];
    return state.getItems();
  }

  final _cameraScreenPageKey = GlobalKey<CameraScreenPageState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _routerConfiguration;

  @override
  void initState() {
    super.initState();

    if (!GetIt.I.isRegistered<GlobalKey<CameraScreenPageState>>()) {
      GetIt.I.registerSingleton(_cameraScreenPageKey);
    }

    _routerConfiguration = createRouterConfiguration(
      _navigatorKey,
      widget.configuration,
      widget.initialItems,
    );
  }

  @override
  void dispose() {
    _routerConfiguration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
      routerConfig: _routerConfiguration,
    );
  }
}
