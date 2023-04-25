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

//TODO: change to list of String database keys and datatypes (or Map), to assure consistency between production and test databases with one modification
const String kCreateReceiptItemDatabaseCommand =
    'CREATE TABLE ReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, quantity REAL, unit TEXT, uuid BLOB)';
const String kReceiptItemDatabaseName =
    "ReceiptItems"; // should match with name defined in kCreateReceiptItemDatabaseCommand
const String kCreateReceiptDatabaseCommand =
    'CREATE TABLE Receipts (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, address TEXT, postalcode TEXT, city TEXT, paymenttype TEXT, uuid BLOB)';
const String kReceiptDatabaseName =
    "Receipts"; // should match with name defined in kCreateReceiptDatabaseCommand

const String kCreateTestReceiptItemDatabaseCommand =
    'CREATE TABLE testReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, quantity REAL, unit TEXT, uuid BLOB)';
const String kTestReceiptItemDatabaseName =
    "testReceiptItems"; // Has to match with table name in creation command

const String kCreateTestReceiptDatabaseCommand =
    'CREATE TABLE testReceipts (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, address TEXT, postalcode TEXT, city TEXT, paymenttype TEXT, uuid BLOB)';
const String kTestReceiptDatabaseName =
    "testReceipts"; // Has to match with table name in creation command

const String kDatabaseName = "bona2.db";
const String kChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String kLowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
const String kUpperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

// when adding two ReceiptItem objects, put this separator between them.
const String kReceiptItemAdditionSeparator = "\n";
