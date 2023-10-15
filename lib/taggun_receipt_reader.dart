import 'dart:typed_data';

import 'package:bona2/DataStructures/shopping_item.dart';
import 'package:bona2/receipt_reader.dart';
import 'package:bona2/uuid_tools.dart';

import 'DataStructures/receipt_item.dart';
import 'DataStructures/receipt.dart';
import 'constants.dart';

// TODO: add source to Receipt (default: NaN)
// TODO: in receipt view, add on-click function: edit text (receiptitem). Edit quantity, what else?

class TaggunReceiptReader implements ReceiptReader {
  /// Class to interpret Taggun json file and convert it to
  /// Receipt and List<ReceiptItem> objects
  //TODO: this does not need to be a class as it stands now. Make it
  // singleton or function.

  @override
  late Receipt receipt;

  @override
  late List<ReceiptItem> receiptItems;

  TaggunReceiptReader({required Map<String, dynamic> json, Uint8List? uuid}) {
    // Read json data and confidence intervals
    final String shopName = json["merchantName"]["data"];
    final double shopNameConfidence = json["merchantName"]["confidenceLevel"];
    // TODO: add more checks and exception handling here! This function needs to be very stable.
    // Also, later, hint for issues that arose? (no datetime, double items?)

    // Taggun returns datetime in following format: yyyy-MM-ddTHH:mm:ss.SSSZ.
    // Need to convert this to [yyyy, MM, dd, HH, mm, ss, SSS].
    // Achieve by finding following separators: "-", "T", ":", and strip by "Z"
    // 1. strip Z
    //final String dateTimeStrings = json["date"]["data"].endsWith("Z") ? json["date"]["data"].substring(0, json["date"]["data"].length - 1) : json["date"]["data"];
    // 2. Split at separators
    //final RegExp separators = RegExp(r"[-|T|:|.]");
    //final List<String> dateTimeList = dateTimeStrings.split(separators);
    // DateTime.parse can theoretically parse this datetime format!
    // TODO: rewrite this more elegantly: if no datetime on receipt, use DateTime.now()
    final DateTime now = DateTime.now();
    DateTime dateTime = now;
    if (json["date"].containsKey("data")) {
      try {
        dateTime = DateTime.parse(json["date"]["data"]) ?? now;
      } on FormatException {
        print("DateTime formatexception!");
      }
    }
    final double dateTimeConfidence;
    if (json["date"]["confidenceLevel"] is double) {
      dateTimeConfidence = json["date"]["confidenceLevel"];
    }
    else if (json["date"]["confidenceLevel"] is int ){
      dateTimeConfidence = json["date"]["confidenceLevel"].toDouble();
    } else {
      print("Warning: date confidenceLevel in json file invalid type: ${json["date"]["confidenceLevel"]}. Expected int or double.");
      dateTimeConfidence = 0.0;
    }

    late double totalPrice;
    if (json["totalAmount"]["data"] is double) {
      totalPrice = json["totalAmount"]["data"];
    } else if (json["totalAmount"]["data"] is int) {
      totalPrice = json["totalAmount"]["data"].toDouble();
    } else {
      print("Warning: totalPrice in json file invalid type: ${json["totalAmount"]["data"]}. Expected int or double.");
      totalPrice = -1.0;
    }

    final double totalPriceConfidence =
        json["totalAmount"]["confidenceLevel"].toDouble() ?? 0.0;

    final String currency =
        json["totalAmount"]["currencyCode"] ?? kNullStringValue;

    final String country =
        json["location"]["country"]["names"]["en"] ?? kNullStringValue;

    final String address = json["merchantAddress"]["data"] ?? kNullStringValue;

    final String postalCode =
        json["merchantPostalCode"]["data"] ?? kNullStringValue;

    final String city = json["merchantCity"]["data"] ?? kNullStringValue;

    // Generate uuid for Receipt object
    // TODO: check overshadowing workings, or find better name than finalUuid!
    Uint8List finalUuid = uuid ?? generateUuidUint8List();

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
    receiptItems = List.generate(
        json["amounts"].length,
        (index) => ReceiptItem(
            itemCategory:
                ItemCategory(itemName: json["amounts"][index]["text"]),
            rawText: json["amounts"][index]["text"],
            totalPrice: json["amounts"][index]["data"],
            quantity: 1,
            currency: currency,
            unit: "piece",
            uuid: finalUuid));
    // TODO: infer quantity, unit, shoppingItem from text!

    // Generate Receipt
    receipt = Receipt(
        receiptItemsList: receiptItems,
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
        uuid: finalUuid,
        dataSource: kDataSourceTaggunNumber);
  }
}
