import 'package:camera/camera.dart';

class Global {
  static final Global _mlapi = Global._internal();

  factory Global() {
    return _mlapi;
  }

  Global._internal();

  static CameraDescription? cameraDescription;
}