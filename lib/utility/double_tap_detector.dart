import 'package:flutter/widgets.dart';

class DoubleTapDetector extends StatefulWidget {
  const DoubleTapDetector({
    super.key,
    required this.onDoubleTap,
    this.behavior = HitTestBehavior.opaque,
    required this.child,
  });

  final VoidCallback? onDoubleTap;
  final HitTestBehavior behavior;
  final Widget child;

  @override
  State<DoubleTapDetector> createState() => _DoubleTapDetectorState();
}

class _DoubleTapDetectorState extends State<DoubleTapDetector> {
  DateTime? _lastTap;

  @override
  Widget build(BuildContext context) {
    final onDoubleTap = widget.onDoubleTap;
    if (onDoubleTap == null) return widget.child;

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

        final difference = now.difference(previousTap);
        if (difference.inMilliseconds >= 300) return;
        _lastTap = null;

        onDoubleTap();
      },
      child: widget.child,
    );
  }
}
