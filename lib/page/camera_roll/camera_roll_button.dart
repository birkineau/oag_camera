import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';

class CameraRollButton extends StatelessWidget {
  static const kButtonSize = 56.0;

  const CameraRollButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraStateBloc = context.read<CameraStateBloc>();

    return BlocBuilder<CameraRollBloc, CameraRollState>(
      builder: (context, state) {
        final hasItemSelected = state.selectedIndex != null;

        final Widget child;

        if (hasItemSelected) {
          final item = state.items[state.selectedIndex!];

          child = BlocProvider.value(
            key: ValueKey("camera_roll_item_${item.timeStamp}"),
            value: cameraStateBloc,
            child: CameraItemPreview(scaleToFit: false, item: item),
          );
        } else {
          child = CameraOrientationRotator(
            key: ValueKey("camera_roll_button_${DateTime.now()}"),
            child: const Icon(Icons.camera_roll_outlined, color: Colors.white),
          );
        }

        return Hero(
          tag: "${CameraScreenPage.heroCameraRollItem}_${state.selectedIndex}",
          child: GestureDetector(
            onTap: hasItemSelected ? () => openCameraRoll(context) : null,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  key: ValueKey(state.selectedIndex),
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                child: KeyedSubtree(
                  key: child.key,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum CameraRollMode {
  /// The camera roll will display a single camera item.
  single,

  /// The camera roll will display multiple items with a selector.
  multiple,
}

Future<void> openCameraRoll(
  BuildContext context, {
  CameraRollMode mode = CameraRollMode.multiple,
}) async {
  CameraRollPage.go(context);
  HapticFeedback.lightImpact();
}
