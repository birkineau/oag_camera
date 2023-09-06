import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../model/camera_roll_state.dart';
import '../../utility/string_extension.dart';

class CameraRollItemCountIndicator extends StatelessWidget {
  const CameraRollItemCountIndicator({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final minWidth = "0 / 0"
        .intrinsicSize(
          context: context,
          maxLines: 1,
          style: const TextStyle(color: Colors.white),
        )
        .width;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: BlocBuilder<CameraRollBloc, CameraRollState>(
            buildWhen: _selectionChanged,
            builder: (context, state) {
              if (state.selectedIndex == null) {
                return const SizedBox.shrink();
              }

              return Text(
                "${state.selectedIndex! + 1} / ${state.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _selectionChanged(CameraRollState previous, CameraRollState current) {
    return current.selectedIndex != null &&
        previous.selectedIndex != current.selectedIndex;
  }
}
