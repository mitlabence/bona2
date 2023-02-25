import 'package:camera/camera.dart';

const kBackCameraLens = CameraLensDirection.back;

// TODO: use dart_numerics package almostEqualNumbersBetween
const double kEpsilon =
    0.01; // let this epsilon be the smallest unit for checking double comparison, i.e. a == b if abs(a-b) < kEpsilon.
bool compareDouble(double a, double b) {
  /// Returns true if the two double values a and b are
  /// "almost equal" (up to a tolerance of kEpsilon), false otherwise.
  return (a - b).abs() < kEpsilon;
}

const String kNullStringValue = "NaN";

