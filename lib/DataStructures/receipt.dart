import "dart:typed_data";

import "package:bona2/DataStructures/shopping-item.dart";

import "receipt-item.dart";

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
  final Uint8List uuid;

  Receipt({required this.receiptItemsList,
    required this.shopName,
    required this.dateTime,
    required this.totalPrice,
    required this.currency,
    required this.country,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.paymentType,
    required this.uuid});

  int get numberOfItems => receiptItemsList.length;

  @override
  String toString() {
    String itemsWithPrices = "";
    for (int i = 0; i < receiptItemsList.length; ++i) {
      itemsWithPrices +=
      "${receiptItemsList[i].shoppingItem.itemName}: ${receiptItemsList[i]
          .totalPrice}, ";
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
      'uuid': uuid, // keep it as blob (Uint8List) for SQLite
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) =>
      Receipt(
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
