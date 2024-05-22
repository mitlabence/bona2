import 'dart:typed_data';
import 'package:bona2/DataStructures/shopping_item.dart';
import 'package:bona2/constants.dart';

/// Contains an item with various properties.
class ReceiptItem {
  /// the text that was used to infer this item
  String? rawText; // Allow None if we do not intend to save raw string
  /// the shopping item containing
  ItemCategory itemCategory;
  num totalPrice;
  num? quantity;
  String? unit;
  String currency;
  final Uint8List
      uuid; // uuid should match uuid of Receipt containing this item

  ReceiptItem({
    required this.itemCategory,
    required this.rawText,
    required this.totalPrice,
    required this.quantity,
    required this.unit,
    required this.currency,
    required this.uuid,
  });

  @override
  String toString() {
    if (rawText != null) {
      return "$itemCategory: $totalPrice with raw text: $rawText";
    } else {
      return "$itemCategory: $totalPrice with no raw text";
    }
  }

  @override
  bool operator ==(Object other) {
    return (other is ReceiptItem) &&
        (itemCategory == other.itemCategory) &&
        (compareDouble(totalPrice.toDouble(), other.totalPrice.toDouble())) &&
        (currency == other.currency);
  }

  Map<String, dynamic> toMap() {
    return {
      'rawText': rawText ?? kNullStringValue,
      'shoppingItem': itemCategory.itemName,
      'totalPrice': totalPrice,
      'uuid': uuid,
      'currency': currency,
      'quantity': quantity ?? -1.0,
      'unit': unit ?? kNullStringValue,
    };
  }

  ReceiptItem.empty({Uint8List? uuid})
      : itemCategory = ItemCategory.empty(),
        rawText = "",  // do not use the "null string", but an empty text
        totalPrice = 0.0,
        quantity = 1,
        unit = kNullStringValue,
        currency = "EUR",
        uuid = uuid ?? Uint8List.fromList([]);

  // TODO: add isNotEmpty (also to ItemCategory)
  @override
  bool get isEmpty {
    if (!itemCategory.isEmpty) {
      return false;
    }
    if (rawText != null && rawText!.isNotEmpty) {
      return false;
    }
    if (totalPrice != 0.0) {
      return false;
    }
    if (unit != kNullStringValue) {
      return false;
    }
    if (uuid != null && uuid.isNotEmpty) {
      return false;
    }
    return true;
  }

  ReceiptItem.fromMap(Map<String, dynamic> map)
      : itemCategory = ItemCategory(itemName: map["shoppingitem"]),
        rawText = map["rawtext"] ?? kNullStringValue,
        // Allow None if we do not intend to save raw string
        totalPrice = map["totalprice"],
        quantity = map.containsKey("quantity") ? map["quantity"] : 1,
        unit = map.containsKey("unit") ? map["unit"] : kNullStringValue,
        currency = map.containsKey("currency") ? map["currency"] : "EUR",
        uuid = map["uuid"];

  /// Adding two receipt items does the following:
  /// 1. The raw Texts are added
  /// 2. The total price of the first receipt item is kept
  /// 3. The shopping item of the first receipt item is kept
  /// 4. The quantity of the first receipt item is kept
  /// 5. The unit of the first receipt item is kept
  /// 6. The uuid of the first receipt item is kept
  ReceiptItem operator +(ReceiptItem other) {
    return ReceiptItem(
      itemCategory: itemCategory + other.itemCategory,
      rawText:
          "${rawText ?? ''}$kReceiptItemAdditionSeparator${other.rawText ?? ''}",
      totalPrice: totalPrice,
      quantity: quantity,
      // TODO: in some cases, "other" might contain the quantity!
      unit: unit,
      currency: currency,
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
      itemCategory: itemCategory - other.itemCategory,
      rawText: resultRawText,
      totalPrice: totalPrice,
      quantity: quantity,
      currency: currency,
      unit: unit,
      uuid: uuid,
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
