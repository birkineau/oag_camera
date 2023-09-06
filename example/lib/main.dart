import 'dart:developer';

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
      home: Example(),
    ),
  );
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final _cameraApplicationKey = GlobalKey<CameraApplicationState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraApplication(
            key: _cameraApplicationKey,
            maxItems: 10,
          ),
          Align(
            alignment: const Alignment(.0, .5),
            child: FloatingActionButton(
              onPressed: () {
                final state = _cameraApplicationKey.currentState;
                if (state == null) return;

                final items = state.getCameraItems();
                var i = 0;

                for (final item in items) {
                  log("Item ${++i}: ${item.name}");
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
