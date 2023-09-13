import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../model/camera_roll_state.dart';
import 'camera_roll_button.dart';
import 'camera_control_button.dart';
import 'camera_roll_item_count_indicator.dart';
import 'camera_roll_item_selector.dart';

class CameraRollControls extends StatelessWidget {
  static const bottomSpacing = 32.0;

  const CameraRollControls({super.key});

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    const iconSize = CameraRollButton.kButtonSize / 2.0;
    final selectorBottomPadding = viewPadding.bottom + bottomSpacing;
    const indicatorHeight = 36.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        /// Back button.
        Positioned(
          width: CameraRollButton.kButtonSize,
          height: CameraRollButton.kButtonSize,
          top: viewPadding.top,
          left: 8.0,
          child: CameraControlButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ),

        /// Delete button.
        Positioned(
          width: CameraRollButton.kButtonSize,
          height: CameraRollButton.kButtonSize,
          top: viewPadding.top,
          right: 8.0,
          child: CameraControlButton(
            onPressed: () => _deleteSelectedItem(context),
            child: const Icon(
              Icons.delete_outline,
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ),

        /// Camera roll item selector; only visible when there is more than
        /// one item.
        Positioned(
          bottom: selectorBottomPadding,
          left: .0,
          right: .0,
          child: BlocBuilder<CameraRollBloc, CameraRollState>(
            buildWhen: (_, current) => !current.isEmpty,
            builder: (context, state) {
              final hasOneItem = state.length == 1;

              return IgnorePointer(
                ignoring: hasOneItem,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: hasOneItem ? .0 : 1.0,
                  child: const CameraRollItemSelector(),
                ),
              );
            },
          ),
        ),

        Positioned(
          bottom: selectorBottomPadding - indicatorHeight - 4.0,
          child: const CameraRollItemCountIndicator(height: indicatorHeight),
        ),
      ],
    );
  }

  void _deleteSelectedItem(BuildContext context) {
    final cameraRollBloc = context.read<CameraRollBloc>();
    if (cameraRollBloc.state.length == 1) {
      Navigator.pop(context);
    }

    cameraRollBloc.add(const DeleteSelectedItemEvent());
  }
}
