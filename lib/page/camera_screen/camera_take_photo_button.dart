import 'dart:developer';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';

class CameraTakePhotoButton extends StatefulWidget {
  const CameraTakePhotoButton({super.key});

  @override
  State<CameraTakePhotoButton> createState() => _CameraTakePhotoButtonState();
}

class _CameraTakePhotoButtonState extends State<CameraTakePhotoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  final bool _isTakingPhoto = false;
  Future<void>? _tapDownAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    const beginScale = 1.0;
    const endScale = .875;

    _scaleAnimation = Tween(begin: beginScale, end: endScale).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
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
      builder: (context, status) => GestureDetector(
        /// Prevent the user from taking photos when the camera controller is
        /// uninitialized and from taking multiple photos at the same time.
        onTapDown:
            status == CameraStatus.ready && !_isTakingPhoto ? _press : null,
        onTapUp: _takePhoto,
        onTapCancel: _depress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.white, width: 3.0),
            shape: BoxShape.circle,
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: Container(
              margin: const EdgeInsets.all(3.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _press(TapDownDetails details) {
    _tapDownAnimation = _animationController.forward();
    setState(() {});
  }

  Future<void> _depress() async {
    await _animationController.reverse();
    setState(() => _tapDownAnimation = null);
  }

  /// Cutler Bay driver,
  /// at end of route,
  /// pick up at facility on patient,
  /// when drop-off at home => created drop-off at facility

  Future<void> _takePhoto(TapUpDetails details) async {
    final cameraRoll = context.read<CameraRollBloc>();

    /// TODO: Create my own snackbar implementation...
    if (cameraRoll.state.isFull) {
      showTopSnackBar(
        Overlay.of(context),
        const CameraSnackBar.error(
          content: AutoSizeText(
            "The camera roll is full.",
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        dismissType: DismissType.onSwipe,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastEaseInToSlowEaseOut,
        animationDuration: const Duration(milliseconds: 500),
        reverseAnimationDuration: const Duration(milliseconds: 400),
        displayDuration: const Duration(milliseconds: 2000),
      );

      return _depress();
    }

    final cameraController = context.read<CameraStateBloc>();

    try {
      final photo = await cameraController.takePhoto();

      if (photo == null) {
        throw Exception("Unable to take photo.");
      }

      cameraRoll.add(AddItemEvent(item: photo));
    } catch (e) {
      rethrow;
    } finally {
      await _depress();
    }
  }
}

class CameraSnackBar extends StatelessWidget {
  static const iconSize = 40.0;

  const CameraSnackBar({
    super.key,
    this.color = Colors.black,
    this.icon,
    required this.content,
  });

  const CameraSnackBar.warning({
    super.key,
    this.color = Colors.amber,
    this.content = const Text("An error occurred."),
  }) : icon = const Icon(
          Icons.warning_rounded,
          size: iconSize,
        );

  const CameraSnackBar.error({
    super.key,
    this.color = Colors.red,
    this.content = const Text("An error occurred."),
  }) : icon = const Icon(
          Icons.error_rounded,
          size: iconSize,
        );

  final Color? color;
  final Widget? icon;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasIcon = icon != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(top: 12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1.5,
              blurRadius: 1.5,
            ),
          ],
        ),
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: hasIcon
                  ? Row(
                      children: [
                        IconTheme(
                          data: IconThemeData(color: color),
                          child: icon!,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: content,
                          ),
                        ),
                        const SizedBox(width: iconSize),
                      ],
                    )
                  : content,
            ),
            const SizedBox(height: 8.0),
            _DurationLinearProgressIndicator(
              duration: const Duration(milliseconds: 2500),
              color: color ?? Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

/// A linear progress indicator with a duration as the progress indicator value.
class _DurationLinearProgressIndicator extends StatefulWidget {
  const _DurationLinearProgressIndicator({
    required this.duration,
    required this.color,
  });

  final Duration duration;
  final Color color;

  @override
  State<_DurationLinearProgressIndicator> createState() =>
      _DurationLinearProgressIndicatorState();
}

class _DurationLinearProgressIndicatorState
    extends State<_DurationLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.color.withOpacity(.33);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => LinearProgressIndicator(
        value: 1.0 - _animationController.value,
        backgroundColor: backgroundColor,
        color: widget.color,
      ),
    );
  }
}
