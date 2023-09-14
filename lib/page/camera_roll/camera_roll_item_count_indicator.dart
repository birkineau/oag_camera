import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../model/camera_roll_state.dart';
import '../../utility/string_extension.dart';

class CameraRollItemCountIndicator extends StatelessWidget {
  const CameraRollItemCountIndicator({
    super.key,
    required this.enableListeners,
    required this.height,
  });

  final bool enableListeners;
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
          child: enableListeners
              ? BlocBuilder<CameraRollBloc, CameraRollState>(
                  buildWhen: (previous, current) => _selectionChanged(
                    context,
                    previous,
                    current,
                  ),
                  builder: (context, state) => _Indicator(state: state),
                )
              : _Indicator(state: context.read<CameraRollBloc>().state),
        ),
      ),
    );
  }

  bool _selectionChanged(
    BuildContext context,
    CameraRollState previous,
    CameraRollState current,
  ) {
    final previousItem = previous.selectedIndex != null
        ? previous.items[previous.selectedIndex!]
        : null;

    final currentItem = current.selectedIndex != null
        ? current.items[current.selectedIndex!]
        : null;

    return previousItem != currentItem;
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.state,
  });

  final CameraRollState state;

  @override
  Widget build(BuildContext context) {
    if (state.selectedIndex == null) return const SizedBox.shrink();

    return Text(
      "${state.selectedIndex! + 1} / ${state.length}",
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
    );
  }
}
