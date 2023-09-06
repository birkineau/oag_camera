import 'package:flutter/material.dart';
import 'package:oag_camera/page/camera_application.dart';

/// TODO: Always keep it turning like a page in different orientations.
/// TODO: Holding the page and using the selector makes the diplayed item incorrect.
/// TODO: Figure out how to switch from wide lens to regular camera on zoom.
/// TODO: Take videos.
/// TODO: Face detection.
/// TODO: Text recognition.
void main() async {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CameraApplication(maxItems: 10),
      ),
    ),
  );
}
