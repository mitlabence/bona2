import 'dart:typed_data';

import 'package:bona2/constants.dart';
import 'package:bona2/random_receipt_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() {
    final RandomReceiptGenerator rrg = RandomReceiptGenerator();
  });
  group("Test uuid generator", () {
    test("Test randomUUID()", () {
      final Uint8List u8l = RandomReceiptGenerator().randomUUID();
      assert(u8l.length == kUuidUint8ListLength);
    });
    test("Test uuid v4 generator", () {
      final uuidString = const Uuid().v4(); // a string
      final uuidValueObj = const Uuid().v4obj(); // an UuidValue object
      final uuidValueObjFromString = UuidValue(uuidString);  // object from uuid string
      final uuidValueObjFromBytes = UuidValue.fromByteList(uuidValueObj.toBytes());

      assert(uuidString.length == uuidValueObj.toString().length);
      assert(uuidValueObj.toBytes().length == uuidValueObjFromString.toBytes().length);
      assert(uuidString.length == uuidValueObjFromString.toString().length);
      assert(uuidValueObjFromBytes.toBytes().length == uuidValueObj.toBytes().length);
    });
  });
}
