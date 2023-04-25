import 'dart:convert';
import 'package:bona2/taggun_receipt_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bona2/DataStructures/receipt.dart';
import 'package:flutter/services.dart' show rootBundle;

Future main() async {
  late String exampleResponse;
  late Map<String, dynamic> exampleResponseJson;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    exampleResponse =
        await rootBundle.loadString('assets/taggun_test/taggun_example_response1.json');
    exampleResponseJson = jsonDecode(exampleResponse);
  });

  group("Group test implementation-independent attributes", () {
    test("ReceiptReader should initialize self.receipt", () {
      final TaggunReceiptReader taggunReader = TaggunReceiptReader(json: exampleResponseJson);
      expect(() => taggunReader.receipt, returnsNormally);
      expect(taggunReader.receipt, isNotNull);
    });
    test("ReceiptReader should initialize self.receiptItems", () {
      final TaggunReceiptReader taggunReader = TaggunReceiptReader(json: exampleResponseJson);
      expect(() => taggunReader.receiptItems, returnsNormally);
      expect(taggunReader.receiptItems, isNotNull);
    });
  });

  group("Group test correctness of TaggunReader with example", () {
    test("test attributes", () {
      final TaggunReceiptReader taggunReader = TaggunReceiptReader(json: exampleResponseJson);
      final Receipt receipt = taggunReader.receipt;
      final List<ReceiptItem> receiptItemsList = taggunReader.receiptItems;
      expect(receiptItemsList.length, receipt.numberOfItems);
      //TODO: continue checking values (datetime, receipt items, uuid etc.)
    });
  });
}
