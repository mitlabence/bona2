import 'package:bona2/Views/receipt_item_list_view.dart';
import 'package:bona2/database_helper.dart';
import 'package:flutter/material.dart';

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
  int s = 0;
  final DataBaseHelper dbh = DataBaseHelper.instance;
  final RandomReceiptGenerator rrg = RandomReceiptGenerator();

  void addReceipt(int? nItems) {
    Receipt r = rrg.randomReceipt(nItems);
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Clearing local databases blocked.'),
                              duration: Duration(seconds: 2),
                            ));
                            //await dbh.clearTable();
                            // setState(
                            //     () {}); // TODO: there must be a better way of notifying the framework of the change!
                          },
                          child: const Text("Clear local databases"))
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
                future: DataBaseHelper.instance.getReceipts(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Receipt>> snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.hasError) {
                      print(snapshot
                          .error); // TODO: proper connectionState sampling logic necessary
                    }
                    return const Center(child: Text('Loading...'));
                  } else {
                    return snapshot.data!.isEmpty
                        ? const Center(child: Text('No receipts yet.'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ReceiptTile(
                                title: snapshot.data![index].shopName,
                                subtitle:
                                    "${formatDateTimeToMinutes(snapshot.data![index].dateTime)}, ${snapshot.data![index].totalPrice} ${snapshot.data![index].currency}",
                                onTapCallback: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReceiptItemListView(
                                                receiptUuid:
                                                    snapshot.data![index].uuid,
                                              )));
                                },
                                onLongPressCallback: () async {
                                  DataBaseHelper dbh = DataBaseHelper.instance;
                                  await dbh.removeReceiptAndItemsByUUID(
                                      snapshot.data![index].uuid);
                                  setState(() {});
                                  print("Removed receipt");
                                },
                              );
                            });
                  }
                },
              ),
            ),
            Expanded(
              flex:1,
              child: TextButton(
                onPressed: () {},
                child: const Text("Add receipt"),
              ),
            ),
            const Expanded(
              flex: 1,
              child: TextButton(
                onPressed: null,
                child: Text("Remove receipt"),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
