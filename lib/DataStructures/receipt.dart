import "dart:typed_data";

import "package:bona2/DataStructures/shopping_item.dart";
import "package:bona2/DataStructures/store_location.dart";
import "package:bona2/uuid_tools.dart";
import "package:uuid/uuid.dart";
import "package:uuid/uuid_util.dart";
import "package:bona2/constants.dart";

import "../global.dart";
import "receipt_item.dart";

class Receipt {
  List<ReceiptItem> receiptItemsList;
  String shopName;
  DateTime dateTime;
  double totalPrice;
  String currency;
  String country;
  String address;
  String postalCode;
  String city;
  String paymentType;
  String? placeId;

  /// 0 - NaN (use 0 value to fill data with no data source info),
  /// 1 - taggun API
  int dataSource; // i.e. the way the receipt was scanned
  late final Uint8List
      uuid; // leave option to either define uuid or let Receipt class assign one

  Receipt({
    required this.receiptItemsList,
    required this.shopName,
    required this.dateTime,
    required this.totalPrice,
    required this.currency,
    required this.country,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.paymentType,
    uuid,
    this.dataSource = 0,
    placeId, // Google Maps API place_id
  }) {
    this.uuid = uuid ?? generateUuidUint8List();
  }

  int get numberOfItems => receiptItemsList.length;

  num get detectedTotalPrice => numberOfItems == 0
      ? 0.0
      : receiptItemsList
          .map((receiptItem) => receiptItem.totalPrice)
          .reduce((a, b) => a + b);

  factory Receipt.empty() {
    /// Create a Receipt instance with
    ///   * String attributes having the empty string "",
    ///   * DateTime attributes DateTime.now(),
    ///   * double attributes 0.0,
    ///   * Uint8List attributes Uint8List(0)
    /// as values.
    return Receipt(
      receiptItemsList: [],
      shopName: kNullStringValue,
      dateTime: DateTime.now(),
      totalPrice: 0.0,
      currency: gDefaultCurrency,
      country: kNullStringValue,
      address: kNullStringValue,
      postalCode: kNullStringValue,
      city: kNullStringValue,
      paymentType: kNullStringValue,
      uuid: generateUuidUint8List(),  // As uuid should be final, needs to be created upon creation...
      placeId: kNullStringValue,
    );
  }

  @override
  String toString() {
    String itemsWithPrices = "";
    for (int i = 0; i < receiptItemsList.length; ++i) {
      itemsWithPrices +=
          "${receiptItemsList[i].itemCategory.itemName}: ${receiptItemsList[i].totalPrice}, ";
    }
    return "Date: $dateTime, Shop: $shopName: $itemsWithPrices"; //TODO: add uuid
  }

  @override
  bool operator ==(Object other) {
    // TODO: improve equality, as uuid might not be reliable, especially if manually created for this or other
    //  check number of items?
    //  check date and time?
    return (other is Receipt) && (uuid == other.uuid);
  }

  Map<String, dynamic> toMap() {
    return {
      'receiptItemsList': receiptItemsList,
      'shopName': shopName,
      'dateTime': dateTime.millisecondsSinceEpoch, // convert for SQLite
      'totalPrice': totalPrice,
      'currency': currency,
      'country': country,
      'city': city,
      'postalCode': postalCode,
      'address': address,
      'paymentType': paymentType,
      'uuid': uuid, // keep it as blob (Uint8List) for SQLite
      'dataSource': dataSource,
      'placeId': placeId ?? kNullStringValue,
    };
  }

  Map<String, dynamic> toMapJson() {
    return {
      'receiptItemsList': List.generate(
          receiptItemsList.length, (index) => receiptItemsList[index].toMap()),
      'shopName': shopName,
      'dateTime': dateTime.millisecondsSinceEpoch, // convert for SQLite
      'totalPrice': totalPrice,
      'currency': currency,
      'country': country,
      'city': city,
      'postalCode': postalCode,
      'address': address,
      'paymentType': paymentType,
      'uuid': uuid, // keep it as blob (Uint8List) for SQLite
      'dataSource': dataSource,
      'placeId': placeId ?? kNullStringValue,
    };
  }

  Map<String, dynamic> toMapSQL() {
    /// Returns map similar to toMap(), excluding receiptItemsList that is
    /// not SQL-compatible.
    return {
      'shopName': shopName,
      'dateTime': dateTime.millisecondsSinceEpoch, // convert for SQLite
      'totalPrice': totalPrice,
      'currency': currency,
      'country': country,
      'city': city,
      'postalCode': postalCode,
      'address': address,
      'paymentType': paymentType,
      'uuid': uuid, // keep it as blob (Uint8List) for SQLite
      'dataSource': dataSource,
      'placeId': placeId ?? kNullStringValue,
    };
  }

  /// Given a json-like map of a receipt object (NOT a scanned receipt object)
  /// with the proper keys, reconstruct the receipt object.
  /// WARNING: uuid (Uint8List) needs to be included in the map!
  /// If not present, use fromMapAndUuid()!
  /// Use ReceiptReader to convert scan results to a Receipt.
  // TODO: make tests, especially to receiptItemsList!
  factory Receipt.fromMap(Map<String, dynamic> mapWithUuid) => Receipt(
        receiptItemsList: mapWithUuid.containsKey("receiptItemsList")
            ? mapWithUuid["receiptItemsList"]
            : [
                ReceiptItem.empty(uuid:mapWithUuid["uuid"]),
              ],
        shopName: mapWithUuid["shopname"],
        dateTime: DateTime.fromMillisecondsSinceEpoch(mapWithUuid["datetime"]),
        totalPrice: mapWithUuid["totalprice"],
        currency: mapWithUuid["currency"],
        country: mapWithUuid["country"],
        city: mapWithUuid["city"],
        address: mapWithUuid["address"],
        postalCode: mapWithUuid["postalcode"],
        uuid: mapWithUuid["uuid"],
        paymentType: mapWithUuid["paymenttype"],
        dataSource: mapWithUuid.containsKey("dataSource")
            ? mapWithUuid["dataSource"]
            : 0,
        placeId: mapWithUuid.containsKey("placeId")
            ? mapWithUuid["placeId"]
            : kNullStringValue,
      );

  factory Receipt.fromMapAndUuid(Map<String, dynamic> map, Uint8List uuid) =>
      Receipt(
        receiptItemsList: [
          ReceiptItem(
              itemCategory: ItemCategory(
                itemName: "asd",
              ),
              rawText: 'asd',
              totalPrice: 1.0,
              currency: map["currency"],
              uuid: uuid,
              unit: "ml",
              quantity: 500)
        ],
        shopName: map["shopname"],
        dateTime: DateTime.fromMillisecondsSinceEpoch(map["datetime"]),
        totalPrice: map["totalprice"],
        currency: map["currency"],
        country: map["country"],
        city: map["city"],
        address: map["address"],
        postalCode: map["postalcode"],
        uuid: uuid,
        paymentType: map["paymenttype"],
        dataSource: map.containsKey("dataSource") ? map["dataSource"] : 0,
        placeId: map.containsKey("placeId") ? map["placeId"] : kNullStringValue,
      );

  void updateFromStoreLocation(StoreLocation storeLocation) {
    // TODO: decide what to do with null entries in storeLocation? Overwrite
    //  receipt fields?
    country = storeLocation.country;
    city = storeLocation.city;
    address = storeLocation.address;
    postalCode = storeLocation.postalCode ?? kNullStringValue;

    shopName = storeLocation.name; // The name of the store
    placeId = storeLocation.placeId ?? kNullStringValue;
  }
}
