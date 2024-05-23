import 'dart:typed_data';

import 'package:bona2/global.dart';
import 'package:bona2/uuid_tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

import 'DataStructures/receipt.dart';
import 'DataStructures/receipt_item.dart';
// TODO: test that it is a singleton
class FireStoreHelper {
  /// The structure of firestore:
  /// root-level collections: receipts, taggunResults
  /// receipts: contains all user-checked, decoded receipts.
  ///   receiptItems: subcollection (see
  ///     https://firebase.google.com/docs/firestore/data-model
  ///     for example of hierarchical data structures). Flutter example:
  ///
  ///     final messageRef = db
  ///     .collection("rooms")
  ///     .doc("roomA")
  ///     .collection("messages")
  ///     .doc("message1");
  /// taggunResults: contains raw read results of taggun.

  static final FireStoreHelper _instance = FireStoreHelper._internal();

  factory FireStoreHelper() {
    return _instance;
  }

  late String userUid;
  late final FirebaseFirestore firebase;
  late final CollectionReference userReceiptsCollection;
  late final CollectionReference taggunResultsCollection;
  late final DocumentReference personalReceiptsDocument;

  FireStoreHelper._internal() {
    // Set root document in firestore
    userUid = firebaseUid;
    // Get instance of Firestore
    firebase = FirebaseFirestore.instance;
    personalReceiptsDocument = firebase.collection(firebaseUid).doc("receipts");
    userReceiptsCollection =
        personalReceiptsDocument.collection("receipts");
    taggunResultsCollection =
        personalReceiptsDocument.collection("taggunResults");
  }

  Future<void> initializeUser() async {
    /// If the user ID collection does not have "receipts" document, initialize this
    personalReceiptsDocument.get().then((docSnapshot) {
      if (!docSnapshot.exists) {
        Map<String, dynamic> userData = {
          "userId": firebaseUid,
          "timeCreated": DateTime.now().toIso8601String()
        };
        personalReceiptsDocument.set(userData);
      }
    });
  }

  Future<void> uploadReceiptAndItems(Receipt receipt) async {
    final String fileName = uuidStringFromUint8List(receipt.uuid);
    // TODO: might convert to non-future function if I don't check for existence
    //    and not wait for batch.commit(). The question: is it worth it?
    WriteBatch batch = firebase.batch(); // create a batch of writes
    Map<String, dynamic> receiptMap = receipt.toMap();
    List<ReceiptItem> receiptItems = receiptMap.remove("receiptItemsList");
    // Write receipt into receipts collection
    var receiptsFileRef = userReceiptsCollection.doc(fileName);
    // TODO: test if document exists! Do not update then... https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore
    batch.set(receiptsFileRef, receiptMap);
    // Create collection for new receipt document
    var receiptItemsCollectionRef = receiptsFileRef.collection("receipt_items");
    //batch-write receipt items
    for (int i = 0; i < receiptItems.length; i++) {
      final ReceiptItem receiptItem = receiptItems[i];
      final receiptItemFileName = "${fileName}_$i";
      var receiptItemDocRef =
          receiptItemsCollectionRef.doc(receiptItemFileName);
      final receiptItemMap = receiptItem.toMap();
      batch.set(receiptItemDocRef, receiptItemMap);
    }
    await batch.commit();
    print("Uploaded receipt (with items) as file ${fileName}");
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final String fileName = uuidStringFromUint8List(receipt.uuid);
    final receiptDocRef = userReceiptsCollection.doc(fileName);
    WriteBatch batch = firebase.batch();
    Map<String, dynamic> receiptMap = receipt.toMap();
    List<ReceiptItem> receiptItems = receiptMap.remove("receiptItemsList");
    // Write receipt into receipts collection
    var receiptsFileRef = firebase.collection("receipts").doc(fileName);
    batch.update(receiptsFileRef, receiptMap);
    var receiptItemsCollectionRef = receiptDocRef.collection("receipt_items");
    for (int i = 0; i < receiptItems.length; i++) {
      final ReceiptItem receiptItem = receiptItems[i];
      final receiptItemFileName = "${fileName}_$i";
      var receiptItemDocRef =
          receiptItemsCollectionRef.doc(receiptItemFileName);
      final receiptItemMap = receiptItem.toMap();
      batch.update(receiptItemDocRef, receiptItemMap);
    }
    await batch.commit();
  }

  Future<Tuple2<List<Receipt>, List<ReceiptItem>>?>
      downloadAllReceipts() async {
    // Download all receipts the user has.
    // TODO: clean up this function... deal with the schema change (all fields lower case now), extract into functions (like Map keys to lower case)
    // TODO: need to test this... make up debug API key, create a Firestore collection with sample data?
    List<Receipt> receiptsList = [];
    List<ReceiptItem> receiptItemsList = [];
    final QuerySnapshot receiptsSnapshot = await userReceiptsCollection.get();
    if (receiptsSnapshot.docs.isNotEmpty) {
      for (var receiptDoc in receiptsSnapshot.docs) {
        var receiptMap = receiptDoc.data();
        if (receiptMap is Map<String, dynamic>) {
          receiptMap["uuid"] = Uint8List.fromList(
              List<int>.from(receiptMap["uuid"].whereType<int>()));
          Map<String, dynamic> lowerCaseMap = {};
          for (var key in receiptMap.keys) {
            lowerCaseMap[key.toLowerCase()] =
                receiptMap[key]; // receipt takes lower case keys
          }
          receiptsList.add(Receipt.fromMap(lowerCaseMap));
        } else {
          throw Exception(
              "receiptsSnapshot: Map excepted, got other type: $receiptMap");
        }
        CollectionReference receiptItemsCollectionRef = userReceiptsCollection
            .doc(receiptDoc.id)
            .collection("receipt_items");
        QuerySnapshot receiptItemsSnapshot =
            await receiptItemsCollectionRef.get();
        for (var receiptItemDoc in receiptItemsSnapshot.docs) {
          var receiptItemMap = receiptItemDoc.data();
          if (receiptItemMap is Map<String, dynamic>) {
            // TODO: define new list instead? See https://stackoverflow.com/questions/50245187/type-listdynamic-is-not-a-subtype-of-type-listint-where - initializing is preferred over casting
            receiptItemMap["uuid"] = Uint8List.fromList(
                List<int>.from(receiptItemMap["uuid"].whereType<int>()));
            Map<String, dynamic> lowerCaseMap = {};
            for (var key in receiptItemMap.keys) {
              lowerCaseMap[key.toLowerCase()] =
                  receiptItemMap[key]; // receipt takes lower case keys
            }
            receiptItemsList.add(ReceiptItem.fromMap(lowerCaseMap));
          } else {
            throw Exception(
                "receiptItemsSnapshot: Map excepted, got other type: $receiptItemMap");
          }
        }
      }
      return Tuple2(receiptsList, receiptItemsList);
    } else {
      print("No entries found!");
    }
  }
// TODO: make an SQL database with receipt uuid and user uuid!
//Future<List<Receipt>> downloadReceipts() async {
// TODO: download for now all receipts in the folder...
//}
// TODO: create two collections: receipts -> subcollection receiptItems, taggunResults
// TODO: upon acquiring the uid (authentication) and uploading first json file,
// put it in proper folder
// TODO: keep using Google Cloud Storage for storing photos of receipts, for
//  future model training (should be easy to match photo with taggunResults document)
// TODO: need to configure appcheck...
}
