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

const String kNullStringValue = "NULL";

//TODO: change to list of String database keys and datatypes (or Map), to assure consistency between production and test databases with one modification
const String kCreateReceiptItemDatabaseCommand =
    'CREATE TABLE ReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, currency TEXT, quantity REAL, unit TEXT, uuid BLOB)';
const String kReceiptItemDatabaseName =
    "ReceiptItems"; // should match with name defined in kCreateReceiptItemDatabaseCommand
enum ReceiptItemField {
  /// The columns of ReceiptItems database
  primaryKey,
  rawText,
  shoppingItem,
  totalPrice,
  currency,
  quantity,
  unit,
  uuid
}

String getReceiptItemColumnName(ReceiptItemField receiptItemField) {
  /// Given a [ReceiptItemField], return the field name in the ReceiptItems database.
  switch (receiptItemField) {
    case ReceiptItemField.primaryKey:
      return "pk";
    case ReceiptItemField.rawText:
      return "rawtext";
    case ReceiptItemField.shoppingItem:
      return "shoppingitem";
    case ReceiptItemField.totalPrice:
      return "totalprice";
    case ReceiptItemField.currency:
      return "currency";
    case ReceiptItemField.quantity:
      return "quantity";
    case ReceiptItemField.unit:
      return "unit";
    case ReceiptItemField.uuid:
      return "uuid";
    default:
      throw Exception("Unknown field $receiptItemField");
  }
}


const String kCreateReceiptDatabaseCommand =
    'CREATE TABLE Receipts (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, address TEXT, postalcode TEXT, city TEXT, paymenttype TEXT, uuid BLOB, datasource INT)';
const String kReceiptDatabaseName =
    "Receipts"; // should match with name defined in kCreateReceiptDatabaseCommand
enum ReceiptField {
  /// The columns of Receipts database
  primaryKey,
  shopName,
  dateTime,
  totalPrice,
  currency,
  country,
  address,
  postalCode,
  city,
  paymentType,
  uuid,
  dataSource,
}

String getReceiptColumnName(ReceiptField receiptField) {
  /// Given a [ReceiptField], get the corresponding SQL column name
  switch (receiptField) {
    case ReceiptField.primaryKey:
      return "pk";
    case ReceiptField.shopName:
      return "shopname";
    case ReceiptField.dateTime:
      return "datetime";
    case ReceiptField.totalPrice:
      return "totalprice";
    case ReceiptField.currency:
      return "currency";
    case ReceiptField.country:
      return "country";
    case ReceiptField.address:
      return "address";
    case ReceiptField.postalCode:
      return "postalcode";
    case ReceiptField.city:
      return "city";
    case ReceiptField.paymentType:
      return "paymenttype";
    case ReceiptField.uuid:
      return "uuid";
    case ReceiptField.dataSource:
      return "datasource";
    default:
      throw Exception("Unknown field $receiptField");
  }
}
enum SortingOrder {
  asc,
  desc
}
String getSortingOrder(SortingOrder order) {
  /// Given a [SortingOrder], return the corresponding SQL keyword for the sorting order
  switch (order){
    case SortingOrder.asc:
      return "ASC";
    case SortingOrder.desc:
      return "DESC";
    default:
      throw Exception("Unknown sorting order $order");
  }
}

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
  kNullStringValue
];

const List<String> kCurrenciesList = [
  "EUR",
  "USD",
  "HUF",
  "GBP",
  kNullStringValue,
];

enum EditStatus {
  unchanged,
  changed,
  deleted
}
