import 'package:flutter/material.dart';
import 'package:oag_camera/app/app.dart';
import 'package:oag_camera/oag_camera.dart';

class CameraRollSingleItemPage extends StatelessWidget {
  const CameraRollSingleItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraRollScreen(backgroundColor: Colors.transparent),
          Hero(
            tag: CameraScreenPage.heroCameraRollControls,
            flightShuttleBuilder: cameraRollControlsFlightShuttleBuilder,
            child: CameraRollSingleItemControls(),
          ),
        ],
      ),
    );
  }
}

class CameraRollSingleItemControls extends StatelessWidget {
  const CameraRollSingleItemControls({super.key});

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Confirm button.
        Positioned(
          width: CameraRollButton.kButtonSize,
          height: CameraRollButton.kButtonSize,
          top: viewPadding.top,
          left: 8.0,
          child: CameraControlButton(
            onPressed: di<CameraConfiguration>().onBackButtonPressed,
            child: Icon(
              Icons.done_rounded,
              size: 32.0,
              color: Colors.green.shade200,
            ),
          ),
        ),

        /// Delete button.
        Positioned(
          width: CameraRollButton.kButtonSize,
          height: CameraRollButton.kButtonSize,
          top: viewPadding.top,
          right: 8.0,
          child: const CameraRollDeleteSelectedItemButton(),
        ),
      ],
    );
  }
}
