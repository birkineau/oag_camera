import 'dart:convert';

import 'package:flutter/material.dart';

String formatJson(Map<String, dynamic> json) =>
    const JsonEncoder.withIndent("\t").convert(json);

Future<T?> showDefaultModalBottomSheet<T>({
  required BuildContext context,
  EdgeInsets? padding,
  bool enableDrag = true,
  bool isDismissible = true,
  required Widget child,
}) {
  final bottomViewInset = MediaQuery.of(context).viewInsets.bottom;
  const defaultPadding = 10.0;
  const defaultRadius = Radius.circular(24.0);
  const borderRadius = BorderRadius.only(
    topLeft: defaultRadius,
    topRight: defaultRadius,
  );

  return showModalBottomSheet<T>(
    context: context,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    isScrollControlled: true,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: borderRadius),
    builder: (context) => SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enableDrag)
              SizedBox(
                width: double.infinity,
                height: 24.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: padding == null
                  ? EdgeInsets.only(
                      top: enableDrag ? .0 : defaultPadding,
                      bottom: defaultPadding + bottomViewInset,
                      left: defaultPadding,
                      right: defaultPadding,
                    )
                  : padding.copyWith(bottom: bottomViewInset + padding.bottom),
              child: child,
            ),
          ],
        ),
      ),
    ),
  );
}
