import 'dart:typed_data';

import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:bona2/Dialogs/all_receipt_items_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../DataStructures/receipt.dart';
import '../Dialogs/receipt_item_edit_dialog.dart';
import '../Widgets/receipt_tile.dart';
import '../database_helper.dart';
import 'package:bona2/constants.dart';

import '../firestore_helper.dart';

// TODO: right now, fetching from database occurs every time a receiptitem is edited and saved, overwriting
// the modifications. For possible solution, see:
// https://stackoverflow.com/questions/57224251/flutter-how-to-update-state-or-value-of-a-future-list-used-to-build-listvie
// See even better: https://github.com/flutter/flutter/issues/62019
// Also helpful: https://www.youtube.com/watch?v=LYN46233cws
// TODO: implement update (now commented out below "Something has changed") for "Save changes" button.

class ReceiptItemListView extends StatefulWidget {
  final Uint8List receiptUuid;

  const ReceiptItemListView({Key? key, required this.receiptUuid})
      : super(key: key);

  @override
  State<ReceiptItemListView> createState() => _ReceiptItemListViewState();
}

class _ReceiptItemListViewState extends State<ReceiptItemListView> {
  List<dynamic>? receiptItemsPk;
  List<EditStatus>? receiptItemsEditStatus;
  Receipt? fetchedReceipt;
  int? receiptPk;
  late DataBaseHelper dbh;
  FireStoreHelper fsh =
      FireStoreHelper(); // TODO: difference with dbh? Why can't take instance?
  late Future<Tuple3<dynamic, Receipt, List<dynamic>>> fetchReceiptTask;

  late Uint8List uuid;
  bool somethingChanged = false;

  @override
  void initState() {
    receiptItemsPk = null;
    receiptItemsEditStatus = null;
    uuid = widget.receiptUuid;
    dbh = DataBaseHelper.instance;
    fetchReceiptTask = dbh.getReceiptAndItemsPk(uuid);
    print("fetchReceiptTask set");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit items"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 1,
                child: const Text("Change for all items..."),
                onTap: () async {
                  await fetchReceiptTask;
                  // TODO: can I do this more elegantly? To make sure receiptitems are already loaded.
                  if (!context.mounted) {
                    return; // TODO: how can I get rid of async gap?
                  }

                  Receipt modifiedReceipt = await showDialog(
                    context: context,
                    builder: (context) => AllReceiptItemsEditDialog(
                      receipt: fetchedReceipt!,
                    ),
                  );
                  if (modifiedReceipt != null) {
                    // a tuple2(receipt, receiptitemslist) was returned
                    // replace old fetchedReceipt and fetchedReceiptItems with new
                    Receipt newReceipt = modifiedReceipt;
                    // TODO: unlock "save changes" button. Assign proper save functionality to it, i.e. update database .

                    setState(() {
                      for (int i = 0; i < receiptItemsEditStatus!.length; i++) {
                        // EditStatus always changed if there was a general change to receipt.
                        receiptItemsEditStatus![i] = EditStatus.changed;
                      }
                      fetchedReceipt = newReceipt;
                      somethingChanged = true;
                    });
                  } else {
                    print("No changes");
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            // FIXME: in horizontal view, makes button disappear (out of bounds)
            // FIXME: futurebuilder is called each time returning from the
            //  dialogs (clicking on an item). For now, the program just ignores
            //  the returned data after the first run. Still, database reads
            //  are executed every time!
            child: FutureBuilder<Tuple3<dynamic, Receipt, List<dynamic>>>(
              future: fetchReceiptTask,
              builder: (BuildContext context,
                  AsyncSnapshot<Tuple3<dynamic, Receipt, List<dynamic>>>
                      snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const Center(child: Text('Loading...'));
                  case ConnectionState.active:
                    return const Center(child: Text('Active.'));
                  case ConnectionState.waiting:
                    return const Center(child: Text('Waiting...'));
                  case ConnectionState.done:
                    if (receiptItemsPk == null) {
                      print("Generating receiptItemsPk");
                      receiptItemsPk = List.generate(
                          snapshot.data!.item3.length,
                          (index) => snapshot.data!.item3[index]);
                    }
                    if (receiptItemsEditStatus == null) {
                      print("Generating receiptItemsEditStatus");
                      receiptItemsEditStatus = List.generate(
                          snapshot.data!.item3.length,
                          (index) => EditStatus.unchanged);
                    }

                    // only fetch data one time; modify local copy afterwards
                    receiptPk ??= snapshot.data!.item1;
                    fetchedReceipt ??= snapshot.data!.item2;

                    return (receiptItemsPk != null) & (receiptItemsPk!.isEmpty)
                        ? const Center(child: Text('No receipt items yet.'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: receiptItemsPk!.length,
                            itemBuilder: (context, index) {
                              return ReceiptTile(
                                title: fetchedReceipt!.receiptItemsList[index]
                                        .itemCategory.itemName ??
                                    "NaN",
                                subtitle:
                                    "${fetchedReceipt!.receiptItemsList[index].currency} ${fetchedReceipt!.receiptItemsList[index].totalPrice}",
                                onTapCallback: () async {
                                  var pk = receiptItemsPk![index];
                                  // FIXME: clicking next to dialog closes it, but returns Null, whereas Tuple3 was expected!
                                  Tuple3 editedPkReceiptItemStatus =
                                      await showDialog(
                                    context: context,
                                    builder: (context) => ReceiptItemEditDialog(
                                        // TODO: add remove option with undo option as well.
                                        // Local copy of list should be tuple3, third option containing "changed", "deleted", "unchanged" enum options.
                                        receiptItem: fetchedReceipt!
                                            .receiptItemsList[index],
                                        pk: pk),
                                  );
                                  var editedPk =
                                      editedPkReceiptItemStatus.item1;
                                  ReceiptItem editedReceiptItem =
                                      editedPkReceiptItemStatus.item2;
                                  EditStatus editStatus =
                                      editedPkReceiptItemStatus.item3;
                                  setState(() {
                                    somethingChanged = true;
                                  });
                                  // FIXME: this does not always get triggered upon editing raw text (or other text field). For price it works.
                                  // It also works when total price is updated along with raw text. But raw text alone does not!
                                  //DataBaseHelper dbh = DataBaseHelper.instance;
                                  //int countChanges = await dbh.updateReceiptItem(
                                  //    editedPk, editedReceiptItem);
                                  //print(
                                  //   "$countChanges changes made to receiptitem");
                                  switch (editStatus) {
                                    case EditStatus.changed:
                                      setState(() {
                                        // TODO: if pressed Cancel, do not change EditStatus of the original fetchedReceiptItems![index]
                                        // if pressed delete or changed, change it
                                        receiptItemsPk![index] = editedPk;
                                        receiptItemsEditStatus![index] =
                                            EditStatus.changed;
                                        fetchedReceipt!
                                                .receiptItemsList[index] =
                                            editedReceiptItem;
                                      });
                                      break;
                                    case EditStatus.deleted:
                                      // TODO: implement!
                                      print("Item deleted.");
                                      break;
                                    case EditStatus.unchanged:
                                      break;
                                  }

                                  // TODO: edit firebase stored json object as well!

                                  // TODO: somethingChanged = True if edits were made.
                                },
                                onLongPressCallback: () {
                                  DataBaseHelper dbh = DataBaseHelper.instance;
                                },
                              );
                            });
                  default:
                    return const Center(child: Text('default'));
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              // TODO: add confirmation dialog!
              onPressed: somethingChanged
                  ? () {
                      DataBaseHelper dbh = DataBaseHelper.instance;
                      // TODO: only change modified items! Not a limitation by performance currently.
                      // The status are stored as receiptItemsPkStatus![index].item2
                      if (receiptItemsPk != null) {
                        for (int index = 0;
                            index < receiptItemsPk!.length;
                            index++) {
                          // var pkItemTuple in receiptItemsPkStatus!
                          var editedPk = receiptItemsPk![index];
                          var editedItem =
                              fetchedReceipt!.receiptItemsList[index];
                          dbh.updateReceiptItem(editedPk, editedItem);
                          print("Updated $editedPk to $editedItem");
                          // TODO: use databasehelper, batch.commit()!
                        }
                        if (fetchedReceipt != null) {
                          dbh.updateReceipt(receiptPk, fetchedReceipt!);
                          fsh.updateReceipt(fetchedReceipt!);
                          print("Updated Receipt");
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saved changes!")));
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/upload', (r) => false);
                      }
                      //dbh.updateReceiptItem(editedPk, newReceiptItem)
                    }
                  : null,
              child: const Text("Save changes"),
            ),
          )
        ],
      ),
    );
  }
}
