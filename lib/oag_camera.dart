library oag_camera;

export 'package:camera/camera.dart' show CameraLensDirection;
export 'model/camera_configuration.dart';
export 'model/camera_item.dart';
export 'model/camera_item_type.dart';
export 'page/camera_roll/camera_roll.dart';
export 'page/camera_screen/camera_screen.dart';
export 'app/app.dart'
    hide di, navigatorInstanceKey, registerDependency, unregisterDependency;
