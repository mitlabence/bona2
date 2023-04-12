import 'package:bona2/Views/receiptitemlistview.dart';
import 'package:bona2/databasehelper.dart';
import 'package:flutter/material.dart';

import '../DataStructures/receipt.dart';
import 'package:bona2/randomreceiptgenerator.dart';

import '../Widgets/receipt-tile.dart';

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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Receipts and Items"),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          onTap: () async {
                            await dbh.clearTable();
                            setState(
                                () {}); // TODO: there must be a better way of notifying the framework of the change! Or put changes inside
                          },
                          child: const Text("Clear databases"))
                    ])
          ],
        ),
        body: Column(children: [
          SizedBox(
            height: 500,
            width: 300,
            child: FutureBuilder<List<Receipt>>(
              future: DataBaseHelper.instance.getReceipts(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Receipt>> snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.hasError)
                    print(snapshot
                        .error); // TODO: proper connectionState sampling logic necessary
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
                                    snapshot.data![index].dateTime.toString(),
                                onTapCallback: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReceiptItemListView(
                                                ReceiptUuid:
                                                    snapshot.data![index].uuid,
                                              )));
                                });
                          });
                }
              },
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text("Add receipt"),
          ),
          TextButton(
            onPressed: () {},
            child: Text("Remove receipt"),
          ),
        ]),
        floatingActionButton: FloatingActionButton(onPressed: () async {
          Receipt r = rrg.randomReceipt(3);
          await DataBaseHelper.instance.addReceipt(r);
          await DataBaseHelper.instance.addReceiptItems(r.receiptItemsList);
          setState(
              () {}); // TODO: there must be a better way of notifying the framework of the change! Or put changes inside
        }));
  }
}
