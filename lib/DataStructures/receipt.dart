import "dart:typed_data";

import "package:bona2/DataStructures/shopping_item.dart";
import "package:bona2/uuid_tools.dart";
import "package:uuid/uuid.dart";
import "package:uuid/uuid_util.dart";

import "receipt_item.dart";

class Receipt {
  final List<ReceiptItem> receiptItemsList;
  final String shopName;
  final DateTime dateTime;
  final double totalPrice;
  final String currency;
  final String country;
  final String address;
  final String postalCode;
  final String city;
  final String paymentType;
  late final Uint8List uuid; // leave option to either define uuid or let Receipt class assign one

  Receipt(
      {required this.receiptItemsList,
      required this.shopName,
      required this.dateTime,
      required this.totalPrice,
      required this.currency,
      required this.country,
      required this.city,
      required this.address,
      required this.postalCode,
      required this.paymentType, uuid}) {
    this.uuid = uuid ?? generateUuidUint8List();
  }

  int get numberOfItems => receiptItemsList.length;

  num get detectedTotalPrice => receiptItemsList
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
      shopName: "",
      dateTime: DateTime.now(),
      totalPrice: 0.0,
      currency: "",
      country: "",
      address: "",
      postalCode: "",
      city: "",
      paymentType: "",
      uuid: Uint8List(0),
    );
  }

  @override
  String toString() {
    String itemsWithPrices = "";
    for (int i = 0; i < receiptItemsList.length; ++i) {
      itemsWithPrices +=
          "${receiptItemsList[i].shoppingItem.itemName}: ${receiptItemsList[i].totalPrice}, ";
    }
    return "Date: $dateTime, Shop: $shopName: $itemsWithPrices"; //TODO: add uuid
  }

  @override
  bool operator ==(Object other) {
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
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) => Receipt(
        receiptItemsList: [
          ReceiptItem(
              shoppingItem: ShoppingItem(
                itemName: "asd",
              ),
              rawText: 'asd',
              totalPrice: 1.0,
              uuid: map["uuid"],
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
        uuid: map["uuid"],
        paymentType: map["paymenttype"],
      );
}
