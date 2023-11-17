import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oag_snack_bar/oag_snack_bar.dart';

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

  final _overlayKey = GlobalKey<OagOverlayState>();

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

    _routerConfiguration = createRouterConfiguration(
      _navigatorKey,
      widget.configuration,
      _cameraRollBloc,
    );
  }

  @override
  void dispose() {
    _routerConfiguration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.configuration),
        RepositoryProvider.value(value: _overlayKey),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => _cameraRollBloc),
          BlocProvider(create: (_) => _cameraStateBloc),
          BlocProvider(create: (_) => _cameraOverlayBloc),
          BlocProvider(create: (_) => _cameraZoomBloc),
          BlocProvider(create: (_) => _cameraSettingsBloc),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context),
          routerConfig: _routerConfiguration,
        ),
      ),
    );
  }
}
