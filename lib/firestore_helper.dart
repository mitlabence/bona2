import 'package:bona2/global.dart';
import 'package:bona2/uuid_tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'DataStructures/receipt.dart';
import 'DataStructures/receipt_item.dart';

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
  late final CollectionReference receiptsCollection;
  late final CollectionReference taggunResultsCollection;

  FireStoreHelper._internal() {
    // Set root document in firestore
    userUid = firebaseUid;
    // Get instance of Firestore
    firebase = FirebaseFirestore.instance;
    receiptsCollection = firebase.collection("receipts");
    taggunResultsCollection = firebase.collection("taggunResults");
  }

  Future<void> uploadSample() async {
    const String fileName = "Sample";
    final docRef = receiptsCollection.doc(fileName);
    final Map<String, String> sample = {"a": "b", "c": "d"};
    await docRef.set(sample);
    print("Done!");
  }

  Future<void> uploadReceiptAndItems(Receipt receipt) async {
    final String fileName = uuidStringFromUint8List(receipt.uuid);
    // TODO: might convert to non-future function if I don't check for existence
    //    and not wait for batch.commit(). The question: is it worth it?
    final receiptDocRef = receiptsCollection.doc(fileName);
    WriteBatch batch = firebase.batch(); // create a batch of writes
    Map<String, dynamic> receiptMap = receipt.toMap();
    List<ReceiptItem> receiptItems = receiptMap.remove("receiptItemsList");
    // Write receipt into receipts collection
    var receiptsFileRef = firebase.collection("receipts").doc(fileName);
    batch.set(receiptsFileRef, receiptMap);
    // Create collection for new receipt document
    var receiptItemsCollectionRef = receiptDocRef.collection("receipt_items");
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
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final String fileName = uuidStringFromUint8List(receipt.uuid);
    final receiptDocRef = receiptsCollection.doc(fileName);
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

// TODO: create two collections: receipts -> subcollection receiptItems, taggunResults
// TODO: upon acquiring the uid (authentication) and uploading first json file,
// put it in proper folder
// TODO: keep using Google Cloud Storage for storing photos of receipts, for
//  future model training (should be easy to match photo with taggunResults document)
// TODO: need to configure appcheck...
}
