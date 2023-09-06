import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_blur_bloc.dart';
import '../../controller/camera_roll_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_item.dart';
import '../../model/camera_roll_state.dart';
import '../camera_roll/camera_item_widget.dart';
import 'camera_live_preview.dart';
import 'camera_live_preview_placeholder.dart';
import 'camera_screen_blur.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blurBloc = context.read<CameraBlurBloc>();

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraLivePreview(
          key: blurBloc.livePreviewKey,
          maxZoom: 5.5,
          placeholder: const CameraLivePreviewPlaceholder(),
        ),

        /// Animates the deletion of the last item in the camera roll.
        const _DeletedCameraItemAnimation(),

        /// Blurs the camera screen when switching lens direction.
        CameraScreenBlur(key: blurBloc.blurKey),
      ],
    );
  }
}

class _DeletedCameraItemAnimation extends StatefulWidget {
  const _DeletedCameraItemAnimation();

  @override
  State<_DeletedCameraItemAnimation> createState() =>
      _DeletedCameraItemAnimationState();
}

class _DeletedCameraItemAnimationState
    extends State<_DeletedCameraItemAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  CameraItem? _deletedItem;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    _scaleAnimation = Tween(begin: 1.0, end: .33).animate(curvedAnimation);
    _opacityAnimation = Tween(begin: 1.0, end: .0).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (_deletedItem == null) {
      child = const SizedBox.shrink();
    } else {
      child = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        ),
        child: ColoredBox(
          color: Colors.black,
          child: OrientatedCameraItemWidget(
            orientation: context.read<CameraStateBloc>().state.orientation,
            item: _deletedItem!,
          ),
        ),
      );
    }

    return IgnorePointer(
      child: BlocListener<CameraRollBloc, CameraRollState>(
        listener: (context, state) async {
          if (state is! CameraRollDeletedItemState || !state.isEmpty) {
            return;
          }

          setState(() => _deletedItem = state.deletedItem);

          await _animationController.forward(from: .0);

          if (mounted) {
            setState(() => _deletedItem = null);
          }
        },
        child: child,
      ),
    );
  }
}
