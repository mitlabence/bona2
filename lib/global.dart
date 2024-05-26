library bona2.globals;

import 'package:camera/camera.dart';
late String OcrApiKey;
late CameraDescription cameraDescription;
late String firebaseUid;
late String googleMapAPIKey;
late final String firebaseAppCheckToken; // https://firebase.google.com/docs/app-check/flutter/default-providers
late final String gDefaultCurrency;  // TODO: set currency based on location? Or ask user on first start
late final String gDefaultQuantity;