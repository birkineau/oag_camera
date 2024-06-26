import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oag_camera/controller/controller.dart';
import 'package:oag_camera/model/model.dart';
import 'package:oag_camera/oag_camera.dart';

class CameraZoomIndicator extends StatelessWidget {
  const CameraZoomIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    const decoration = BoxDecoration(shape: BoxShape.circle);
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
        );

    final button = GestureDetector(
      onTap: () => context.read<CameraZoomBloc>().add(const ResetCameraZoom()),
      child: Container(
        padding: const EdgeInsets.all(3.0),
        margin: const EdgeInsets.all(6.0),
        decoration: decoration.copyWith(color: Colors.black54),
        alignment: Alignment.center,
        child: BlocBuilder<CameraZoomBloc, CameraZoom>(
          builder: (context, zoom) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AutoSizeText(
                  (((zoom.current - .5) * 10.0).round() / 10.0).toString(),
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
              const Icon(Icons.close, color: Colors.white, size: 12.0),
            ],
          ),
        ),
      ),
    );

    return CameraOrientationRotator(child: button);
  }
}
