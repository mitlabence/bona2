import 'dart:math';
import 'dart:typed_data';

import 'package:bona2/DataStructures/receipt.dart';
import 'package:bona2/DataStructures/shopping_item.dart';
import 'package:bona2/constants.dart';
import 'package:uuid/uuid.dart';

import 'DataStructures/receipt_item.dart';
import 'package:uuid/uuid_util.dart';

class RandomReceiptGenerator {
  static final RandomReceiptGenerator _rrg = RandomReceiptGenerator._internal();

  factory RandomReceiptGenerator() {
    return _rrg;
  }

  RandomReceiptGenerator._internal();

  final Random rng = Random();
  final int seed = 42;
  final int maxReceiptLength = 21;
  final int maxItemRawTextLength = 20;
  final int maxItemNameLength = 10;
  final double maxTotalPrice = 30.0;

  String randomString(int length) {
    return List.generate(length,
        (index) => kLowerCaseChars[rng.nextInt(kLowerCaseChars.length)]).join();
  }

  Uint8List randomUUID() {
    UuidValue uuid = const Uuid().v4obj(options: {"rng": UuidUtil.cryptoRNG});
    return uuid.toBytes(); // Not cryptographically strong! Use cryptoRNG() for production code
  }

  ReceiptItem randomReceiptItem() {
    return ReceiptItem(
        itemCategory: ItemCategory(itemName: randomString(maxItemNameLength)),
        rawText: randomString(maxItemRawTextLength),
        //TODO: for future testing, adding whitespace (converting to using lorem ipsum, for example) might be useful
        totalPrice: rng.nextDouble() * maxTotalPrice,
        uuid: randomUUID(),
        unit: "g",
        currency: "EUR",
        quantity: rng.nextInt(1000));
  }

  List<ReceiptItem> randomReceiptItemList(int? length) {
    final len = length ?? rng.nextInt(21);
    return List.generate(len, (index) => randomReceiptItem());
  }

  DateTime randomDateTime() {
    return DateTime(rng.nextInt(10) + 2010, rng.nextInt(12) + 1,
        rng.nextInt(27), rng.nextInt(24), rng.nextInt(60), rng.nextInt(60));
  }

  Receipt randomReceipt(int? nItems) {
    final riList = randomReceiptItemList(nItems);
    var totalPrice = 0.0;
    for (var element in riList) {
      totalPrice += element.totalPrice;
    }
    return Receipt(
        receiptItemsList: riList,
        shopName: randomString(8),
        dateTime: randomDateTime(),
        totalPrice: totalPrice,
        currency: "EUR",
        country: "Deutschland",
        city: "Berlin",
        address: "Ritterstraße 51, 10119 Berlin, Germany",
        postalCode: "10119",
        paymentType: "cash",
        dataSource: 0,
        uuid: randomUUID());
  }
}
