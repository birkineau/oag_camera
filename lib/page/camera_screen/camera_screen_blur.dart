import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_blur_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';

class CameraScreenBlur extends StatefulWidget {
  const CameraScreenBlur({super.key});

  @override
  State<CameraScreenBlur> createState() => CameraScreenBlurState();
}

class CameraScreenBlurState extends State<CameraScreenBlur>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _blurSigmaAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _blurSigmaAnimation = Tween<double>(begin: .0, end: 16.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuad,
        reverseCurve: Curves.easeOutQuad,
      ),
    );

    context.read<CameraBlurBloc>().stream.listen(_blurBlocListener);
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
      builder: (context, status) => IgnorePointer(
        ignoring: status == CameraStatus.ready,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: _blurSigmaAnimation.value,
              sigmaY: _blurSigmaAnimation.value,
            ),
            child: child,
          ),
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ColoredBox(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  void _blurBlocListener(CameraBlurState state) => state.isBlurred
      ? _animationController.forward()
      : _animationController.reverse();
}
