import 'package:flutter/widgets.dart';

/// A widget that detects a double tap gesture.
///
/// The [DoubleTapDetector] widget listens for a double tap gesture and calls
/// the [onDoubleTap] callback when two taps occur within the [timeout]
/// duration.
///
/// Important: When [GestureDetector.onTap] is used along with
/// [GestureDetector.onDoubleTap], there is a hardcoded delay before the single
/// tap is recognized. This widget allows for a more immediate response to a
/// single tap, while still allowing for a double tap gesture.
class DoubleTapDetector extends StatefulWidget {
  const DoubleTapDetector({
    super.key,
    required this.onDoubleTap,
    this.timeout = const Duration(milliseconds: 300),
    this.behavior = HitTestBehavior.opaque,
    required this.child,
  });

  /// Duration for which the detector will wait for a second tap before
  /// discarding the first tap.
  final Duration timeout;

  /// Callback to be called when a two taps occur within the [timeout] duration.
  final VoidCallback? onDoubleTap;

  /// See [GestureDetector.behavior].
  final HitTestBehavior behavior;

  /// The widget used to receive the double tap gesture.
  final Widget child;

  @override
  State<DoubleTapDetector> createState() => _DoubleTapDetectorState();
}

class _DoubleTapDetectorState extends State<DoubleTapDetector> {
  /// The time of the last tap.
  DateTime? _lastTap;

  @override
  Widget build(BuildContext context) {
    final onDoubleTap = widget.onDoubleTap;

    /// There's no need for gesture detection if the callback is null, so just
    /// return the child widget.
    if (onDoubleTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (details) {
        final now = DateTime.now();

        if (_lastTap == null) {
          _lastTap = now;
          return;
        }

        final previousTap = _lastTap ?? now;
        _lastTap = now;

        /// The difference between the current tap and the previous tap is
        /// greater than the timeout duration, so the current double tap is
        /// discarded.
        if (now.difference(previousTap) >= widget.timeout) {
          return;
        }

        _lastTap = null;
        onDoubleTap();
      },
      child: widget.child,
    );
  }
}
