import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import '../model/camera_item.dart';
import '../model/camera_item_type.dart';
import '../model/camera_state.dart';
import '../model/camera_status.dart';

const _notReadyState = CameraState(
  controller: null,
  status: CameraStatus.notReady,
  orientation: DeviceOrientation.portraitUp,
);

class CameraStateBloc extends Bloc<CameraEvent, CameraState> {
  CameraStateBloc()
      : _cameras = {},
        super(_notReadyState) {
    on<InitializeCameraEvent>(_initializeCamera);
    on<SetCameraDescriptionEvent>(_setDescription);
    on<SetCameraLensDirectionEvent>(_setLensDirection);
    on<UpdateOrientationEvent>(_updateOrientation);
    on<DisposeCameraEvent>(_disposeCamera);
  }

  /// Device cameras grouped by [CameraLensDirection].
  Map<CameraLensDirection, List<CameraDescription>> _cameras;

  List<CameraDescription> camerasForLensDirection(
    CameraLensDirection lensDirection,
  ) {
    return _cameras[lensDirection] ?? [];
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }

  /// Takes a photo [CameraItem] using the current camera.
  ///
  /// Returns `null` if the [maxItems] has been reached.
  ///
  /// Throws an [Exception] if the camera controller is null or is not
  /// initialized.
  Future<CameraItem?> takePhoto() async {
    final controller = state.controller;

    /// Ensure the [CameraController] is initialized.
    if (controller == null || !controller.value.isInitialized) {
      throw Exception("Camera controller is not initialized.");
    }

    try {
      final file = await controller.takePicture();
      final name = path.basename(file.path);
      final bytes = await file.readAsBytes();

      final buffer = await ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);

      final item = CameraItem(
        name: name,
        bytes: bytes,
        width: descriptor.width,
        height: descriptor.height,
        type: CameraItemType.photo,
        lensDirection: controller.description.lensDirection,
        orientation: controller.value.deviceOrientation,
        timeStamp: DateTime.now(),
      );

      log("Photo taken '$name'.", name: "$CameraStateBloc.takePhoto");
      buffer.dispose();
      descriptor.dispose();

      return item;
    } on CameraException catch (e) {
      log(
        "Unable to create camera item: ${e.toString()}",
        name: "$CameraStateBloc.takePhoto",
      );
      rethrow;
    } on Exception catch (e) {
      log(
        "Unable to read file as bytes: ${e.toString()}",
        name: "$CameraStateBloc.takePhoto",
      );
      rethrow;
    }
  }

  /// See [InitializeCameraEvent].
  Future<void> _initializeCamera(
    InitializeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CameraStatus.notReady));

      if (_cameras.isEmpty) {
        await _updateDeviceCameraList();
      }

      /// Dispose of any previous camera controller; removes listeners.
      if (state.controller != null) {
        state.controller!.removeListener(_orientationListener);
        await state.controller!.dispose();
      }

      /// Find the largest camera with a matching [lensDirection].
      final controller = CameraController(
        _cameras[event.lensDirection]!.last,
        event.resolutionPreset,
        enableAudio: event.enableAudio,
        imageFormatGroup: event.imageFormatGroup,
      );

      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

      controller.addListener(_orientationListener);

      log(
        "Initialized camera '${controller.description.name}'",
        name: "$CameraStateBloc._initialize",
      );

      emit(state.copyWith(controller: controller, status: CameraStatus.ready));
    } on CameraException catch (e) {
      log(
        "Unable to initialize camera controller; "
        "${e.code}${e.description != null ? " - ${e.description}" : ""}",
        name: "$CameraStateBloc._initialize",
      );

      rethrow;
    }
  }

  Future<void> _setDescription(
    SetCameraDescriptionEvent event,
    Emitter<CameraState> emit,
  ) async {
    final controller = state.controller;

    if (controller == null) {
      return Future.value();
    }

    final lensDirection =
        event.lensDirection ?? controller.description.lensDirection;

    final descriptions = _cameras[lensDirection];

    if (descriptions == null || descriptions.isEmpty) {
      return log(
        "No camera descriptions found for '$lensDirection'.",
        name: "$CameraStateBloc._setDescription",
      );
    }

    return await controller.setDescription(event.selector(descriptions));
  }

  Future<void> _setLensDirection(
    SetCameraLensDirectionEvent event,
    Emitter<CameraState> emit,
  ) async {
    await _initializeCamera(
      InitializeCameraEvent(lensDirection: event.lensDirection),
      emit,
    );
  }

  void _updateOrientation(
    UpdateOrientationEvent event,
    Emitter<CameraState> emit,
  ) {
    final controller = state.controller;

    if (controller == null) {
      return;
    }

    emit(state.copyWith(orientation: controller.value.deviceOrientation));
  }

  Future<void> _disposeCamera(
    DisposeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    state.dispose();
    emit(_notReadyState);
  }

  /// Updates the list of device cameras.
  ///
  /// Throws an [Exception] if no cameras are found.
  Future<void> _updateDeviceCameraList() async {
    try {
      _cameras = (await availableCameras()).groupListsBy(
        (camera) => camera.lensDirection,
      );

      for (final entry in _cameras.entries) {
        if (entry.value.isEmpty) {
          throw Exception("No device camera(s) found for '${entry.key}'.");
        }

        log(
          "Found ${entry.value.length} device camera(s) for '${entry.key}'.",
          name: "$CameraStateBloc._updateDeviceCameraList",
        );

        for (final camera in entry.value) {
          log(
            "\t${camera.name}",
            name: "$CameraStateBloc._updateDeviceCameraList",
          );
        }
      }
    } on CameraException catch (e) {
      log(
        "Camera exception: ${e.toString()}",
        name: "$CameraStateBloc._updateDeviceCameraList",
      );

      rethrow;
    }
  }

  void _orientationListener() => add(const UpdateOrientationEvent());
}

abstract class CameraEvent {
  const CameraEvent();
}

class InitializeCameraEvent extends CameraEvent {
  const InitializeCameraEvent({
    required this.lensDirection,
    this.resolutionPreset = ResolutionPreset.max,
    this.enableAudio = true,
    this.imageFormatGroup = ImageFormatGroup.yuv420,
  });

  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;
  final ImageFormatGroup imageFormatGroup;
}

class SetCameraDescriptionEvent extends CameraEvent {
  const SetCameraDescriptionEvent({
    required this.selector,
    this.lensDirection,
  });

  SetCameraDescriptionEvent.before({required CameraDescription current})
      : this(
          selector: (descriptions) => _getOtherDescription(
            current,
            descriptions,
            (index) => index - 1,
          ),
        );

  SetCameraDescriptionEvent.after({required CameraDescription current})
      : this(
          selector: (descriptions) => _getOtherDescription(
            current,
            descriptions,
            (index) => index + 1,
          ),
        );

  final CameraDescription Function(
    List<CameraDescription> descriptions,
  ) selector;

  final CameraLensDirection? lensDirection;
}

class SetCameraLensDirectionEvent extends CameraEvent {
  const SetCameraLensDirectionEvent({required this.lensDirection});

  final CameraLensDirection lensDirection;
}

class UpdateOrientationEvent extends CameraEvent {
  const UpdateOrientationEvent();
}

class DisposeCameraEvent extends CameraEvent {
  const DisposeCameraEvent();
}

CameraDescription _getOtherDescription(
  CameraDescription current,
  List<CameraDescription> descriptions,
  int Function(int) index,
) {
  final currentIndex = descriptions.indexOf(current);

  if (currentIndex == -1) {
    return descriptions.first;
  }

  return descriptions[index(currentIndex) % descriptions.length];
}
