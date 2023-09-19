import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'controller/controller.dart';
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
  State<Camera> createState() => CameraState();
}

class CameraState extends State<Camera> {
  List<CameraItem>? get items {
    if (_cameraRollBloc.state.items.isEmpty) return null;
    return _cameraRollBloc.state.items;
  }

  late final CameraRollBloc _cameraRollBloc;
  late final GoRouter _routerConfiguration;

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    _cameraRollBloc = CameraRollBloc(
      maxItems: widget.configuration.maxPhotoItems,
      initialItems: widget.initialItems,
    );

    if (!GetIt.I.isRegistered<CameraRollBloc>()) {
      GetIt.I.registerSingleton<CameraRollBloc>(_cameraRollBloc);
    }

    _routerConfiguration = createRouterConfiguration(
      _navigatorKey,
      widget.configuration,
    );
  }

  @override
  void dispose() {
    _routerConfiguration.dispose();
    _cameraRollBloc.close();
    GetIt.I.unregister<CameraRollBloc>();
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
