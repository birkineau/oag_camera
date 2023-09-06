import 'package:flutter/material.dart';

extension StringExtension on String {
  Size intrinsicSize({
    BuildContext? context,
    double maxWidth = double.infinity,
    int? maxLines,
    TextStyle? style,
  }) {
    final double textScaleFactor;
    final TextDirection textDirection;

    if (context == null) {
      textScaleFactor = 1.0;
      textDirection = TextDirection.ltr;
    } else {
      textScaleFactor = MediaQuery.of(context).textScaleFactor;
      textDirection = Directionality.of(context);
    }

    return (TextPainter(
      text: TextSpan(text: this, style: style),
      textScaleFactor: textScaleFactor,
      textDirection: textDirection,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth))
        .size;
  }
}
