import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';

class CameraRollControls extends StatelessWidget {
  static const bottomSpacing = 32.0;

  const CameraRollControls({
    super.key,
    required this.enableListeners,
  });

  final bool enableListeners;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    final topPadding = viewPadding.top == .0 ? 8.0 : viewPadding.top;
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
          top: topPadding,
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
          top: topPadding,
          right: 8.0,
          child: const CameraRollDeleteSelectedItemButton(),
        ),

        /// Camera roll item selector; only visible when there is more than
        /// one item.
        Positioned(
          bottom: selectorBottomPadding,
          left: .0,
          right: .0,
          child: BlocSelector<CameraRollBloc, CameraRollState, bool>(
            selector: (state) => state.length <= 1,
            builder: (context, hasOneItemOrLess) => IgnorePointer(
              ignoring: hasOneItemOrLess,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasOneItemOrLess ? .0 : 1.0,
                child: CameraRollItemSelector(enableListeners: enableListeners),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: selectorBottomPadding - indicatorHeight - 4.0,
          child: CameraRollItemCountIndicator(
            enableListeners: enableListeners,
            height: indicatorHeight,
          ),
        ),
      ],
    );
  }
}
