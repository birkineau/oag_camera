import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_roll_state.dart';
import '../camera_application.dart';
import '../camera_screen/camera_orientation_rotator.dart';
import 'camera_item_preview.dart';
import 'camera_roll_page.dart';

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
          tag: "${CameraApplication.heroCameraRollItem}_${state.selectedIndex}",
          child: GestureDetector(
            onTap: hasItemSelected ? () => _openCameraRoll(context) : null,
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

  void _openCameraRoll(BuildContext context) {
    const duration = Duration(milliseconds: 500);
    final cameraStateBloc = context.read<CameraStateBloc>();
    final cameraRollBloc = context.read<CameraRollBloc>();

    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (_, animation, ___) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cameraRollBloc),
            BlocProvider.value(value: cameraStateBloc),
          ],
          child: const CameraRollPage(),
        ),
      ),
    );
  }
}
