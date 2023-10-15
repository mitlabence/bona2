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
    'CREATE TABLE ReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, currency TEXT, quantity REAL, unit TEXT, uuid BLOB)';
const String kReceiptItemDatabaseName =
    "ReceiptItems"; // should match with name defined in kCreateReceiptItemDatabaseCommand
const String kCreateReceiptDatabaseCommand =
    'CREATE TABLE Receipts (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, address TEXT, postalcode TEXT, city TEXT, paymenttype TEXT, uuid BLOB, datasource INT)';
const String kReceiptDatabaseName =
    "Receipts"; // should match with name defined in kCreateReceiptDatabaseCommand

const String kCreateTestReceiptItemDatabaseCommand =
    'CREATE TABLE testReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, currency TEXT, quantity REAL, unit TEXT, uuid BLOB)';
const String kTestReceiptItemDatabaseName =
    "testReceiptItems"; // Has to match with table name in creation command

const String kCreateTestReceiptDatabaseCommand =
    'CREATE TABLE testReceipts (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, address TEXT, postalcode TEXT, city TEXT, paymenttype TEXT, uuid BLOB, datasource INT)';
const String kTestReceiptDatabaseName =
    "testReceipts"; // Has to match with table name in creation command

const String kDatabaseName = "bona2.db";
const String kChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String kLowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
const String kUpperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// To document the data source, assign the proper integer value (corresponding
/// to Taggun API) here. See Receipt.dataSource for documentation
const int kDataSourceTaggunNumber = 1; //

// when adding two ReceiptItem objects, put this separator between them.
const String kReceiptItemAdditionSeparator = "\n";

// uuid is 32 characters of hexadecimal digits, i.e. 16 unsigned int 8-bit integers
const int kUuidUint8ListLength = 16;

// Firestore-related constants
const String kFireStoreRootUsersCollection = "users";

const List<String> kReceiptItemUnitsList = [
  "g",
  "ml",
  "l",
  "piece",
  "bundle",
  "mg",
  "kg",
  "dl",
  "oz",
  "lb",
  "gal",
];

const List<String> kCurrenciesList = [
  "NaN",
  "EUR",
  "USD",
  "HUF",
  "GBP",
];

enum EditStatus {
  unchanged,
  changed,
  deleted
}
