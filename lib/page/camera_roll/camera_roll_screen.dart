import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/app/app.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';
import 'package:oag_camera/utility/utility.dart';

class CameraRollScreen extends StatefulWidget {
  const CameraRollScreen({
    super.key,
    this.backgroundColor = Colors.black,
  });

  final Color backgroundColor;

  @override
  State<CameraRollScreen> createState() => _CameraRollScreenState();
}

class _CameraRollScreenState extends State<CameraRollScreen>
    with SingleTickerProviderStateMixin {
  static const _minScale = 1.0;
  static const _maxScale = 6.0;

  late final AnimationController _animationController;
  late final Matrix4Tween _transformationTween;
  late final CurvedAnimation _transformationCurve;

  late PageController _pageController;
  final _transformationController = TransformationController();

  var _scale = _minScale;
  var _listenForPageChange = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(
        () => _transformationController.value =
            _transformationTween.evaluate(_transformationCurve),
      );

    _transformationCurve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuad,
    );

    _transformationTween = Matrix4Tween(begin: null, end: Matrix4.identity());
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _pageController = PageController(
      initialPage: context.read<CameraRollBloc>().state.selectedIndex ?? 0,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraStateBloc = context.read<CameraStateBloc>();
    final isZoomedIn = _scale > _minScale;

    final child = CameraOrientationBuilder(
      bloc: context.read<CameraStateBloc>(),
      builder: (context, orientation) {
        final scrollDirection = switch (orientation) {
          DeviceOrientation.portraitUp ||
          DeviceOrientation.portraitDown =>
            Axis.horizontal,
          DeviceOrientation.landscapeLeft ||
          DeviceOrientation.landscapeRight =>
            Axis.vertical,
        };

        /// Camera item page view.
        return IgnorePointer(
          ignoring: isZoomedIn,
          child: BlocConsumer<CameraRollBloc, CameraRollState>(
            listenWhen: _selectionChanged,
            listener: _jumpToSelection,
            builder: (context, state) => PageView.builder(
              controller: _pageController,
              scrollDirection: scrollDirection,
              onPageChanged: _onPageChanged,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                final isSelected = state.selectedIndex == index;

                final child = Container(
                  key: ValueKey("camera_item_${item.timeStamp}"),
                  decoration: BoxDecoration(color: widget.backgroundColor),
                  clipBehavior: Clip.hardEdge,
                  child: BlocProvider.value(
                    value: cameraStateBloc,
                    child: CameraItemPreview(item: item),
                  ),
                );

                if (isSelected) {
                  return Hero(
                    tag: "${CameraScreenPage.heroCameraRollItem}_"
                        "${state.selectedIndex}",
                    createRectTween: _deceleratedRectTween,
                    flightShuttleBuilder: _itemPreviewScaleOutShuttleBuilder,
                    child: child,
                  );
                }

                return child;
              },
            ),
          ),
        );
      },
    );

    final viewer = InteractiveViewer(
      transformationController: _transformationController,
      onInteractionEnd: _updateScale,
      minScale: _minScale,
      maxScale: _maxScale,
      clipBehavior: Clip.none,
      child: child,
    );

    return DoubleTapDetector(
      onDoubleTap: () => _handleItemPreviewDoubleTap(isZoomedIn),
      child: viewer,
    );
  }

  bool _selectionChanged(CameraRollState previous, CameraRollState current) {
    return current.selectedIndex != null &&
        previous.selectedIndex != current.selectedIndex;
  }

  void _jumpToSelection(BuildContext context, CameraRollState state) async {
    if (_pageController.position.isScrollingNotifier.value) return;

    _listenForPageChange = false;
    _pageController.jumpToPage(state.selectedIndex!);
    _listenForPageChange = true;
  }

  Future<void> _resetScale() async {
    _scale = _minScale;
    _transformationTween.begin = _transformationController.value;
    return _animationController.forward(from: .0);
  }

  Future<void> _handleItemPreviewDoubleTap(bool isZoomedIn) async {
    /// Reset the scale if the image is zoomed in.
    if (isZoomedIn) {
      await _resetScale();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    /// Close the camera roll if the image is not zoomed in.
    final configuration = di<CameraConfiguration>();
    if (configuration.cameraRollMode == CameraRollMode.single) {
      context.read<CameraRollBloc>().add(const DeleteSelectedItemEvent());
    }

    /// Unblur the screenshot view if
    if (context.read<CameraOverlayBloc>().state.isActive) {
      context.read<CameraOverlayBloc>().add(const UnblurScreenshotEvent());
    }

    Navigator.pop(context);
  }

  void _onPageChanged(int index) {
    if (!_listenForPageChange) return;
    context.read<CameraRollBloc>().add(SetSelectedItemEvent(index: index));
  }

  void _updateScale(ScaleEndDetails details) {
    setState(() {
      _scale = _transformationController.value.getMaxScaleOnAxis();
    });
  }
}

Tween<Rect?> _deceleratedRectTween(begin, end) {
  return CurvedRectTween(
    curve: Curves.decelerate,
    begin: begin,
    end: end,
  );
}

/// start from the scaled in, and scale out the image during the transition.
Widget _itemPreviewScaleOutShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final item = fromHeroContext.read<CameraRollBloc>().selectedItem;

  return Container(
    decoration: const BoxDecoration(color: Colors.black),
    clipBehavior: Clip.antiAlias,
    child: item == null
        ? fromHeroContext.widget
        : BlocProvider.value(
            value: fromHeroContext.read<CameraStateBloc>(),
            child: CameraItemPreview(
              scaleToFit: flightDirection == HeroFlightDirection.push,
              item: item,
            ),
          ),
  );
}
