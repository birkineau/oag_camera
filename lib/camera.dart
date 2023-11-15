import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'controller/controller.dart';
import 'oag_camera.dart';
import 'router_configuration.dart';

/// TODO: Delete XFile after reading bytes.
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
  final _cameraStateBloc = CameraStateBloc();
  final _cameraOverlayBloc = CameraOverlayBloc();
  final _cameraZoomBloc = CameraZoomBloc();
  final _cameraSettingsBloc = CameraSettingsBloc();

  final _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _routerConfiguration;

  @override
  void initState() {
    super.initState();

    _cameraRollBloc = CameraRollBloc(
      maxItems: widget.configuration.maxPhotoItems,
      initialItems: widget.initialItems,
    );

    void close<T>(BlocBase<T> bloc) {
      if (!bloc.isClosed) bloc.close();
    }

    if (!GetIt.I.isRegistered<CameraConfiguration>()) {
      GetIt.I.registerSingleton(widget.configuration);
    }

    GetIt.I
      ..registerSingleton(_cameraRollBloc, dispose: close)
      ..registerSingleton(_cameraStateBloc, dispose: close)
      ..registerSingleton(_cameraOverlayBloc, dispose: close)
      ..registerSingleton(_cameraZoomBloc, dispose: close)
      ..registerSingleton(_cameraSettingsBloc, dispose: close);

    _routerConfiguration = createRouterConfiguration(
      _navigatorKey,
      widget.configuration,
    );
  }

  @override
  void dispose() {
    GetIt.I
      ..unregister<CameraSettingsBloc>()
      ..unregister<CameraZoomBloc>()
      ..unregister<CameraOverlayBloc>()
      ..unregister<CameraStateBloc>()
      ..unregister<CameraRollBloc>()
      ..unregister<CameraConfiguration>();

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
