import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oag_camera/app/app.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';
import 'package:oag_camera/utility/utility.dart';
import 'package:oag_snack_bar/oag_snack_bar.dart';

Future<void> showOverlay(
  BuildContext context,
  Offset offset, {
  required Widget child,
  Duration? duration,
}) async {
  final state = context.read<GlobalKey<OagOverlayState>>().currentState;
  if (state == null) return;
  if (state.visible) {
    state
      ..replace(child)
      ..restartDuration();
    return;
  }

  await state.showAtOffset(offset, child: child, duration: duration);
}

class CameraScreenPage extends StatefulWidget {
  static const heroCameraRollItem = "hero_camera_roll_item";
  static const heroCameraRollControls = "hero_camera_roll_controls";

  const CameraScreenPage({
    super.key,
    required this.configuration,
    this.initialItems,
  });

  final CameraConfiguration configuration;
  final List<CameraItem>? initialItems;

  @override
  State<CameraScreenPage> createState() => _CameraScreenPageState();

  static const path = "/camera";

  static void go(BuildContext context, CameraConfiguration configuration) {
    navigatorContext.go(path, extra: di<CameraConfiguration>());
  }

  static Page<void> pageBuilder(BuildContext context, GoRouterState state) {
    final configuration = di<CameraConfiguration>();

    /// Transition animations are handled manually.
    return NoTransitionPage(
      key: state.pageKey,
      child: CameraScreenPage(configuration: configuration),
    );
  }
}

class _CameraScreenPageState extends State<CameraScreenPage> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final topPadding = mediaQuery.viewPadding.top == .0 ? 8.0 : viewPadding.top;

    return DoubleTapDetector(
      onDoubleTap: () => _handleLivePreviewDoubleTap(context),
      child: OagOverlay(
        key: context.read<GlobalKey<OagOverlayState>>(),
        duration: const Duration(milliseconds: 500),
        tapToDismiss: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Camera live preview.
            const Positioned.fill(
              child: CameraPreviewWithOverlay(),
            ),

            /// Back button.
            Positioned(
              width: CameraRollButton.kButtonSize,
              height: CameraRollButton.kButtonSize,
              top: topPadding,
              left: 8.0,
              child: BlocSelector<CameraStateBloc, CameraState, bool>(
                selector: (state) => state.status == CameraStatus.ready,
                builder: (context, isReady) => CameraBackButton(
                  onPressed: isReady
                      ? () => context.read<CameraOverlayBloc>().add(
                            ShowFramePlaceholder(
                              callback:
                                  widget.configuration.onBackButtonPressed,
                            ),
                          )
                      : null,
                ),
              ),
            ),

            /// Settings visibility toglee button.
            Positioned(
              width: CameraRollButton.kButtonSize,
              height: CameraRollButton.kButtonSize,
              top: topPadding,
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
                    (mediaQuery.size.height - mediaQuery.padding.vertical) * .6,
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
                    child: widget.configuration.cameraRollMode ==
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
    );
  }

  Future<void> _handleLivePreviewDoubleTap(BuildContext context) async {
    if (!context.mounted) return;

    final cameraSettingsBloc = context.read<CameraSettingsBloc>();

    /// Close the camera settings on double tap if they're visible.
    if (cameraSettingsBloc.state.visible) {
      return cameraSettingsBloc.add(
        const CameraSettingsSetVisible(visible: false),
      );
    }

    final cameraZoomBloc = context.read<CameraZoomBloc>();

    /// Reset zoom on double tap, if the zoom is not already at the
    /// minimum zoom and if the settings are closed.
    if (cameraZoomBloc.state.current != cameraZoomBloc.state.min) {
      return cameraZoomBloc.add(const ResetCameraZoom());
    }

    if (widget.configuration.allowLensDirectionChange) {
      return _toggleLensDirection(
        cameraStateBloc: context.read<CameraStateBloc>(),
        cameraOverlayBloc: context.read<CameraOverlayBloc>(),
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
