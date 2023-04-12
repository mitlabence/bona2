import 'dart:typed_data';

import 'package:bona2/DataStructures/shopping-item.dart';
import 'package:uuid/uuid_util.dart';

import 'DataStructures/receipt-item.dart';
import 'DataStructures/receipt.dart';

class TaggunReader {
  /// Class to interpret Taggun json file and convert it to
  /// Receipt and List<ReceiptItem> objects
  //TODO: this does not need to be a class as it stands now. Make it
  // singleton or function.

  late Receipt receipt;
  late List<ReceiptItem> receiptItemsList;

  TaggunReader({required Map<String, dynamic> json}) {
    // Read json data and confidence intervals
    final String shopName = json["merchantName"]["data"];
    final double shopNameConfidence = json["merchantName"]["confidenceLevel"];

    // Taggun returns datetime in following format: yyyy-MM-ddTHH:mm:ss.SSSZ.
    // Need to convert this to [yyyy, MM, dd, HH, mm, ss, SSS].
    // Achieve by finding following separators: "-", "T", ":", and strip by "Z"
    // 1. strip Z
    //final String dateTimeStrings = json["date"]["data"].endsWith("Z") ? json["date"]["data"].substring(0, json["date"]["data"].length - 1) : json["date"]["data"];
    // 2. Split at separators
    //final RegExp separators = RegExp(r"[-|T|:|.]");
    //final List<String> dateTimeList = dateTimeStrings.split(separators);
    // DateTime.parse can theoretically parse this datetime format!

    final DateTime dateTime = DateTime.parse(json["date"]["data"]);
    final double dateTimeConfidence = json["date"]["confidenceLevel"];

    final double totalPrice = json["totalAmount"]["data"];
    final double totalPriceConfidence = json["totalAmount"]["confidenceLevel"];

    final String currency = json["totalAmount"]["currencyCode"];

    final String country = json["location"]["country"]["names"]["en"];

    final String address = json["merchantAddress"]["data"];

    final String postalCode = json["merchantPostalCode"]["data"];

    final String city = json["merchantCity"]["data"];

    // Generate uuid for Receipt object
    final Uint8List uuid = UuidUtil.mathRNG();
    // Get items
    /*
    receiptItemsList = List.generate(
        json["amounts"].length,
        (index) => ReceiptItem(
            shoppingItem: ShoppingItem(itemName: json["amount"][index]["text"]),
            rawText: json["amount"][index]["text"],
            totalPrice: json["amount"][index]["data"],
            quantity: 1,
            unit: "piece",
            uuid: uuid));
    */
    receiptItemsList = List.generate(json["amounts"].length, (index) => ReceiptItem(
        shoppingItem: ShoppingItem(itemName: json["amounts"][0]["text"]),
        rawText: json["amounts"][index]["text"],
        totalPrice: json["amounts"][index]["data"],
        quantity: 1,
        unit: "piece",
        uuid: uuid));
    // TODO: infer quantity, unit, shoppingItem from text!

    // Generate Receipt
    receipt = Receipt(
        receiptItemsList: receiptItemsList,
        shopName: shopName,
        dateTime: dateTime,
        totalPrice: totalPrice,
        currency: currency,
        country: country,
        city: city,
        address: address,
        postalCode: postalCode,
        paymentType: "card",
        // TODO: infer payment type!
        uuid: uuid);
  }
}
