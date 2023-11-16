import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    Future<void> closeBloc<T>(BlocBase<T> bloc) async {
      if (!bloc.isClosed) await bloc.close();
    }

    _registerDi(widget.configuration);
    _registerDi(_cameraRollBloc, dispose: closeBloc);
    _registerDi(_cameraStateBloc, dispose: closeBloc);
    _registerDi(_cameraOverlayBloc, dispose: closeBloc);
    _registerDi(_cameraZoomBloc, dispose: closeBloc);
    _registerDi(_cameraSettingsBloc, dispose: closeBloc);

    _routerConfiguration = createRouterConfiguration(
      _navigatorKey,
      widget.configuration,
    );
  }

  @override
  void dispose() {
    _unregisterDi<CameraSettingsBloc>();
    _unregisterDi<CameraZoomBloc>();
    _unregisterDi<CameraOverlayBloc>();
    _unregisterDi<CameraStateBloc>();
    _unregisterDi<CameraRollBloc>();
    _unregisterDi<CameraConfiguration>();

    // _routerConfiguration.dispose();

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

void _registerDi<T extends Object>(
  T instance, {
  FutureOr<dynamic> Function(T)? dispose,
}) {
  if (GetIt.I.isRegistered<T>()) return;
  GetIt.I.registerSingleton<T>(instance, dispose: dispose);
}

void _unregisterDi<T extends Object>() {
  if (!GetIt.I.isRegistered<T>()) return;
  GetIt.I.unregister<T>();
}
