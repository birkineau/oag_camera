import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:oag_snack_bar/oag_snack_bar.dart';

import '../controller/camera_blur_bloc.dart';
import '../controller/camera_roll_bloc.dart';
import '../controller/camera_settings_bloc.dart';
import '../controller/camera_state_bloc.dart';
import '../controller/camera_zoom_bloc.dart';
import '../model/camera_item.dart';
import '../model/camera_settings_state.dart';
import '../model/camera_zoom.dart';
import 'camera_roll/camera_control_button.dart';
import 'camera_roll/camera_roll_button.dart';
import 'camera_roll/camera_roll_controls.dart';
import 'camera_screen/camera_back_button.dart';
import 'camera_screen/camera_screen.dart';
import 'camera_screen/camera_screen_controls.dart';
import 'camera_screen/camera_settings_exposure.dart';
import 'camera_screen/camera_settings_flash_mode.dart';
import 'camera_screen/camera_settings_focus.dart';
import 'camera_screen/camera_toggle_settings_button.dart';

final _overlayKey = GlobalKey<OagOverlayState>();

void showOverlay(
  Offset offset, {
  required Widget child,
  Duration? duration,
}) {
  final state = _overlayKey.currentState;
  if (state == null) return;
  state.showAtOffset(offset, child: child, duration: duration);
}

class CameraApplication extends StatefulWidget {
  static const heroCameraRollControls = "hero_camera_roll_controls";
  static const heroCameraRollItem = "hero_camera_roll_item";

  const CameraApplication({
    super.key,
    this.onBackButtonPressed,
    required this.maxItems,
    this.initialItems,
  });

  final VoidCallback? onBackButtonPressed;
  final int maxItems;
  final List<CameraItem>? initialItems;

  @override
  State<CameraApplication> createState() => CameraApplicationState();
}

class CameraApplicationState extends State<CameraApplication> {
  List<CameraItem> getItems() => _cameraRollBloc.state.items;

  final _cameraStateBloc = CameraStateBloc();
  final _cameraBlurBloc = CameraBlurBloc();
  late final CameraRollBloc _cameraRollBloc;
  final _cameraZoomBloc = CameraZoomBloc();
  final _cameraSettingsBloc = CameraSettingsBloc();

  @override
  void initState() {
    super.initState();

    GetIt.instance.registerSingleton(_overlayKey);

    _cameraRollBloc = CameraRollBloc(
      maxItems: widget.maxItems,
      initialItems: widget.initialItems,
    );
  }

  @override
  void dispose() {
    GetIt.instance.unregister<GlobalKey<OagOverlayState>>();

    _cameraStateBloc.close();
    _cameraBlurBloc.close();
    _cameraZoomBloc.close();
    _cameraRollBloc.close();
    _cameraSettingsBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    const threshold = 1.5;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cameraStateBloc),
        BlocProvider.value(value: _cameraBlurBloc),
        BlocProvider.value(value: _cameraZoomBloc),
        BlocProvider.value(value: _cameraSettingsBloc),
        BlocProvider.value(value: _cameraRollBloc),
      ],
      child: GestureDetector(
        onDoubleTap: _handleLivePreviewDoubleTap,
        child: OagOverlay(
          key: GetIt.instance<GlobalKey<OagOverlayState>>(),
          duration: const Duration(milliseconds: 500),
          tapToDismiss: true,
          allowDrag: true,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CameraScreen()),

              Positioned(
                width: CameraRollButton.kButtonSize,
                height: CameraRollButton.kButtonSize,
                top: mediaQuery.viewPadding.top,
                left: 8.0,
                child: CameraBackButton(onPressed: widget.onBackButtonPressed),
              ),

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
                  child: BlocBuilder<CameraSettingsBloc, CameraSettingsState>(
                    buildWhen: (_, current) =>
                        current != const CameraSettingsState.uninitialized(),
                    builder: (context, state) {
                      if (state == const CameraSettingsState.uninitialized()) {
                        return const SizedBox.shrink();
                      }

                      return const CameraSettingsExposure();
                    },
                  ),
                ),
              ),

              /// Open camera roll, take photo, and toggle lens direction buttons.
              Positioned(
                bottom: viewPadding.bottom + 8.0,
                left: viewPadding.left + 8.0,
                right: viewPadding.right + 8.0,
                child: const CameraScreenControls(),
              ),

              /// Camera roll controls placeholder; the [CameraRollControls] is
              /// wrapped by a [Hero] widget, so it needs to be placed in the widget
              /// tree before the [Hero] widget is used during the route transition.
              const Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: .0,
                    child: Hero(
                      tag: CameraApplication.heroCameraRollControls,
                      child: CameraRollControls(),
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

  void _handleLivePreviewDoubleTap() {
    /// Close the camera settings on double tap if they're visible.
    if (_cameraSettingsBloc.state.visible) {
      return _cameraSettingsBloc.add(
        const CameraSettingsSetVisible(visible: false),
      );
    }

    /// Reset zoom on double tap, if the zoom is not already at the
    /// minimum zoom and if the settings are closed.
    if (_cameraZoomBloc.state.current != _cameraZoomBloc.state.min) {
      log("reset zoom");
      return _cameraZoomBloc.add(const ResetCameraZoom());
    }

    _cameraBlurBloc.add(const BlurScreenshotEvent());

    final controller = _cameraStateBloc.state.controller;
    if (controller == null) return;

    final isBack =
        controller.description.lensDirection == CameraLensDirection.back;

    final SetCameraLensDirectionEvent setLensDirection;

    if (isBack) {
      setLensDirection = const SetCameraLensDirectionEvent(
        lensDirection: CameraLensDirection.front,
      );
    } else {
      setLensDirection = const SetCameraLensDirectionEvent(
        lensDirection: CameraLensDirection.back,
      );
    }

    _cameraStateBloc.add(setLensDirection);
  }
}

class MultiGestureRecognizer extends GestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  void acceptGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  String get debugDescription => "Multi gesture recognizer";
}
