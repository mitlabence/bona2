import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../DataStructures/receipt.dart';
import '../DataStructures/receipt_item.dart';
import '../constants.dart';

class AllReceiptItemsEditDialog extends StatefulWidget {
  AllReceiptItemsEditDialog({required this.receipt, Key? key})
      : super(key: key);
  Receipt receipt;

  @override
  State<AllReceiptItemsEditDialog> createState() =>
      _AllReceiptItemsEditDialogState();
}

// TODO: implement few changes to receipt, and if there are changes,
//  update the whole receipt, including the receipt items! (like currency). Need to pass receiptitems list, too!
class _AllReceiptItemsEditDialogState extends State<AllReceiptItemsEditDialog> {
  late Receipt receipt;
  late String currency;
  late TextEditingController _totalPriceController;

  @override
  void initState() {
    super.initState();
    print("Init called");
    receipt = widget.receipt;
    currency = receipt.currency;
    _totalPriceController =
        TextEditingController(text: receipt.totalPrice.toString());
    print(receipt.totalPrice.toString());
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit general data"),
      content: Column(
        children: [
          Text("Total price:"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 40,
                width: 80,
                child: TextField(
                  controller: _totalPriceController,
                  keyboardType: TextInputType.number,
                ),
              ),
              DropdownButton(
                value: currency,
                items: kCurrenciesList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      currency = value;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.pop(context, null); // Return null instead of tuple2
            }
            // Close the dialog  , Navigator.pop(context, Tuple2(pk, receipt));
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save the edited content
            for (int i = 0; i < receipt.receiptItemsList.length; i++) {
              receipt.receiptItemsList[i].currency = currency;
            }
            setState(() {
              receipt.currency = currency;
            });
            //Receipt editedReceipt
            if (context.mounted) {
              Navigator.pop(context,
                  receipt // Return changed receipt and receiptItems as tuple
                  ); // Close the dialog and return the edited value Tuple2(widget.pk, editedValue, markedForDelete? EditStatus.deleted : EditStatus.changed)
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
