import 'dart:typed_data';

import 'package:bona2/DataStructures/receipt-item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/utils/utils.dart';
import 'dart:io';
import 'DataStructures/receipt.dart';
import 'constants.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseHelper {
  /// Singleton class containing database-related functions
  DataBaseHelper._privateConstructor();

  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();
  static Database? _db;

  Future<Database> get db async => _db ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    String path = join(docsDir.path, kDatabaseName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future createTable(String createTableCommand) async {
    Database db = await instance.db;
  }

  Future _onCreate(Database db, int version) async {
    /// There are two tables in the database: Receipts and ReceiptItems.
    await db.execute(kCreateReceiptDatabaseCommand);
    await db.execute(kCreateReceiptItemDatabaseCommand);
  }

  Future<List<Receipt>> getReceipts() async {
    Database db = await instance.db;
    var receipts = await db.query(kTestReceiptDatabaseName, orderBy: 'uuid');
    List<Receipt> receiptsList = receipts.isNotEmpty
        ? receipts.map((item) => Receipt.fromMap(item)).toList()
        : [];
    return receiptsList;
  }

  Future<int> addReceipt(Receipt receipt) async {
    Database db = await instance.db;
    print("Receipt:");
    print(hex(receipt.uuid));
    return await db.insert(kTestReceiptDatabaseName, receipt.toMapSQL());
  }

  Future<int> addReceiptItem(ReceiptItem receiptItem) async {
    Database db = await instance.db;
    return await db.insert(kTestReceiptItemDatabaseName, receiptItem.toMap());
  }

  Future<int> addReceiptItems(List<ReceiptItem> receiptItemsList) async {
    Database db = await instance.db;
    int i = -1;
    print("ReceiptItems:");
    for (var element in receiptItemsList) {
      print(hex(element.uuid));
      i = await db.insert(kTestReceiptItemDatabaseName, element.toMap());
    }
    return i;
  }

  Future<int> deleteTable() async {
    // TODO: make it selectable once more tables exist
    Database db = await instance.db;
    return await db.delete(kTestReceiptDatabaseName);
  }

  Future clearTable() async {
    // TODO: make it selectable once more tables exist
    Database db = await instance.db;
    await db.execute("DROP TABLE IF EXISTS $kTestReceiptDatabaseName");
    await db.execute(kCreateReceiptDatabaseCommand);
    await db.execute("DROP TABLE IF EXISTS $kTestReceiptItemDatabaseName");
    await db.execute(kCreateReceiptItemDatabaseCommand);
  }

  Future<List<ReceiptItem>> getReceiptItems(Uint8List uuid) async {
    String uuidString = hex(uuid).toUpperCase();
    print(uuidString);
    Database db = await instance.db;
    var receiptItems =
        await db.query(kTestReceiptItemDatabaseName, where: "uuid = x'$uuidString'", orderBy: 'uuid');
    List<ReceiptItem> receiptItemsList = receiptItems.isNotEmpty
        ? receiptItems.map((item) => ReceiptItem.fromMap(item)).toList()
        : [];
    return receiptItemsList;
  }
}
