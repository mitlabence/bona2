import 'dart:collection';

import 'package:bona2/Dialogs/show_image_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../DataStructures/receipt.dart';
import '../DataStructures/receipt_item.dart';
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
  const ReceiptRevisionView({required this.receipt, required this.imageData, Key? key})
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

  int getReceiptItemsLength(ProviderRef<Receipt> ref){
    return ref.read(receiptProvider).receiptItemsList.length;
  }

  ReceiptItem getReceiptItem(ProviderRef<Receipt> ref, int index){
    return ref.read(receiptProvider).receiptItemsList[index];
  }
  void updateReceiptItem(ProviderRef<Receipt> ref, ReceiptItem newReceiptItem, int index) {
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
                onTap: () {
                  //final data = ref.watch(receiptProvider);
                  // TODO: think about how to modify receipt items from a pop-up window
                  // https://stackoverflow.com/questions/54480641/flutter-how-to-create-forms-in-popup
                  // For initial value of form fields:
                  // https://stackoverflow.com/questions/43214271/how-do-i-supply-an-initial-value-to-a-text-field
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(receipt.receiptItemsList[index].rawText ??
                        kNullStringValue),
                    duration: const Duration(seconds: 2),
                  ));
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
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {
                      mergeUpAddToHistory(index);
                      setState(() {}); // FIXME: proper way to update needed
                    },
                  ),
                  IconButton(
                    // MergeUp
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () {
                      mergeDownAddToHistory(index);
                      setState(() {}); // FIXME: proper way to update needed
                    },
                  ),
                ]),
              );
            },
          ),
        ),
        Text(
            "Total: ${receipt.detectedTotalPrice} ${receipt.currency} from items, ${receipt.totalPrice} detected."),
        IconButton(onPressed: () async {
          if (widget.imageData != null) {
            await showDialog(context: context, builder: (context) => ShowImageDialog(
              imageData: widget.imageData!,
            ),);
          } else {
            print("No image was found.");
          }

        }, icon: const Icon(Icons.preview),),
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
            final String fname = "${UuidValue.fromByteList(receipt.uuid).uuid}.json";
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
    }
  }

  int undoLastEditRemoveFromHistory() {
    if (history.isEmpty) {
      if (kDebugMode) {
        print('${kClassName}: undoLastEditRemoveFromHistory() was called with empty history.');
      }
      return 0;
    }
    EditHistoryQueueItem historyItem = history.removeLast();
    return undo(historyItem);
  }
}
