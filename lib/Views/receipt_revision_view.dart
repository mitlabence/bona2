import 'dart:collection';

import 'package:bona2/Dialogs/show_image_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../DataStructures/receipt.dart';
import '../DataStructures/receipt_item.dart';
import '../Dialogs/receipt_item_edit_dialog.dart';
import '../constants.dart';
import '../database_helper.dart';
import '../post_request_provider.dart';
import 'package:bona2/firestore_helper.dart';
import 'package:riverpod/riverpod.dart';

//TODO: this should replace the receiptsoverview. editing should be blocked or allowed, depending on some setting.
const kClassName = "ReceiptRevisionView";

enum EditType {
  delete,
  mergeUp,
  mergeDown,
  moveUp,
  moveDown,
  edit,
}

class EditHistoryQueueItem {
  /// @param editType the type of editing
  /// @param index the original index of receiptItem in the list
  /// @param receiptItem
  final EditType editType;
  final int index;
  final ReceiptItem receiptItem;

  EditHistoryQueueItem(
      {required this.editType, required this.index, required this.receiptItem});
}

class ReceiptRevisionView extends StatefulWidget {
  /// This view should be called after a receipt and receipt items are
  /// acquired and just before inserted into the database. Review the items,
  /// details, manually correct them if necessary.
  const ReceiptRevisionView(
      {required this.receipt, required this.imageData, Key? key})
      : super(key: key);
  final Receipt receipt;
  final Uint8List? imageData;

  @override
  State<ReceiptRevisionView> createState() => _ReceiptRevisionViewState();
}

class _ReceiptRevisionViewState extends State<ReceiptRevisionView> {
  late Receipt receipt;
  late FireStoreHelper fireStoreHelper;
  late Provider<Receipt> receiptProvider;
  Queue<EditHistoryQueueItem> history = Queue();

  int getReceiptItemsLength(ProviderRef<Receipt> ref) {
    return ref.read(receiptProvider).receiptItemsList.length;
  }

  ReceiptItem getReceiptItem(ProviderRef<Receipt> ref, int index) {
    return ref.read(receiptProvider).receiptItemsList[index];
  }

  void updateReceiptItem(
      ProviderRef<Receipt> ref, ReceiptItem newReceiptItem, int index) {
    ref.read(receiptProvider).receiptItemsList[index] = newReceiptItem;
  }

  @override
  void initState() {
    super.initState();
    receipt = widget.receipt;
    fireStoreHelper = FireStoreHelper(); // get instance
    receiptProvider = Provider<Receipt>((ref) => receipt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Undo"),
                onTap: () {
                  undoLastEditRemoveFromHistory();
                  setState(() {});
                },
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Undo all"),
                onTap: () {
                  int historyIndex = history.length;
                  while (historyIndex > 0) {
                    undoLastEditRemoveFromHistory();
                    historyIndex--;
                  }
                  setState(() {});
                },
              ),
            ],
            onSelected: (int result) {
              //TODO: implement undo and undo all.
            },
          ),
        ],
      ),
      body: Column(children: [
        Text(receipt.shopName),
        Text(receipt.dateTime.toString()),
        SizedBox(
          width: 400,
          height: 600,
          child: ListView.builder(
            //FIXME: if empty list, throws error (deleting items for example)
            scrollDirection: Axis.vertical,
            itemCount: receipt.numberOfItems,
            itemBuilder: (context, index) {
              return ListTile(
                title:
                    Text(receipt.receiptItemsList[index].itemCategory.itemName),
                subtitle: Text(
                    "${receipt.receiptItemsList[index].totalPrice} ${receipt.currency}"),
                onTap: () async {
                  //final data = ref.watch(receiptProvider);
                  // TODO: think about how to modify receipt items from a pop-up window
                  // https://stackoverflow.com/questions/54480641/flutter-how-to-create-forms-in-popup
                  // For initial value of form fields:
                  // https://stackoverflow.com/questions/43214271/how-do-i-supply-an-initial-value-to-a-text-field
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //   content: Text(receipt.receiptItemsList[index].rawText ??
                  //       kNullStringValue),
                  //   duration: const Duration(seconds: 2),
                  // ));
                  Tuple3 editedIndexReceiptItemStatus = await showDialog(
                    context: context,
                    builder: (context) => ReceiptItemEditDialog(
                        receiptItem: receipt.receiptItemsList[index],
                        index: index),
                  );
                  // Save changes, add to edit history
                  var editedIndex =
                      editedIndexReceiptItemStatus.item1;
                  ReceiptItem editedReceiptItem =
                      editedIndexReceiptItemStatus.item2;
                  EditStatus editStatus =
                      editedIndexReceiptItemStatus.item3;

                  switch(editStatus) {
                    case EditStatus.changed:
                      replaceAddToHistory(editedIndex, editedReceiptItem);
                      break;
                    // Delete is implemented in a different way, as we don't have the items in a database yet,
                    // but in a simple List that we can modify easily.
                    case EditStatus.deleted:
                    case EditStatus.unchanged:
                      break;
                  }

                  setState(() {
                    // TODO: replace with proper update state
                  });
                },
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      deleteAddToHistory(index);
                      setState(() {});
                    },
                  ),
                  IconButton(
                    // MergeUp
                    icon: const Icon(Icons.merge_type),
                    onPressed: () {
                      mergeUpAddToHistory(index);
                      setState(() {}); // FIXME: proper way to update needed
                    },
                  ),
                  IconButton(
                    // MoveUp
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {
                      moveUpAddToHistory(index);
                      setState(() {}); // FIXME: proper way to update needed
                    },
                  ),
                  IconButton(
                    // MoveDown
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () {
                      moveDownAddToHistory(index);
                      setState(() {}); // FIXME: proper way to update needed
                    },
                  ),
                ]),
              );
            },
          ),
        ),
        Text(
            "Total: ${receipt.detectedTotalPrice.toStringAsFixed(2)} ${receipt.currency} from items, ${receipt.totalPrice.toStringAsFixed(2)} detected."),
        IconButton(
          onPressed: () async {
            if (widget.imageData != null) {
              await showDialog(
                context: context,
                builder: (context) => ShowImageDialog(
                  imageData: widget.imageData!,
                ),
              );
            } else {
              print("No image was found.");
            }
          },
          icon: const Icon(Icons.preview),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          DataBaseHelper dbh = DataBaseHelper.instance;
          int responseReceipt = await dbh.addReceipt(receipt);
          int responseReceiptItem =
              await dbh.addReceiptItems(receipt.receiptItemsList);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Added receipt number $responseReceipt, receipt items $responseReceiptItem'),
              duration: const Duration(seconds: 2),
            ));
            print("Uploading to cloud...");
            final String fname =
                "${UuidValue.fromByteList(receipt.uuid).uuid}.json";
            // TODO: it should be uploaded into an own (uuid) folder per user!
            await fireStoreHelper.uploadReceiptAndItems(receipt);
            //await fireStoreHelper.uploadSample();
            if (!mounted) {
              print("ReceiptRevisionView: not mounted.");
              return;
            }
            //Navigator.of(context).pop();
            Navigator.pushNamedAndRemoveUntil(context, '/upload', (r) => false);
          }
        },
      ),
    );
  }

  void mergeUpAddToHistory(int index) {
    if (index > 0) {
      receipt.receiptItemsList[index - 1] += receipt.receiptItemsList[index];
      ReceiptItem mergedItem = receipt.receiptItemsList.removeAt(index);
      history.addLast(EditHistoryQueueItem(
        editType: EditType.mergeUp,
        index: index,
        receiptItem: mergedItem,
      ));
    }
    print(history.length);
  }

  void mergeDownAddToHistory(int index) {
    if (index < receipt.receiptItemsList.length - 1) {
      receipt.receiptItemsList[index + 1] += receipt.receiptItemsList[index];
      ReceiptItem mergedItem = receipt.receiptItemsList.removeAt(index);
      history.addLast(EditHistoryQueueItem(
        editType: EditType.mergeDown,
        index: index,
        receiptItem: mergedItem,
      ));
    }
  }

  void moveUp(int index) {
    /// Moves item at index up once, into index-1. Element at index-1 is moved to index.
    /// This function does no check on index!
    ReceiptItem item = receipt.receiptItemsList[index];
    ReceiptItem itemAbove = receipt.receiptItemsList[index - 1];

    receipt.receiptItemsList[index] = itemAbove;
    receipt.receiptItemsList[index - 1] = item;
  }

  void moveDown(int index) {
    /// Moves item at index down once, into index+1. Element at index+1 is moved to index.
    /// This function does no check on index!
    ReceiptItem item = receipt.receiptItemsList[index];
    ReceiptItem itemBelow = receipt.receiptItemsList[index + 1];

    receipt.receiptItemsList[index] = itemBelow;
    receipt.receiptItemsList[index + 1] = item;
  }

  void moveUpAddToHistory(int index) {
    if (index > 1) {
      // do nothing if element is first
      moveUp(index);
      ReceiptItem item =
          receipt.receiptItemsList[index - 1]; // Get the item that was moved up
      history.addLast(EditHistoryQueueItem(
        editType: EditType.moveUp,
        index: index,
        receiptItem:
            item, // TODO: for moving up or down, no need to pass receiptItem
      ));
    }
  }

  void moveDownAddToHistory(int index) {
    if (index < receipt.receiptItemsList.length - 1) {
      // do nothing if element is last
      moveDown(index);
      ReceiptItem item = receipt
          .receiptItemsList[index + 1]; // Get the item that was moved down
      history.addLast(EditHistoryQueueItem(
        editType: EditType.moveDown,
        index: index,
        receiptItem:
            item, // TODO: for moving up or down, no need to pass receiptItem
      ));
    }
  }

  void replaceAddToHistory(int index, ReceiptItem newItem){
    ReceiptItem overwrittenItem = receipt.receiptItemsList[index];
    receipt.receiptItemsList[index] = newItem;
    history.addLast(EditHistoryQueueItem(
        editType: EditType.edit, index: index, receiptItem: overwrittenItem));
  }

  void deleteAddToHistory(int index) {
    ReceiptItem removedItem = receipt.receiptItemsList.removeAt(index);
    history.addLast(EditHistoryQueueItem(
        editType: EditType.delete, index: index, receiptItem: removedItem));
    print(history.length);
  }

  int undo(EditHistoryQueueItem historyItem) {
    switch (historyItem.editType) {
      case EditType.delete:
        receipt.receiptItemsList
            .insert(historyItem.index, historyItem.receiptItem);
        return 1;
      case EditType.mergeUp:
        receipt.receiptItemsList[historyItem.index - 1] =
            receipt.receiptItemsList[historyItem.index - 1] -
                historyItem.receiptItem;
        receipt.receiptItemsList
            .insert(historyItem.index, historyItem.receiptItem);
        return 1;
      case EditType.mergeDown:
        // the item after historyItem is the one currently at "index"
        receipt.receiptItemsList[historyItem.index] =
            receipt.receiptItemsList[historyItem.index] -
                historyItem.receiptItem;
        receipt.receiptItemsList
            .insert(historyItem.index, historyItem.receiptItem);
        return 1;
      case EditType.moveUp:
        // Element at index was moved up, so need to move element at index-1 down.
        moveDown(historyItem.index - 1);
        return 1;
      case EditType.moveDown:
        // Element at index was moved down, so need to move element at index+1 up.
        moveUp(historyItem.index + 1);
        return 1;
      case EditType.edit:
        // Change edited element back to original
        receipt.receiptItemsList[historyItem.index] = historyItem.receiptItem;
        return 1;
    }
  }

  int undoLastEditRemoveFromHistory() {
    if (history.isEmpty) {
      if (kDebugMode) {
        print(
            '${kClassName}: undoLastEditRemoveFromHistory() was called with empty history.');
      }
      return 0;
    }
    EditHistoryQueueItem historyItem = history.removeLast();
    return undo(historyItem);
  }
}
