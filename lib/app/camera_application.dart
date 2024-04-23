import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:oag_camera/app/router_configuration.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/oag_camera.dart';
import 'package:oag_snack_bar/oag_snack_bar.dart';

/// Dependency injector.
///
/// This will be used to simplify various navigation related tasks; for example,
/// to enable navigation without an explicit [BuildContext].
final di = GetIt.instance;

const navigatorInstanceKey = "oag_camera_navigator_key_instance";

/// The [CameraApplication] handles taking photos, and managing the camera roll.
///
/// Items stored in the camera roll can be retrieved by using a
/// `GlobalKey<CameraApplicationState>` to access the
/// [CameraApplicationState.items] getter.
class CameraApplication extends StatefulWidget {
  const CameraApplication({
    super.key,
    required this.configuration,
    this.initialItems,
  });

  /// Camera application configuration. See [CameraConfiguration].
  final CameraConfiguration configuration;

  /// Items added to the camera roll when the camera is opened.
  final List<CameraItem>? initialItems;

  @override
  State<CameraApplication> createState() => CameraApplicationState();
}

class CameraApplicationState extends State<CameraApplication> {
  /// The items in the camera roll.
  ///
  /// Allows external access to the camera roll items through a
  /// `GlobalKey<CameraState>`.
  List<CameraItem>? get items {
    if (_cameraRollBloc.state.items.isEmpty) {
      return null;
    }

    return _cameraRollBloc.state.items;
  }

  final _overlayKey = GlobalKey<OagOverlayState>();

  /// By holding the instances in the state itself, we can make them available
  /// through the [di] dependency injector if necessary.
  ///
  /// For now, we simply use the instances to provide them to th
  /// [MultiBlocProvider].
  late final CameraRollBloc _cameraRollBloc;
  final _cameraStateBloc = CameraStateBloc();
  final _cameraOverlayBloc = CameraOverlayBloc();
  final _cameraZoomBloc = CameraZoomBloc();
  final _cameraSettingsBloc = CameraSettingsBloc();

  late final GoRouter _routerConfiguration;

  @override
  void initState() {
    super.initState();

    registerDependency<CameraConfiguration>(widget.configuration);

    _cameraRollBloc = CameraRollBloc(
      maxItems: widget.configuration.maxPhotoItems,
      initialItems: widget.initialItems,
    );

    _routerConfiguration = createRouterConfiguration(_cameraRollBloc);
  }

  @override
  void dispose() {
    /// Since all camera bloc instances are passed to the respective
    /// [BlocProvider] widgets, they will be automatically closed when the
    /// the application is disposed.

    unregisterDependency<CameraConfiguration>();

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

T registerDependency<T extends Object>(T instance, {String? instanceName}) {
  if (di.isRegistered<T>(instanceName: instanceName)) {
    return di.get<T>(instanceName: instanceName);
  }

  return di.registerSingleton<T>(instance, instanceName: instanceName);
}

void unregisterDependency<T extends Object>({String? instanceName}) {
  if (di.isRegistered<T>(instanceName: instanceName)) {
    di.unregister<T>(instanceName: instanceName);
  }
}
