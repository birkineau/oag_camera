import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'oag_camera.dart';
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
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _routerConfiguration;

  @override
  void initState() {
    super.initState();

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
