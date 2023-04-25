import 'dart:ffi';
import 'dart:typed_data';
import 'package:bona2/DataStructures/shopping_item.dart';
import 'package:bona2/constants.dart';

/// Contains an item with various properties.
class ReceiptItem {
  /// the text that was used to infer this item
  final String? rawText; // Allow None if we do not intend to save raw string
  /// the shopping item containing
  final ShoppingItem shoppingItem;
  final num totalPrice;
  final num? quantity;
  final String? unit;
  final Uint8List
      uuid; // uuid should match uuid of Receipt containing this item

  ReceiptItem({
    required this.shoppingItem,
    required this.rawText,
    required this.totalPrice,
    required this.quantity,
    required this.unit,
    required this.uuid,
  });

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
        (compareDouble(totalPrice.toDouble(), other.totalPrice.toDouble()));
  }

  Map<String, dynamic> toMap() {
    return {
      'rawText': rawText ?? "NaN",
      'shoppingItem': shoppingItem.itemName,
      'totalPrice': totalPrice,
      'uuid': uuid,
      'quantity': quantity ?? -1.0,
      'unit': unit ?? "NaN",
    };
  }

  factory ReceiptItem.fromMap(Map<String, dynamic> map) => ReceiptItem(
        shoppingItem: ShoppingItem(itemName: map["shoppingitem"]),
        rawText: map["rawtext"] ?? "NaN",
        // Allow None if we do not intend to save raw string
        totalPrice: map["totalprice"],
        quantity: map["quantity"],
        unit: map["unit"] ?? "NaN",
        uuid: map["uuid"],
      );

  /// Adding two receipt items does the following:
  /// 1. The raw Texts are added
  /// 2. The total price of the first receipt item is kept
  /// 3. The shopping item of the first receipt item is kept
  /// 4. The quantity of the first receipt item is kept
  /// 5. The unit of the first receipt item is kept
  /// 6. The uuid of the first receipt item is kept
  ReceiptItem operator +(ReceiptItem other) {
    return ReceiptItem(
      shoppingItem: shoppingItem + other.shoppingItem,
      rawText:
          "${rawText ?? ''}$kReceiptItemAdditionSeparator${other.rawText ?? ''}",
      totalPrice: totalPrice,
      quantity: quantity,
      // TODO: in some cases, "other" might contain the quantity!
      unit: unit,
      uuid: uuid,
    );
  }

  /// Subtracting a ReceiptItem from another (a-b):
  /// 1. The raw Texts get removed (if b.rawText is in a.rawText)
  /// 2. The total price of a is kept
  /// 3. The shopping item of a is kept
  /// 4. The quantity of a is kept
  /// 5. The unit of a is kept
  /// 6. The uuid of a is kept
  ReceiptItem operator -(ReceiptItem other) {
    String? resultRawText = rawText;
    if (resultRawText != null) {
      if (other.rawText != null) {
        // First, only remove other rawText; need to handle addition separator after
        resultRawText = resultRawText.endsWith(other.rawText!)
            ? resultRawText.substring(
                0, resultRawText.length - other.rawText!.length)
            : resultRawText;
        if (resultRawText.endsWith(kReceiptItemAdditionSeparator)) {
          resultRawText = resultRawText.substring(
              0, resultRawText.length - kReceiptItemAdditionSeparator.length);
        }
      }
      // Else (if other.rawText is null): keep this.rawText intact
    } // Else (if this.rawText is null): keep it null

    return ReceiptItem(
      shoppingItem: shoppingItem - other.shoppingItem,
      rawText: resultRawText,
      totalPrice: totalPrice,
      quantity: quantity,
      unit: unit,
      uuid: uuid,
    );
  }
}
