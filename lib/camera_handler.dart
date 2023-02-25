import 'package:camera/camera.dart';


Future<CameraDescription> getCamera(CameraLensDirection camDirection) async {
  return await availableCameras().then(
        (List<CameraDescription> cameras) => cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == camDirection,
    ),
  );
}