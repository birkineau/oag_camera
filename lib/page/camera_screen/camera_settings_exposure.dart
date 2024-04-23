import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';
import 'package:oag_camera/utility/utility.dart';

typedef _ExposureBuilder
    = BlocConsumer<CameraSettingsBloc, CameraSettingsState>;

class CameraSettingsExposure extends StatelessWidget {
  const CameraSettingsExposure({super.key});

  @override
  Widget build(BuildContext context) {
    const axis = Axis.vertical;
    final selectorKey = GlobalKey<CenterItemSelectorState>();

    final selector = AxisFade(
      axis: axis,
      child: LayoutBuilder(
        builder: (context, constraints) => _ExposureBuilder(
          listenWhen: _exposureOffsetChanged,
          listener: (context, state) {
            final index = state.exposure.range.indexOf(state.exposure.value);
            selectorKey.currentState?.selectItemAt(index);
          },
          buildWhen: _rangeChanged,
          builder: (context, state) => CenterItemSelector(
            key: selectorKey,
            scrollConfiguration: const SnapScrollPhysicsConfiguration(
              minPages: .0,
              maxPages: 8.0,
              velocityDivisor: 100,
            ),
            scrollDirection: axis,
            extent: constraints.maxHeight,
            reverse: true,
            itemSize: 14.0,
            items: state.exposure.range,
            initialIndex: state.exposure.range.indexOf(state.exposure.value),
            onItemSelected: (index) => _setExposure(
              context,
              state.exposure.range[index],
            ),
            itemBuilder: (context, index, isSelected) => Container(
              height: 4.0,
              margin: EdgeInsets.only(
                top: 5.75,
                bottom: 5.75,
                left: index % 4 == 0 ? .0 : 2.5,
                right: .0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.amber
                    : index % 4 == 0
                        ? Colors.grey[350]
                        : Colors.grey.shade500,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );

    const buttonWidth = 40.0;
    const buttonHeight = 32.0;
    const edgeSpacing = SizedBox(height: 4.0);
    const radius = Radius.circular(8.0);
    const tickRadius = Radius.circular(4.0);

    final dial = Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: _SetExposureButton(
              onPressed: () => _incrementExposure(selectorKey),
              child: const Icon(Icons.add_circle, color: Colors.white),
            ),
          ),
          edgeSpacing,
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: SizedBox(
                    width: buttonHeight,
                    child: selector,
                  ),
                ),
                const Positioned(
                  left: .0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: tickRadius,
                      bottomRight: tickRadius,
                    ),
                    child: SizedBox(
                      width: 6.0,
                      height: 6.0,
                      child: ColoredBox(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          edgeSpacing,
          SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: _SetExposureButton(
              onPressed: () => _decrementExposure(selectorKey),
              child: const Icon(Icons.remove_circle, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return CameraSettingsVisibility(
      duration: const Duration(milliseconds: 500),
      axis: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48.0,
            height: 56.0,
            child: _CameraExposureIndicator(),
          ),
          dial,
        ],
      ),
    );
  }

  bool _rangeChanged(
    CameraSettingsState previous,
    CameraSettingsState current,
  ) {
    return previous.exposure.range != current.exposure.range;
  }

  bool _exposureOffsetChanged(
    CameraSettingsState previous,
    CameraSettingsState current,
  ) {
    return previous.exposure.value != current.exposure.value;
  }

  void _setExposure(BuildContext context, double exposure) {
    HapticFeedback.selectionClick();

    context.read<CameraSettingsBloc>().add(
          CameraSetExposureEvent(exposure: exposure),
        );
  }

  Future<void> _incrementExposure(
    GlobalKey<CenterItemSelectorState> selectorKey,
  ) {
    final selectorState = selectorKey.currentState;
    if (selectorState == null) {
      return Future.value();
    }

    return selectorState.selectNextItem();
  }

  Future<void> _decrementExposure(
    GlobalKey<CenterItemSelectorState> selectorKey,
  ) {
    final selectorState = selectorKey.currentState;
    if (selectorState == null) {
      return Future.value();
    }

    return selectorState.selectPreviousItem();
  }
}

class _SetExposureButton extends StatefulWidget {
  const _SetExposureButton({
    this.onPressed,
    required this.child,
  });

  final Future<void> Function()? onPressed;
  final Widget child;

  @override
  State<_SetExposureButton> createState() => _SetExposureButtonState();
}

class _SetExposureButtonState extends State<_SetExposureButton> {
  Future<void>? _operation;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(.0),
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: CameraOrientationRotator(child: widget.child),
    );
  }

  void _onPressed() async {
    if (_operation != null) {
      await _operation;
    }

    _operation = widget.onPressed?.call();
  }
}

class _CameraExposureIndicator extends StatefulWidget {
  const _CameraExposureIndicator();

  @override
  State<_CameraExposureIndicator> createState() =>
      _CameraExposureIndicatorState();
}

class _CameraExposureIndicatorState extends State<_CameraExposureIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

  late final Map<double, double> _rangeMap;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final exposure = context.read<CameraSettingsBloc>().state.exposure;

    final mappedRange = mapRange(
      sourceStart: exposure.minimum,
      sourceEnd: exposure.maximum,
      sourceStep: exposure.step,
      targetStart: -2.0,
      targetEnd: 2.0,
    ).range;

    assert(
      exposure.range.length == mappedRange.length,
      "The mapped range length does not match the source range.",
    );

    _rangeMap = {
      for (var i = 0; i != exposure.range.length; ++i)
        exposure.range[i]: mappedRange[i],
    };

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacityAnimation = Tween(begin: .0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(16.0);

    final indicator = Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
      ),
      alignment: Alignment.center,
      child: BlocConsumer<CameraSettingsBloc, CameraSettingsState>(
        listenWhen: _exposureValueChanged,
        listener: (context, state) {
          if (!_animationController.isCompleted) {
            _animationController.forward();
          }

          _timer?.cancel();
          _timer = Timer(
            const Duration(milliseconds: 1500),
            () => _animationController.reverse(),
          );
        },
        buildWhen: _exposureValueChanged,
        builder: (context, state) {
          var value = roundToDecimal(_rangeMap[state.exposure.value] ?? .0, 1);

          return CameraOrientationRotator(
            child: Text(
              value.toString(),
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          );
        },
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: indicator,
        );
      },
    );
  }

  bool _exposureValueChanged(
    CameraSettingsState previous,
    CameraSettingsState current,
  ) {
    return previous.exposure.value != current.exposure.value;
  }
}
