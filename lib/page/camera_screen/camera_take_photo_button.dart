import 'dart:developer';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../controller/camera_state_bloc.dart';
import '../../model/camera_state.dart';
import '../../model/camera_status.dart';
import '../camera_application.dart';

class CameraTakePhotoButton extends StatefulWidget {
  const CameraTakePhotoButton({super.key});

  @override
  State<CameraTakePhotoButton> createState() => _CameraTakePhotoButtonState();
}

class _CameraTakePhotoButtonState extends State<CameraTakePhotoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  bool _isTakingPhoto = false;

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
    final button = Container(
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
    );

    return BlocSelector<CameraStateBloc, CameraState, bool>(
      selector: (state) => state.status == CameraStatus.ready,
      builder: (context, isReady) => IgnorePointer(
        ignoring: !isReady,
        child: GestureDetector(
          /// Prevent the user from taking photos when the camera controller is
          /// uninitialized and from taking multiple photos at the same time.
          onTapDown: _press,
          onTapUp: _takePhoto,
          onTapCancel: _depress,
          child: button,
        ),
      ),
    );
  }

  Future<void> _press(TapDownDetails details) async {
    await _animationController.forward();
    setState(() {});
  }

  Future<void> _depress() async {
    await _animationController.reverse();
    setState(() {});
  }

  /// Cutler Bay driver,
  /// at end of route,
  /// pick up at facility on patient,
  /// when drop-off at home => created drop-off at facility

  Future<void> _takePhoto(TapUpDetails details) async {
    final cameraRoll = context.read<CameraRollBloc>();

    if (cameraRoll.state.isFull) {
      final topPadding = math.max(8.0, MediaQuery.of(context).viewPadding.top);
      const duration = Duration(milliseconds: 2250);

      showOverlay(
        Offset(.0, topPadding),
        child: CameraSnackBar.error(
          key: UniqueKey(),
          height: 64.0,
          content: const AutoSizeText(
            "The camera roll is full.",
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        duration: duration,
      );

      return _depress();
    }

    final cameraController = context.read<CameraStateBloc>();

    try {
      setState(() => _isTakingPhoto = true);
      final photo = await cameraController.takePhoto();
      setState(() => _isTakingPhoto = false);

      if (photo == null) {
        if (!mounted) return;

        final topPadding = math.max(
          8.0,
          MediaQuery.of(context).viewPadding.top,
        );

        return showOverlay(
          Offset(.0, topPadding),
          child: const CameraSnackBar.error(
            height: 64.0,
            content: AutoSizeText(
              "ERROR: Unable to take photo.",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          duration: const Duration(milliseconds: 2250),
        );
      }

      cameraRoll.add(AddItemEvent(item: photo));
    } catch (e) {
      rethrow;
    } finally {
      await _depress();
    }
  }
}

class CameraSnackBar extends StatefulWidget {
  static const iconSize = 40.0;

  const CameraSnackBar({
    super.key,
    this.width,
    this.height,
    this.color = Colors.black,
    this.icon,
    required this.content,
  });

  const CameraSnackBar.warning({
    super.key,
    this.width,
    this.height,
    this.color = Colors.amber,
    required this.content,
  }) : icon = const Icon(
          Icons.warning_rounded,
          size: iconSize,
        );

  const CameraSnackBar.error({
    super.key,
    this.width,
    this.height,
    this.color = Colors.red,
    required this.content,
  }) : icon = const Icon(
          Icons.error_rounded,
          size: iconSize,
        );

  final double? width;
  final double? height;
  final Color? color;
  final Widget? icon;
  final Widget content;

  @override
  State<CameraSnackBar> createState() => _CameraSnackBarState();
}

class _CameraSnackBarState extends State<CameraSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  void animate({Duration? duration}) {
    if (duration != null) _animationController.duration = duration;
    _animationController.forward(from: .0);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    animate();

    final hasIcon = widget.icon != null;

    return Container(
      height: 72.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(1.0, 1.0),
            color: Colors.black12,
            spreadRadius: 1.5,
            blurRadius: 1.5,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: hasIcon
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IconTheme(
                          data: IconThemeData(color: widget.color),
                          child: widget.icon!,
                        ),
                        Expanded(child: Center(child: widget.content)),
                        const SizedBox(width: CameraSnackBar.iconSize),
                      ],
                    )
                  : widget.content,
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => LinearProgressIndicator(
              value: 1.0 - _animationController.value,
              backgroundColor: widget.color?.withOpacity(.33),
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
