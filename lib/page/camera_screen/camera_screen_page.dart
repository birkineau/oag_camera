import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:oag_camera/page/camera_roll/camera_roll_single_item_page.dart';
import 'package:oag_snack_bar/oag_snack_bar.dart';

import '../../controller/camera_overlay_bloc.dart';
import '../../controller/camera_roll_bloc.dart';
import '../../controller/camera_settings_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../controller/camera_zoom_bloc.dart';
import '../../model/camera_configuration.dart';
import '../../model/camera_item.dart';
import '../../model/camera_status.dart';
import '../../utility/double_tap_detector.dart';
import '../camera_roll/camera_roll_button.dart';
import '../camera_roll/camera_roll_controls.dart';
import '../camera_roll/camera_roll_page.dart';
import 'camera_back_button.dart';
import 'camera_screen.dart';
import 'camera_screen_controls.dart';
import 'camera_settings_exposure.dart';
import 'camera_settings_flash_mode.dart';
import 'camera_toggle_settings_button.dart';
import 'deleted_camera_item_animation.dart';

final _overlayKey = GlobalKey<OagOverlayState>();

Future<void> showOverlay(
  Offset offset, {
  required Widget child,
  Duration? duration,
}) async {
  final state = _overlayKey.currentState;
  if (state == null) return;
  if (state.visible) {
    state
      ..replace(child)
      ..restartDuration();
    return;
  }

  await state.showAtOffset(offset, child: child, duration: duration);
}

class CameraScreenPage extends StatelessWidget {
  static const heroCameraRollItem = "hero_camera_roll_item";
  static const heroCameraRollControls = "hero_camera_roll_controls";

  static const routeName = "/camera_application";

  static void go(BuildContext context) => context.go(routeName);

  static GoRoute route({required CameraConfiguration configuration}) {
    return GoRoute(
      path: routeName,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          key: state.pageKey,
          child: CameraScreenPage(configuration: configuration),
        );
      },
      routes: [CameraRollPage.route()],
    );
  }

  const CameraScreenPage({
    super.key,
    required this.configuration,
    this.initialItems,
  });

  final CameraConfiguration configuration;
  final List<CameraItem>? initialItems;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.I<CameraRollBloc>()),
        BlocProvider.value(value: GetIt.I<CameraStateBloc>()),
        BlocProvider.value(value: GetIt.I<CameraOverlayBloc>()),
        BlocProvider.value(value: GetIt.I<CameraZoomBloc>()),
        BlocProvider.value(value: GetIt.I<CameraSettingsBloc>()),
      ],
      child: DoubleTapDetector(
        onDoubleTap: _handleLivePreviewDoubleTap,
        child: OagOverlay(
          key: _overlayKey,
          duration: const Duration(milliseconds: 500),
          tapToDismiss: true,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CameraScreen()),

              /// Back button.
              Positioned(
                width: CameraRollButton.kButtonSize,
                height: CameraRollButton.kButtonSize,
                top: mediaQuery.viewPadding.top,
                left: 8.0,
                child: CameraBackButton(
                  onPressed: () => GetIt.I<CameraOverlayBloc>().add(
                    ShowFramePlaceholder(
                      callback: configuration.onBackButtonPressed,
                    ),
                  ),
                ),
              ),

              /// Settings visibility toglee button.
              Positioned(
                width: CameraRollButton.kButtonSize,
                height: CameraRollButton.kButtonSize,
                top: viewPadding.top,
                right: 8.0,
                child: const CameraToggleSettingsButton(),
              ),

              const Positioned(
                top: .0,
                left: .0,
                right: .0,
                child: CameraSettingsFlashMode(),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height:
                      (mediaQuery.size.height - mediaQuery.padding.vertical) *
                          .6,
                  child: const CameraSettingsExposure(),
                ),
              ),

              /// Open camera roll, take photo, and toggle lens direction buttons.
              Positioned(
                bottom: viewPadding.bottom + 8.0,
                left: viewPadding.left + 8.0,
                right: viewPadding.right + 8.0,
                child: const CameraScreenControls(),
              ),

              /// Animates the deletion of the last item  in the camera roll.
              const Positioned.fill(child: DeletedCameraItemAnimation()),

              /// Camera roll controls placeholder; the [CameraRollControls] is
              /// wrapped by a [Hero] widget, so it needs to be placed in
              /// the widget tree before the [Hero] widget is used during the
              /// route transition to avoid overlap.
              Positioned.fill(
                child: Opacity(
                  opacity: .0,
                  child: IgnorePointer(
                    child: Hero(
                      tag: CameraScreenPage.heroCameraRollControls,
                      child: configuration.cameraRollType ==
                              CameraRollMode.single
                          ? const CameraRollSingleItemControls()
                          : const CameraRollControls(enableListeners: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLivePreviewDoubleTap() async {
    final cameraSettingsBloc = GetIt.I<CameraSettingsBloc>();

    /// Close the camera settings on double tap if they're visible.
    if (cameraSettingsBloc.state.visible) {
      return cameraSettingsBloc.add(
        const CameraSettingsSetVisible(visible: false),
      );
    }

    final cameraZoomBloc = GetIt.I<CameraZoomBloc>();

    /// Reset zoom on double tap, if the zoom is not already at the
    /// minimum zoom and if the settings are closed.
    if (cameraZoomBloc.state.current != cameraZoomBloc.state.min) {
      return cameraZoomBloc.add(const ResetCameraZoom());
    }

    if (configuration.allowLensDirectionChange) {
      return _toggleLensDirection(
        cameraStateBloc: GetIt.I<CameraStateBloc>(),
        cameraOverlayBloc: GetIt.I<CameraOverlayBloc>(),
      );
    }
  }
}

Future<void> _toggleLensDirection({
  required CameraStateBloc cameraStateBloc,
  required CameraOverlayBloc cameraOverlayBloc,
}) async {
  /// Toggle the camera lens direction on double tap, if the camera is ready.
  if (cameraStateBloc.state.status != CameraStatus.ready) return;
  cameraOverlayBloc.add(const BlurScreenshotEvent());

  /// If, for some reason, the controller is null, unblur and return.
  final controller = cameraStateBloc.state.controller;
  if (controller == null) {
    throw StateError(
      "Attempted to toggle lens direction, but the "
      "camera controller is null.",
    );
  }

  final oppositeLensDirection =
      controller.description.lensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

  cameraStateBloc.add(
    SetCameraLensDirectionEvent(lensDirection: oppositeLensDirection),
  );
}
