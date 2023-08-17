import 'dart:typed_data';

import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../Dialogs/receipt_item_edit_dialog.dart';
import '../Widgets/receipt_tile.dart';
import '../database_helper.dart';

class ReceiptItemListView extends StatefulWidget {
  final Uint8List ReceiptUuid;

  const ReceiptItemListView({Key? key, required this.ReceiptUuid})
      : super(key: key);

  @override
  State<ReceiptItemListView> createState() => _ReceiptItemListViewState();
}

class _ReceiptItemListViewState extends State<ReceiptItemListView> {
  late List<dynamic> pkList; // list holding integer primary keys
  bool somethingChanged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            // FIXME: in horizontal view, makes button disappear (out of bounds)
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder<List<Tuple2<dynamic, ReceiptItem>>>(
              future: DataBaseHelper.instance
                  .getReceiptItemsWithPk(widget.ReceiptUuid),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Tuple2<dynamic, ReceiptItem>>> snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.hasError) print(snapshot.error);
                  // TODO: proper connectionState sampling logic necessary
                  return const Center(child: Text('Loading...'));
                } else {
                  return snapshot.data!.isEmpty
                      ? const Center(child: Text('No receipt items yet.'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ReceiptTile(
                              title:
                                  snapshot.data![index].item2.rawText ?? "NaN",
                              subtitle: snapshot.data![index].item2.totalPrice
                                  .toString(),
                              onTapCallback: () async {
                                var pk = snapshot.data![index].item1;
                                Tuple2 editedPkReceiptItem = await showDialog(
                                  context: context,
                                  builder: (context) => ReceiptItemEditDialog(
                                      receiptItem: snapshot.data![index].item2,
                                      pk: pk),
                                );
                                var editedPk = editedPkReceiptItem.item1;
                                ReceiptItem editedReceiptItem = editedPkReceiptItem.item2;
                                setState(() {
                                  somethingChanged = true;
                                });
                                if (editedReceiptItem !=
                                    snapshot.data![index].item2) {
                                  print("Something has changed");
                                  DataBaseHelper dbh = DataBaseHelper.instance;
                                  await dbh.updateReceiptItem(editedPk, editedReceiptItem);
                                }
                                // TODO: somethingChanged = True if edits were made.
                              },
                              onLongPressCallback: () {
                                DataBaseHelper dbh = DataBaseHelper.instance;
                              },
                            );
                          });
                }
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: somethingChanged ? () {} : null,
              child: const Text("Save changes"),
            ),
          )
        ],
      ),
    );

    // TODO: calls a future function to build listView of ReceiptItems, the list we get from the ReceiptItems database with matching uuid.
  }
}
