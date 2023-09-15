import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_overlay_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';

class CameraScreenOverlay extends StatefulWidget {
  const CameraScreenOverlay({super.key});

  @override
  State<CameraScreenOverlay> createState() => CameraScreenOverlayState();
}

class CameraScreenOverlayState extends State<CameraScreenOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Tween<double> _blurTween;
  late final CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _blurTween = Tween<double>(begin: .0, end: .0);

    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuad,
      reverseCurve: Curves.easeOutQuad,
    );

    context.read<CameraOverlayBloc>().stream.listen(_blurBlocListener);
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
        child: Stack(
          children: [
            BlocBuilder<CameraOverlayBloc, CameraOverlayState>(
              builder: (context, state) => SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: state.placeholder ??
                    const ColoredBox(color: Colors.transparent),
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final sigma = _blurTween.evaluate(_curvedAnimation);

                return BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: child,
                );
              },
              child: const SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ColoredBox(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _blurBlocListener(CameraOverlayState state) {
    _blurTween.end = state.blur;

    state.showOverlay
        ? _animationController.forward()
        : _animationController.reverse();
  }
}
