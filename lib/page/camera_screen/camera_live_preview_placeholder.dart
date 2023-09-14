import 'package:flutter/material.dart';

import '../../utility/string_extension.dart';

class CameraLivePreviewPlaceholder extends StatelessWidget {
  const CameraLivePreviewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey.shade100;
    const message = "Camera not ready";
    final messageStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: color,
        );

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spaceBetween = 24.0;
            final messageSize = message.intrinsicSize(
              context: context,
              maxWidth: constraints.maxWidth,
              maxLines: 1,
              style: messageStyle,
            );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight -
                        messageSize.height -
                        spaceBetween,
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth * .66,
                    child: Image(
                      image: const AssetImage(
                        "packages/oag_camera/lib/assets/images/"
                        "camera_status_not_ready.png",
                      ),
                      color: color,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                const SizedBox(height: spaceBetween),
                Text(message, maxLines: 1, style: messageStyle),
              ],
            );
          },
        ),
      ),
    );
  }
}
