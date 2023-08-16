import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:bona2/DataStructures/receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data_structures_util.dart';
import 'package:bona2/constants.dart';


Future main() async {
  // Helpful stackoverflow answer for setting up SQLite unit tests:
  // https://stackoverflow.com/questions/71136324/writing-unit-tests-for-sqflite-for-flutter
  // also
  // https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/testing.md
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Test SQLite', () async {
    // from https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/testing.md
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db
          .execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, value TEXT)');
    });
    await db.insert('Test', {'value': 'my_value'});
    expect(await db.query('Test'), [
      {'id': 1, 'value': 'my_value'}
    ]);
    await db.close();
  });

  test('test insert ReceiptItem with null rawText', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute(kCreateTestReceiptItemDatabaseCommand);
    });
    final ReceiptItem receiptItem = createReceiptItem(); // rawText = null
    await db.insert(kTestReceiptItemDatabaseName, receiptItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    expect(await db.query(kTestReceiptItemDatabaseName), [
      {
        'pk': 1,
        'rawtext': 'NaN',
        'shoppingitem': receiptItem.shoppingItem.itemName,
        'totalprice': receiptItem.totalPrice,
        "quantity": receiptItem.quantity,
        "currency": receiptItem.currency,
        "unit": receiptItem.unit,
        'uuid': receiptItem.uuid,
      }
    ]);
    await db.close();
  });

  test('test insert empty Receipt', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute(kCreateTestReceiptDatabaseCommand);
    });
    final Receipt receipt = createReceiptEmpty(); // rawText = null

    await db.insert(kTestReceiptDatabaseName, receipt.toMapSQL(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    expect(await db.query(kTestReceiptDatabaseName), [
      {
        'pk': 1,
        'shopname': receipt.shopName,
        'datetime': receipt.dateTime.millisecondsSinceEpoch,
        'totalprice': receipt.totalPrice,
        'currency': receipt.currency,
        'country': receipt.country,
        'address': receipt.address,
        'postalcode': receipt.postalCode,
        'city': receipt.city,
        'paymenttype': receipt.paymentType,
        'uuid': receipt.uuid,
        'datasource': receipt.dataSource,
      }
    ]);
    await db.close();
  });
}
