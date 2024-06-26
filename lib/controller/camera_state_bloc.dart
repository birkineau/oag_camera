import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;

import '../model/camera_item.dart';
import '../model/camera_item_type.dart';
import '../model/camera_state.dart';
import '../model/camera_status.dart';

typedef _ImageData = ({Uint8List bytes, int width, int height});

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
    CameraStateBloc.dispose(this);
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
      // ignore: invalid_use_of_visible_for_testing_member
      emit(state.copyWith(status: CameraStatus.takingPhoto));

      final file = await controller.takePicture();

      Future<_ImageData> getImageData() async {
        final bytes = await file.readAsBytes();
        final buffer = await ImmutableBuffer.fromUint8List(bytes);
        final descriptor = await ui.ImageDescriptor.encoded(buffer);

        final data = (
          bytes: bytes,
          width: descriptor.width,
          height: descriptor.height,
        );

        buffer.dispose();
        descriptor.dispose();

        return data;
      }

      final operation = await Future.wait(
        [
          getImageData(),
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
        ],
      );

      final name = path.basename(file.path);
      final data = operation[0] as _ImageData;
      final position = operation[1] as Position;

      final item = CameraItem(
        name: name,
        bytes: data.bytes,
        width: data.width,
        height: data.height,
        type: CameraItemType.photo,
        lensDirection: controller.description.lensDirection,
        orientation: controller.value.deviceOrientation,
        timeStamp: position.timestamp,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      log("Photo taken '$name'.", name: "$CameraStateBloc.takePhoto");

      // ignore: invalid_use_of_visible_for_testing_member
      emit(state.copyWith(status: CameraStatus.ready));
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
      if (_cameras.isEmpty) await _updateDeviceCameraList();

      /// Dispose of any previous camera controller; removes listeners.
      if (state.controller != null) {
        await state.controller!.setExposureOffset(.0);
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
      event.onInitialized?.call();
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
    if (controller == null) return Future.value();

    final lensDirection =
        event.lensDirection ?? controller.description.lensDirection;

    final descriptions = _cameras[lensDirection];

    if (descriptions == null || descriptions.isEmpty) {
      return log(
        "No camera descriptions found for '$lensDirection'.",
        name: "$CameraStateBloc._setDescription",
      );
    }

    return controller.setDescription(event.selector(descriptions));
  }

  Future<void> _setLensDirection(
    SetCameraLensDirectionEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(state.copyWith(status: CameraStatus.notReady));

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
    if (controller == null) return;
    emit(state.copyWith(orientation: controller.value.deviceOrientation));
  }

  Future<void> _disposeCamera(
    DisposeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(_notReadyState);
    await CameraStateBloc.dispose(this);
  }

  /// Updates the list of device cameras.
  ///
  /// Throws an [Exception] if no cameras are found.
  Future<void> _updateDeviceCameraList() async {
    try {
      _cameras = (await availableCameras()).groupListsBy(
        (camera) => camera.lensDirection,
      );

      /// TODO: Remove when 'camera' package allows access to logical cameras.
      /// TODO: Create platform channel to access logical cameras.
      // if (Platform.isIOS) {
      //   _cameras[CameraLensDirection.back]?.add(
      //     const CameraDescription(
      //       name: "com.apple.avfoundation.avcapturedevice.built-in_video:6",
      //       lensDirection: CameraLensDirection.back,
      //       sensorOrientation: 90,
      //     ),
      //   );
      // }

      for (final entry in _cameras.entries) {
        entry.value.sort((a, b) => a.name.compareTo(b.name));
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

  void _orientationListener() {
    if (isClosed) return;
    add(const UpdateOrientationEvent());
  }

  static Future<void> dispose(CameraStateBloc bloc) async {
    final controller = bloc.state.controller;
    if (controller == null) return;

    controller.removeListener(bloc._orientationListener);
    return controller.dispose();
  }
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
    this.onInitialized,
  });

  InitializeCameraEvent.fromController(CameraController controller,
      {VoidCallback? onInitialized})
      : this(
          lensDirection: controller.description.lensDirection,
          resolutionPreset: controller.resolutionPreset,
          enableAudio: controller.enableAudio,
          imageFormatGroup:
              controller.imageFormatGroup ?? ImageFormatGroup.yuv420,
          onInitialized: onInitialized,
        );

  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;
  final ImageFormatGroup imageFormatGroup;
  final VoidCallback? onInitialized;
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
