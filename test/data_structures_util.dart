import 'dart:typed_data';
import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:bona2/DataStructures/receipt.dart';
import 'package:bona2/DataStructures/shopping_item.dart';

// TODO: there might be a better way to provide these functions to tests

final Uint8List uuid = Uint8List.fromList(
    [121, 127, 240, 67, 17, 235, 17, 225, 128, 214, 81, 9, 152, 117, 93, 16]);
final ShoppingItem shoppingItem = ShoppingItem(itemName: "Nothing");


ReceiptItem createReceiptItem({String? rawText}) {
  return ReceiptItem(
      shoppingItem: shoppingItem, rawText: rawText, totalPrice: 0.49, uuid: uuid, quantity: 500, unit: "g");
}


Receipt createReceiptSingleItem() {
  final ReceiptItem receiptItem = createReceiptItem();
  return Receipt(
      receiptItemsList: <ReceiptItem>[receiptItem],
      shopName: "shopName",
      dateTime: DateTime(1999, 1, 2, 13, 31, 20),
      totalPrice: 0.0,
      currency: "EUR",
      country: "Deutschland",
      city: "Berlin",
      address: "Axel-Springer-Straße 11, 10001 Berlin, Deutschland",
      postalCode: "10969",
      paymentType: "cash",
      uuid: uuid);
}

Receipt createReceiptEmpty() {
  return Receipt(
      receiptItemsList: const <ReceiptItem>[],
      shopName: "shopName",
      dateTime: DateTime(1999, 1, 2, 13, 31, 20),
      totalPrice: 0.0,
      currency: "EUR",
      country: "Deutschland",
      city: "Berlin",
      address: "Axel-Springer-Straße 11, 10001 Berlin, Deutschland",
      postalCode: "10969",
      uuid: uuid,
      paymentType: 'cash');
}
