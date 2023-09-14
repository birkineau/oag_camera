import 'package:flutter/material.dart';

import '../../utility/string_extension.dart';

class CameraLivePreviewPlaceholder extends StatelessWidget {
  const CameraLivePreviewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    const message = "Camera not ready";
    final messageStyle = Theme.of(context).textTheme.headlineSmall;
    const imagePath = "packages/oag_camera/lib/assets/images/"
        "camera_status_not_ready.png";

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spaceBetween = 16.0;
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
                    width: messageSize.width * 1.25,
                    child: Image(
                      image: const AssetImage(imagePath),
                      color: Colors.grey.shade300,
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
