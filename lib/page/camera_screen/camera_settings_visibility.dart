import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';

class CameraSettingsVisibility extends StatefulWidget {
  const CameraSettingsVisibility({
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.axis = Axis.vertical,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final Axis axis;
  final Widget child;

  @override
  State<CameraSettingsVisibility> createState() =>
      _CameraSettingsVisibilityState();
}

class _CameraSettingsVisibilityState extends State<CameraSettingsVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
      reverseCurve: widget.curve.flipped,
    );

    return BlocConsumer<CameraSettingsBloc, CameraSettingsState>(
      listenWhen: (previous, current) =>
          current.initialized && previous.visible != current.visible,
      listener: (context, state) => state.visible
          ? _animationController.forward()
          : _animationController.reverse(),
      buildWhen: (previous, current) =>
          previous.initialized != current.initialized,
      builder: (context, state) {
        if (state.initialized) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              axis: widget.axis,
              sizeFactor: animation,
              child: widget.child,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
