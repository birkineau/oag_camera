import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';

class CameraTakePhotoButton extends StatefulWidget {
  const CameraTakePhotoButton({super.key});

  @override
  State<CameraTakePhotoButton> createState() => _CameraTakePhotoButtonState();
}

class _CameraTakePhotoButtonState extends State<CameraTakePhotoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  Future<void>? _tapDownAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    const beginScale = 1.0;
    const endScale = .875;

    _scaleAnimation = Tween(begin: beginScale, end: endScale).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CameraStateBloc, CameraState, CameraStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        return GestureDetector(
          /// Prevent the user from taking photos when the camera controller is
          /// uninitialized and from taking multiple photos at the same time.
          onTapDown: status == CameraStatus.ready && _tapDownAnimation == null
              ? _takePhoto
              : null,
          onTapUp: _reverseAnimationAfterTakingPhoto,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              border: Border.all(color: Colors.white, width: 3.0),
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
              child: Container(
                margin: const EdgeInsets.all(3.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _takePhoto(TapDownDetails details) async {
    final cameraRoll = context.read<CameraRollBloc>();
    if (cameraRoll.state.isFull) {
      throw Exception("Camera roll is full.");
    }

    final cameraController = context.read<CameraStateBloc>();

    _tapDownAnimation = Future(
      () async {
        _animationController.forward();

        final photo = await cameraController.takePhoto();

        if (photo == null) {
          /// TODO: Display error message.
          return log(
            "Unable to take photo.",
            name: "$CameraTakePhotoButton._takePhoto",
          );
        }

        cameraRoll.add(AddItemEvent(item: photo));
      },
    );

    setState(() {});
  }

  void _reverseAnimationAfterTakingPhoto(TapUpDetails details) async {
    try {
      await _tapDownAnimation;
    } catch (e) {
      rethrow;
    } finally {
      setState(() => _tapDownAnimation = null);
      _animationController.reverse();
    }
  }
}
