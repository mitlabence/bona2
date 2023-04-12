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

const String kCreateReceiptItemDatabaseCommand = 'CREATE TABLE ReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, quantity REAL, unit TEXT, uuid BLOB)';
const String kTestReceiptItemDatabaseName = "ReceiptItems"; // should match with name defined in kCreateReceiptItemDatabaseCommand
const String kCreateReceiptDatabaseCommand = 'CREATE TABLE Receipts (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, street TEXT, postalcode TEXT, city TEXT, uuid BLOB)';
const String kTestReceiptDatabaseName = "Receipts"; // should match with name defined in kCreateReceiptDatabaseCommand

const String kDatabaseName = "bona2.db";
const String kChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String kLowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
const String kUpperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
