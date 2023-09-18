import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';
import 'camera_control_button.dart';
import 'camera_roll_button.dart';
import 'camera_roll_delete_selected_item_button.dart';
import 'camera_roll_screen.dart';

class CameraRollSingleItemPage extends StatelessWidget {
  const CameraRollSingleItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    const opacityAnimationDuration = Duration(milliseconds: 500);
    final viewPadding = MediaQuery.of(context).viewPadding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CameraRollScreen(),

          /// Delete button.
          Positioned(
            width: CameraRollButton.kButtonSize,
            height: CameraRollButton.kButtonSize,
            top: viewPadding.top,
            right: 8.0,
            child: ValueListenableBuilder<bool>(
              valueListenable: isCameraRollOpenNotifier,
              builder: (context, isOpen, child) => AnimatedOpacity(
                duration: opacityAnimationDuration,
                opacity: isOpen ? 1.0 : .0,
                child: child,
              ),
              child: const CameraRollDeleteSelectedItemButton(),
            ),
          ),

          /// Confirm button.
          Positioned(
            width: CameraRollButton.kButtonSize,
            height: CameraRollButton.kButtonSize,
            top: viewPadding.top,
            left: 8.0,
            child: ValueListenableBuilder<bool>(
              valueListenable: isCameraRollOpenNotifier,
              builder: (context, isOpen, child) => AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isOpen ? 1.0 : .0,
                child: child,
              ),
              child: CameraControlButton(
                onPressed: () {
                  final configuration = GetIt.I<CameraConfiguration>();

                  context.read<CameraOverlayBloc>().add(
                        ShowFramePlaceholder(
                          callback: configuration.onBackButtonPressed,
                        ),
                      );
                },
                child: const Icon(
                  Icons.done_rounded,
                  size: 32.0,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
