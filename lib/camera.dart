import 'dart:async';

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

    Future<void> closeBloc<T>(BlocBase<T> bloc) async {
      if (!bloc.isClosed) await bloc.close();
    }

    registerDi(widget.configuration);
    registerDi(_cameraRollBloc, dispose: closeBloc);
    registerDi(_cameraStateBloc, dispose: closeBloc);
    registerDi(_cameraOverlayBloc, dispose: closeBloc);
    registerDi(_cameraZoomBloc, dispose: closeBloc);
    registerDi(_cameraSettingsBloc, dispose: closeBloc);

    _routerConfiguration = createRouterConfiguration(
      _navigatorKey,
      widget.configuration,
    );
  }

  @override
  void dispose() {
    unregisterDi<CameraSettingsBloc>();
    unregisterDi<CameraZoomBloc>();
    unregisterDi<CameraOverlayBloc>();
    unregisterDi<CameraStateBloc>();
    unregisterDi<CameraRollBloc>();
    unregisterDi<CameraConfiguration>();

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

void registerDi<T extends Object>(
  T instance, {
  FutureOr<dynamic> Function(T)? dispose,
}) {
  if (GetIt.I.isRegistered<T>()) return;
  GetIt.I.registerSingleton<T>(instance, dispose: dispose);
}

void unregisterDi<T extends Object>() {
  if (!GetIt.I.isRegistered<T>()) return;
  GetIt.I.unregister<T>();
}
