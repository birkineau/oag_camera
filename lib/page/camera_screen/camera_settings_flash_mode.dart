import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';

typedef CameraSettingsSelector<T>
    = BlocSelector<CameraSettingsBloc, CameraSettingsState, T>;

class CameraSettingsFlashMode extends StatefulWidget {
  const CameraSettingsFlashMode({super.key});

  @override
  State<CameraSettingsFlashMode> createState() =>
      _CameraSettingsFlashModeState();
}

class _CameraSettingsFlashModeState extends State<CameraSettingsFlashMode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    );

    final flashModeMenu = Container(
      padding: EdgeInsets.only(top: viewPadding.top),
      color: Colors.black54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: const Text(
                "FLASH MODE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
          const Divider(height: .0),
          SizedBox(
            height: 48.0,
            child: BlocBuilder<CameraStateBloc, CameraState>(
                buildWhen: (previous, current) {
              return previous.controller != null &&
                  current.controller != null &&
                  previous.controller!.value.description.lensDirection !=
                      current.controller!.value.description.lensDirection;
            }, builder: (context, state) {
              final isFrontLens =
                  state.controller!.value.description.lensDirection ==
                      CameraLensDirection.front;

              return CameraSettingsSelector(
                selector: (state) => state.flashMode,
                builder: (context, currentFlashMode) => Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final flashMode in FlashMode.values)
                      if (!isFrontLens ||
                          (isFrontLens && flashMode != FlashMode.torch))
                        Expanded(
                          child: TextButton(
                            onPressed: flashMode == currentFlashMode
                                ? null
                                : () => _setFlashMode(flashMode),
                            style: buttonStyle,
                            child: Text(
                              flashMode.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: flashMode == currentFlashMode
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                                fontWeight: flashMode == currentFlashMode
                                    ? FontWeight.w500
                                    : FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );

    return CameraSettingsVisibility(
      duration: const Duration(milliseconds: 500),
      child: flashModeMenu,
    );
  }

  void _setFlashMode(FlashMode flashMode) {
    context.read<CameraSettingsBloc>().add(
          CameraSetFlashModeEvent(flashMode: flashMode),
        );
  }
}
