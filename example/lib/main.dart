import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:oag_camera/oag_camera.dart';

/// TODO: Holding the page and using the selector makes the diplayed item incorrect.
/// TODO: Take videos.
/// TODO: Face detection.
/// TODO: Text recognition.
void main() async {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraExample(),
    ),
  );
}

class CameraExample extends StatefulWidget {
  const CameraExample({super.key});

  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  final _cameraApplicationKey = GlobalKey<CameraState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Camera(
        key: _cameraApplicationKey,
        // configuration: CameraConfiguration.defaultCameraConfiguration(
        //   onBackButtonPressed: () => log("Back button pressed."),
        // ),
        configuration: CameraConfiguration.defaultSinglePortraitCamera(
          onBackButtonPressed: () => log("Back button pressed."),
        ),
      ),
    );
  }
}
