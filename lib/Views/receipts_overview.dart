import 'package:bona2/Views/receipt_item_list_view.dart';
import 'package:bona2/database_helper.dart';
import 'package:bona2/uuid_tools.dart';
import 'package:flutter/material.dart';
import "package:bona2/firestore_helper.dart";

import '../DataStructures/receipt.dart';
import 'package:bona2/random_receipt_generator.dart';

import '../Widgets/receipt_tile.dart';
import '../utils.dart';

class ReceiptsOverview extends StatefulWidget {
  const ReceiptsOverview({Key? key}) : super(key: key);

  @override
  State<ReceiptsOverview> createState() => _ReceiptsOverviewState();
}

class _ReceiptsOverviewState extends State<ReceiptsOverview> {
  final DataBaseHelper dbh = DataBaseHelper.instance;

  Future<void> _synchronizeDataBase() async {
    // Download all receipts and receipt items from FireStore.
    var inst = FireStoreHelper();
    var dbh = DataBaseHelper.instance;
    var receiptsAndItems = await inst.downloadAllReceipts();
    if(receiptsAndItems != null){
      dbh.addReceiptItems(receiptsAndItems.item2);
      dbh.addReceipts(receiptsAndItems.item1);
    }
    print("Done!");
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Receipts and Items"),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          onTap: () async {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Clearing local databases blocked.'),
                              duration: Duration(seconds: 2),
                            ));
                            //await dbh.clearTable();
                            // setState(
                            //     () {}); // TODO: there must be a better way of notifying the framework of the change!
                          },
                          child: const Text("Clear local databases")),
                  // PopupMenuItem<int>(
                  //     onTap: () async {
                  //       final List<Receipt> allReceipts = await DataBaseHelper.instance.getReceipts();
                  //       final FireStoreHelper fsh = FireStoreHelper();
                  //       for (Receipt receipt in allReceipts){
                  //        await fsh.uploadReceiptAndItems(receipt);
                  //       }
                  //     },
                  //     child: const Text("Upload all receipts"))
                    ])
          ],
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: Column(children: [
            Expanded(
              flex: 10,
              child: FutureBuilder<List<Receipt>>(
                // TODO: with increasing number of receipts, need to make smaller queries, updating with scrolling
                future: DataBaseHelper.instance.getReceiptsWithoutItems(),  // No need to fetch receipt items, only when clicking on one receipt.
                builder: (BuildContext context,
                    AsyncSnapshot<List<Receipt>> snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.hasError) {
                      print(snapshot
                          .error); // TODO: proper connectionState sampling logic necessary
                    }
                    return const Center(child: Text('Loading...'));
                  } else {
                    return snapshot.data!.isEmpty
                        ? Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  // TODO: block second click while synchronization is running.
                                  // TODO: add checking if all receipts and receipt items are present. No duplication should happen
                                  _synchronizeDataBase();
                                },
                                child: Text(
                                    'No receipts locally. Synchronize...')))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ReceiptTile(
                                title: snapshot.data![index].shopName,
                                subtitle:
                                    "${formatDateTimeToMinutes(snapshot.data![index].dateTime)}, ${snapshot.data![index].totalPrice.toStringAsFixed(2)} ${snapshot.data![index].currency}",
                                onTapCallback: () {
                                  print("Opening receipt ${uuidStringFromUint8List(snapshot.data![index].uuid)}");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReceiptItemListView(
                                                receiptUuid:
                                                    snapshot.data![index].uuid,
                                              )));
                                },
                                onLongPressCallback: () {},
                              );
                            });
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
