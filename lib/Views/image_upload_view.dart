import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:bona2/Views/receipt_revision_view.dart';
import 'package:flutter/material.dart';

import '../DataStructures/receipt.dart';
import '../database_helper.dart';



//TODO: create abstract class/interface POST handler, create implementation for
// Taggun, add tests

class ImageUploadView extends StatelessWidget {
  ImageUploadView({Key? key}) : super(key: key);
  final TaggunReceiptProvider taggunReceiptProvider = TaggunReceiptProvider();

  void addReceiptCallback(BuildContext context, Receipt receipt) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReceiptRevisionView(receipt: receipt),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: 500,
        width: 300,
        child: Column(
          children: <Widget>[
            TextButton(
              onPressed: () async {
                Receipt receipt = await taggunReceiptProvider.pickJsonFile();
                //TODO: see https://stackoverflow.com/questions/68871880/do-not-use-buildcontexts-across-async-gaps
                if (context.mounted){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ReceiptRevisionView(receipt: receipt)));
                }
                else {
                  print("ImageUploadView: Context not mounted!");
                }
                // DataBaseHelper dbh = DataBaseHelper.instance;
                // int responseReceipt = await dbh.addReceipt(r);
                // int responseReceiptItem = await dbh.addReceiptItems(r.receiptItemsList);
              },
              child: const Text("Add random receipt"),
            ),
          ],
        ),
      ),
    );
  }
}
