import 'dart:async';
import 'dart:developer';
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
    final overlay = BlocBuilder<CameraOverlayBloc, CameraOverlayState>(
      builder: (context, state) {
        final begin = state.showOverlay ? .0 : 1.0;
        final opacityTween = Tween(begin: begin, end: 1.0 - begin);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Opacity(
            opacity: opacityTween.evaluate(_curvedAnimation),
            child: child,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              state.placeholder ?? const SizedBox.shrink(),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final sigma = _blurTween.evaluate(_curvedAnimation);

                  return BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: sigma,
                      sigmaY: sigma,
                    ),
                    child: child,
                  );
                },
                child: const ColoredBox(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );

    return BlocSelector<CameraStateBloc, CameraState, CameraStatus>(
      selector: (state) => state.status,
      builder: (context, status) => IgnorePointer(
        ignoring: status == CameraStatus.ready,
        child: overlay,
      ),
    );
  }

  void _blurBlocListener(CameraOverlayState state) {
    _blurTween.begin = _blurTween.end;
    _blurTween.end = state.blur;
    _animationController.forward(from: .0);
  }
}
