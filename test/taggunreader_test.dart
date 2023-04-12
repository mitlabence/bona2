import 'dart:convert';
import 'package:bona2/taggunReader.dart';
import 'package:flutter/cupertino.dart';
import 'package:bona2/DataStructures/receipt-item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bona2/DataStructures/receipt.dart';
import 'package:flutter/services.dart' show rootBundle;

Future main() async {
  late String exampleResponse;
  late Map<String, dynamic> exampleResponseJson;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    exampleResponse =
        await rootBundle.loadString('assets/taggun_example_response.json');
    exampleResponseJson = jsonDecode(exampleResponse);
  });

  group("Group test correctness of TaggunReader with example", () {
    test("test attributes", () {
      final TaggunReader taggunReader = TaggunReader(json: exampleResponseJson);
      final Receipt receipt = taggunReader.receipt;
      final List<ReceiptItem> receiptItemsList = taggunReader.receiptItemsList;
      expect(receiptItemsList.length, receipt.numberOfItems);
      //TODO: continue checking values (datetime, receipt items, uuid etc.)
    });
  });
}
