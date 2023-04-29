import 'package:bona2/camera_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bona2/constants.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
  });
  group("getCamera", () {
    // test("get back-facing camera using getCamera", () async {
    //   final CameraDescription cameraDescription =
    //       await getCamera(kBackCameraLens);
    //   expect(cameraDescription.lensDirection, CameraLensDirection.back);
    // });
  });
}
