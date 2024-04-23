import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:oag_camera/oag_camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// TODO: Holding the page and using the selector makes the diplayed item incorrect.
/// TODO: Take videos.
/// TODO: Face detection.
/// TODO: Text recognition/scanning.
/// TODO: Barcode/QR code scanning.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// For example purposes, we will request the camera permission here, and
  /// expect it to be granted by the user.
  ///
  /// Permissions should be handled externally by a different package due to
  /// separation of concerns.
  final cameraPermission = await Permission.camera.request();

  if (cameraPermission.isGranted) {
    log("Camera permission granted.");
  } else {
    throw StateError("Camera permission not granted.");
  }

  final locationWhenInUsePermission =
      await Permission.locationWhenInUse.request();

  if (locationWhenInUsePermission.isGranted) {
    log("Location when in use permission granted.");
  } else {
    throw StateError("Location when in use permission not granted.");
  }

  runApp(const CameraExample());
}

class CameraExample extends StatelessWidget {
  const CameraExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CameraApplication(
          key: const ValueKey("oag_camera_application"),
          configuration: CameraConfiguration.defaultCameraConfiguration(
            onBackButtonPressed: () => log("Back button pressed."),
          ),
        ),
      ),
    );
  }
}
