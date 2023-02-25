import "dart:typed_data";

import "receipt-item.dart";

class Receipt {
  final List<ReceiptItem> receiptItemsList;
  final String shopName;
  final DateTime dateTime;
  final double totalPrice;
  final String currency;
  final String country;
  final String street;
  final String postalCode;
  final String city;
  final Uint8List uuid;

  Receipt(
      {required this.receiptItemsList,
      required this.shopName,
      required this.dateTime,
      required this.totalPrice,
      required this.currency,
      required this.country,
      required this.city,
      required this.street,
      required this.postalCode,
      required this.uuid});

  int get numberOfItems => receiptItemsList.length;

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
      'street': street,
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
      'street': street,
      'uuid': uuid, // keep it as blob (Uint8List) for SQLite
    };
  }
}
