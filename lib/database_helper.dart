import 'dart:typed_data';

import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:tuple/tuple.dart';
import 'dart:io';
import 'DataStructures/receipt.dart';
import 'constants.dart';
import 'package:path_provider/path_provider.dart';
// TODO: refactor with new name "DBProvider"
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
    // TODO: add snackbar when new database is created? Or a waiting/loading screen. This function is not the proper place, though.
    await db.execute(kCreateReceiptDatabaseCommand);
    await db.execute(kCreateReceiptItemDatabaseCommand);
  }

  Future<List<Receipt>> getReceipts() async {
    Database db = await instance.db;
    var receipts = await db.query(kReceiptDatabaseName, orderBy: 'uuid');
    List<Receipt> receiptsList = receipts.isNotEmpty
        ? receipts.map((item) => Receipt.fromMap(item)).toList()
        : [];
    return receiptsList;
  }

  Future<int> addReceipt(Receipt receipt) async {
    //TODO: misleading, as this function does not add the items in the receipt.
    // Change the name or impelment alternative function which adds the items as well.
    // TODO: handle re-adding same receipt: should not add duplicate. Use datetime, total price to compare.
    Database db = await instance.db;
    print("Receipt:");
    print(hex(receipt.uuid));
    return await db.insert(kReceiptDatabaseName, receipt.toMapSQL());
  }

  Future<int> addReceiptItem(ReceiptItem receiptItem) async {
    //TODO: handle re-adding same receipt item: do not add duplicate. What if two items bought in same session?
    Database db = await instance.db;
    return await db.insert(kReceiptItemDatabaseName, receiptItem.toMap());
  }


  Future<int> updateReceiptItem(var pk, ReceiptItem newReceiptItem) async {
    /// Replace the keys and values in newValues for ReceiptItem entry with primary key pk
    Database db = await instance.db;
    // TODO: implement function. uuid is in newReceiptItem. Test it!
    // TODO: check if possible to turn pk into num! See getReceiptItemsWithPk().
    return await db.update(kReceiptItemDatabaseName, newReceiptItem.toMap(), where: 'pk = ?', whereArgs: [pk]);
  }

  Future<int> addReceiptItems(List<ReceiptItem> receiptItemsList) async {
    Database db = await instance.db;
    int i = -1;
    for (var element in receiptItemsList) {
      i = await db.insert(kReceiptItemDatabaseName, element.toMap());
    }
    return i;
  }

  Future<int> updateReceipt(dynamic pk, Receipt receipt) async {
    Database db = await instance.db;
    int n_changes = -1;
    n_changes = await db.update(kReceiptDatabaseName, receipt.toMapSQL(), where: 'pk = $pk');
    print("updateReceipt: $n_changes changes");
    return n_changes;
  }
  Future<int> updateReceiptItems(List<dynamic> pkList, List<ReceiptItem> receiptItems) async {
    // TODO: Assert length of the two input lists is equal
    Database db = await instance.db;
    //int n_changes = -1;
    Batch batch = db.batch();
    for(int i=0; i < pkList.length; i++) {
      batch.update(kReceiptDatabaseName, receiptItems[i].toMap(), where: 'pk = ${pkList[i]}');
    }
    await batch.commit(noResult: true);
    //print("updateReceiptItems: $n_changes changes");
    return 1;
  }

  Future<int> deleteTable() async {
    // TODO: make it selectable once more tables exist
    Database db = await instance.db;
    return await db.delete(kReceiptDatabaseName);
  }

  Future clearTable() async {
    // TODO: make it selectable once more tables exist
    Database db = await instance.db;
    await db.execute("DROP TABLE IF EXISTS $kReceiptDatabaseName");
    await db.execute(kCreateReceiptDatabaseCommand);
    await db.execute("DROP TABLE IF EXISTS $kReceiptItemDatabaseName");
    await db.execute(kCreateReceiptItemDatabaseCommand);
  }

  Future<List<ReceiptItem>> getReceiptItemsByUuid(Uint8List uuid) async {
    String uuidString = hex(uuid).toUpperCase();
    Database db = await instance.db;
    List receiptItems = await db.query(kReceiptItemDatabaseName,
        where: "uuid = x'$uuidString'", orderBy: 'pk');
    List<ReceiptItem> receiptItemsList = receiptItems.isNotEmpty
        ? receiptItems.map((item) => ReceiptItem.fromMap(item)).toList()
        : [];

    Map<int, ReceiptItem> result = {};
    for (int i = 0; i < receiptItemsList.length; i++) {
      result[i] = receiptItemsList[i];
    }
    return receiptItemsList;
  }

  Future<Receipt> getReceiptByUuid(Uint8List uuid) async{
    String uuidString = hex(uuid).toUpperCase();
    Database db = await instance.db;
    List queryResponse = await db.query(kReceiptDatabaseName, where: "uuid = x'$uuidString'", orderBy: 'pk' );
    Receipt receipt = queryResponse.isNotEmpty ? Receipt.fromMap(queryResponse[0]) : Receipt.empty(); // TODO: handle empty response!

    // Fill up receipt items. Here, uuid refers to receipt and is not unique for receipt item!
    queryResponse = await db.query(kReceiptItemDatabaseName, where: "uuid = x'$uuidString'", orderBy: 'pk');
    List<ReceiptItem> receiptItems = queryResponse.isNotEmpty ? List.generate(queryResponse.length, (index) => ReceiptItem.fromMap(queryResponse[index]))  : List.empty();
    receipt.receiptItemsList = receiptItems;

    // Assume for now that the list has at most one element (uuid unique).
    return receipt;
  }

  Future<Tuple2<dynamic, Receipt>> getReceiptWithPk(Uint8List uuid) async {
    String uuidString = hex(uuid).toUpperCase();
    Database db = await instance.db;
    List queryResponse = await db.query(kReceiptDatabaseName, where: "uuid = x'$uuidString'", orderBy: 'pk' );
    // TODO: handle empty query response! Make sure only one entry of receipt with uuid!
    Receipt receipt = queryResponse.isNotEmpty ? Receipt.fromMap(queryResponse[0]) : Receipt.empty();
    var pk = queryResponse.isNotEmpty ? queryResponse[0]["pk"] : null;

    // Fill up receipt items. Here, uuid refers to receipt and is not unique for receipt item!
    queryResponse = await db.query(kReceiptItemDatabaseName, where: "uuid = x'$uuidString'", orderBy: 'pk');
    List<ReceiptItem> receiptItems = queryResponse.isNotEmpty ? List.generate(queryResponse.length, (index) => ReceiptItem.fromMap(queryResponse[index]))  : List.empty();
    receipt.receiptItemsList = receiptItems;
    return Tuple2(pk, receipt);
  }

  Future<List<Tuple2<dynamic, ReceiptItem>>> getReceiptItemsWithPk(Uint8List uuid) async {
    String uuidString = hex(uuid).toUpperCase();
    Database db = await instance.db;
    List queryResponse = await db.query(kReceiptItemDatabaseName,
        where: "uuid = x'$uuidString'", orderBy: 'pk');
    List<ReceiptItem> receiptItemsList = queryResponse.isNotEmpty
        ? queryResponse.map((item) => ReceiptItem.fromMap(item)).toList()
        : [];
    List<dynamic> pkList = queryResponse.isNotEmpty
        ? queryResponse.map((item) => item["pk"]).toList()
        : [];
    List<Tuple2<dynamic, ReceiptItem>> result = [];
    for (int i = 0; i < receiptItemsList.length; i++) {
      result.add(Tuple2(pkList[i], receiptItemsList[i]));
    }
    return result;
  }

  Future<void> removeReceiptAndItemsByUUID(Uint8List uuid) async {
    String uuidString = hex(uuid).toUpperCase();
    Database db = await instance.db;
    // TODO: make sure that where is never null and other dangers
    int countReceipts =
        await db.delete(kReceiptDatabaseName, where: "uuid = x'$uuidString'");
    int countReceiptItems = await db.delete(kReceiptItemDatabaseName,
        where: "uuid = x'$uuidString'");
    if (countReceipts > 1) {
      // TODO: get rid of this exception.
      throw Exception(
          "removeReceiptByUUID(): more receipts were deleted: $countReceipts");
    }
  }

  Future<Tuple3<dynamic, Receipt, List<dynamic>>> getReceiptAndItemsPk(Uint8List uuid) async {
    List<Tuple2<dynamic, ReceiptItem>> pkReceiptItems = await getReceiptItemsWithPk(uuid);
    Tuple2<dynamic, Receipt> pkReceipt = await getReceiptWithPk(uuid);
    List<dynamic> pkList = List.generate(pkReceiptItems.length, (index) => pkReceiptItems[index].item1);
    return Tuple3(pkReceipt.item1, pkReceipt.item2, pkList);
  }

}
