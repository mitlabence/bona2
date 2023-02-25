import 'package:bona2/DataStructures/receipt-item.dart';
import 'package:bona2/DataStructures/receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data-structures_util.dart';

const String kCreateReceiptItemDatabaseCommand =
    'CREATE TABLE testReceiptItems (pk INTEGER PRIMARY KEY, rawtext TEXT, shoppingitem TEXT, totalprice REAL, uuid BLOB)';
const String kReceiptItemDatabaseName =
    "testReceiptItems"; // Has to match with table name in creation command

const String kCreateReceiptDatabaseCommand =
    'CREATE TABLE testReceipt (pk INTEGER PRIMARY KEY, shopname TEXT, datetime INT, totalprice REAL, currency TEXT, country TEXT, street TEXT, postalcode TEXT, city TEXT, uuid BLOB)';
const String kReceiptDatabaseName =
    "testReceipt"; // Has to match with table name in creation command

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
      await db.execute(kCreateReceiptItemDatabaseCommand);
    });
    final ReceiptItem receiptItem = createReceiptItem(); // rawText = null
    await db.insert(kReceiptItemDatabaseName, receiptItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    expect(await db.query(kReceiptItemDatabaseName), [
      {
        'pk': 1,
        'rawtext': 'NaN',
        'shoppingitem': receiptItem.shoppingItem.itemName,
        'totalprice': receiptItem.totalPrice,
        'uuid': receiptItem.uuid,
      }
    ]);
    await db.close();
  });

  test('test insert empty Receipt', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute(kCreateReceiptDatabaseCommand);
    });
    final Receipt receipt = createReceiptEmpty(); // rawText = null

    await db.insert(kReceiptDatabaseName, receipt.toMapSQL(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    expect(await db.query(kReceiptDatabaseName), [
      {
        'pk': 1,
        'shopname': receipt.shopName,
        'datetime': receipt.dateTime.millisecondsSinceEpoch,
        'totalprice': receipt.totalPrice,
        'currency': receipt.currency,
        'country': receipt.country,
        'street': receipt.street,
        'postalcode': receipt.postalCode,
        'city': receipt.city,
        'uuid': receipt.uuid,
      }
    ]);
    await db.close();
  });
}
