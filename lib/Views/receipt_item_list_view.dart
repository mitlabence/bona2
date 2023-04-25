import 'dart:typed_data';

import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  late List<ReceiptItem> receiptItemList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: 500,
        width: 300,
        child: FutureBuilder<List<ReceiptItem>>(
          future: DataBaseHelper.instance.getReceiptItems(widget.ReceiptUuid),
          builder: (BuildContext context,
              AsyncSnapshot<List<ReceiptItem>> snapshot) {
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
                          title: snapshot.data![index].rawText ?? "NaN",
                          subtitle: snapshot.data![index].totalPrice.toString(),
                          onTapCallback: () {},
                          onLongPressCallback: () {
                            DataBaseHelper dbh = DataBaseHelper.instance;

                          },
                        );
                      });
            }
          },
        ),
      ),
    );

    // TODO: calls a future function to build listView of ReceiptItems, the list we get from the ReceiptItems database with matching uuid.
  }
}
