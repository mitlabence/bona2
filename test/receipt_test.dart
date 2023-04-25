import 'data_structures_util.dart';
import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:bona2/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bona2/DataStructures/receipt.dart';

void main() {
  group("test receipt creation functions for testing", () {
    test("test receipt creation functions for testing", (){
      final ReceiptItem receiptItem1 = createReceiptItem(rawText: "item1");
      final ReceiptItem receiptItem2 = createReceiptItem(rawText: "item2");
      assert(receiptItem1.rawText == "item1");
      assert(receiptItem2.rawText == "item2");
    });
  });

  group("test getNumberItems", () {
    test("test getNumberItems for empty Receipt", () {
      final Receipt emptyReceipt = createReceiptEmpty();
      expect(emptyReceipt.numberOfItems, 0);
    });
    test("test getNumberItems for Receipt with 1 element", () {
      final Receipt receipt = createReceiptSingleItem();
      expect(receipt.numberOfItems, 1);
    });
  });

  group("test ReceiptItem equality operator", () {
    test("test ReceiptItem equality operator", () {
      final ReceiptItem receiptItem1 = createReceiptItem();
      final ReceiptItem receiptItem2 = createReceiptItem();
      assert(receiptItem1 == receiptItem2);
    });
  });

  group("test ReceiptItem + operator", () {
    test("test ReceiptItem + operator", () {
      final ReceiptItem receiptItem1 = createReceiptItem(rawText: "item1");
      final ReceiptItem receiptItem2 = createReceiptItem(rawText: "item2");
      final ReceiptItem receiptItem3 =
          receiptItem1 + receiptItem2; // TODO: add these in setUp()
      assert(receiptItem1.rawText == "item1");
      assert(receiptItem2.rawText == "item2");
      assert(receiptItem3.rawText == "item1${kReceiptItemAdditionSeparator}item2");
    });
  });

  group("test ReceiptItem - operator", () {
    test("test ReceiptItem - operator", () {
      final ReceiptItem receiptItem1 = createReceiptItem(rawText: "item1");
      final ReceiptItem receiptItem2 = createReceiptItem(rawText: "item2");
      // simulate two receiptItems added
      final ReceiptItem receiptItem3 =
          createReceiptItem(rawText: "item1${kReceiptItemAdditionSeparator}item2");
      final ReceiptItem receiptItem4 = receiptItem3 - receiptItem2;
      assert(receiptItem4.rawText == receiptItem1.rawText);
    });
  });

  /// The following groups test toMap(), essential for saving receipts and items
  /// to SQLite database
  group("test ReceiptItem toMap()", () {
    test("test ReceiptItem toMap() with null rawText", () {
      final ReceiptItem receiptItem = createReceiptItem();
      final Map<String, dynamic> map = receiptItem.toMap();
      expect(map['rawText'],
          kNullStringValue); // if rawText is null, check default value
      expect(map['uuid'], receiptItem.uuid);
      // ShoppingItem cannot be written directly to SQL, save its itemName
      expect(map['shoppingItem'], shoppingItem.itemName);
      expect(map['totalPrice'], receiptItem.totalPrice);
    });
  });
  group("test Receipt toMap()", () {
    test("test Receipt toMap() with single ReceiptItem", () {
      final Receipt receipt = createReceiptSingleItem();
      final Map<String, dynamic> map = receipt.toMap();
      expect(map['receiptItemsList'], receipt.receiptItemsList);
      expect(map['shopName'], receipt.shopName);
      expect(map['dateTime'], receipt.dateTime.millisecondsSinceEpoch);
      expect(map['totalPrice'], receipt.totalPrice);
      expect(map['currency'], receipt.currency);
      expect(map['country'], receipt.country);
      expect(map['city'], receipt.city);
      expect(map['postalCode'], receipt.postalCode);
      expect(map['address'], receipt.address);
      expect(map['uuid'], receipt.uuid);
    });
    test("test Receipt toMap() with single ReceiptItem", () {
      final Receipt receipt = createReceiptEmpty();
      final Map<String, dynamic> map = receipt.toMap();
      expect(map['receiptItemsList'], receipt.receiptItemsList);
      expect(map['shopName'], receipt.shopName);
      expect(map['dateTime'], receipt.dateTime.millisecondsSinceEpoch);
      expect(map['totalPrice'], receipt.totalPrice);
      expect(map['currency'], receipt.currency);
      expect(map['country'], receipt.country);
      expect(map['city'], receipt.city);
      expect(map['postalCode'], receipt.postalCode);
      expect(map['address'], receipt.address);
      expect(map['uuid'], receipt.uuid);
    });
  });

  /// Test equality operators
  group("test Receipt equality operator", () {
    test("test equality of empty Receipt objects", () {
      final Receipt emptyReceipt1 = createReceiptEmpty();
      final Receipt emptyReceipt2 = createReceiptEmpty();
      assert(emptyReceipt1 == emptyReceipt2);
    });
    test("test equality of Receipt objects with 1 element", () {
      final Receipt receipt1 = createReceiptSingleItem();
      final Receipt receipt2 = createReceiptSingleItem();
      assert(receipt1 == receipt2);
    });
  });

  /// Test addition operator
  group("test Receipt + operator", () {
    // TODO: implement tests! + and - defined for ReceiptItem and ShoppingItem
    assert(1 == 1);
  });

  /// Test subtraction operator
  group("test Receipt - operator", () {
    assert(1 == 1);
  });

  /// Test getters and setters
  group("test Receipt getters and setters", () {
    assert(1 == 1);
  });
}
