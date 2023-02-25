import 'dart:typed_data';

import 'package:bona2/DataStructures/shopping-item.dart';
import 'package:bona2/constants.dart';

class ReceiptItem {
  final String? rawText; // Allow None if we do not intend to save raw string
  final ShoppingItem shoppingItem;
  final double totalPrice;
  final Uint8List
      uuid; // uuid should match uuid of Receipt containing this item

  ReceiptItem(
      {required this.shoppingItem,
      required this.rawText,
      required this.totalPrice,
      required this.uuid});

  @override
  String toString() {
    if (rawText != null) {
      return "$shoppingItem: $totalPrice with raw text: $rawText";
    } else {
      return "$shoppingItem: $totalPrice with no raw text";
    }
  }

  @override
  bool operator ==(Object other) {
    return (other is ReceiptItem) &&
        (shoppingItem == other.shoppingItem) &&
        (compareDouble(totalPrice, other.totalPrice));
  }

  Map<String, dynamic> toMap() {
    return {
      'rawText': rawText ?? "NaN",
      'shoppingItem': shoppingItem.itemName,
      'totalPrice': totalPrice,
      'uuid': uuid,
    };
  }
}
