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
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    print("Init called");
    receipt = widget.receipt;
    currency = receipt.currency;
    selectedDate = receipt.dateTime;
    _totalPriceController =
        TextEditingController(text: receipt.totalPrice.toString());
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
          const Text("Total price:"),
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
          Text(selectedDate.toString()),
          ElevatedButton(onPressed: () => _selectDate(context), child: const Text("Change date...")),
          ElevatedButton(onPressed: () => _selectTime(context), child: const Text("Change time...")),
          ElevatedButton(onPressed: () => _addUpCosts(context), child: const Text("Calculate total cost...")),
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
              if (selectedDate != null && selectedDate != receipt.dateTime) {
                receipt.dateTime = selectedDate;
              }
              receipt.totalPrice = double.parse(_totalPriceController.text);
              print(receipt.totalPrice);
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(context: context, firstDate: DateTime(2018, 1), lastDate: DateTime(2101));
    if (pickedDate != null && pickedDate != selectedDate) {
      // Keep the time data unchanged, only modify year, month and day
      final hour = selectedDate.hour;
      final minute = selectedDate.minute;
      final second = selectedDate.second;
      final millisec = selectedDate.millisecond;
      final year = pickedDate.year;
      final month = pickedDate.month;
      final day = pickedDate.day;
      final DateTime newDateTime = DateTime(year, month, day, hour, minute, second, millisec);
      setState(() {
        selectedDate = newDateTime;
      });
    }
  }
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute);  // The original time user wants to change
    final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: initialTime);
    if (pickedTime != null && pickedTime != initialTime) {
      // Keep date, only change time: hours and minutes
      final hour = pickedTime.hour;
      final minute = pickedTime.minute;
      final year = selectedDate.year;
      final month = selectedDate.month;
      final day = selectedDate.day;
      final DateTime newDateTime = DateTime(year, month, day, hour, minute);
      setState(() {
        selectedDate = newDateTime;
      });
    }
    }
  Future<void> _addUpCosts(BuildContext context) async {
    final num newTotalPrice = receipt.receiptItemsList.map((receiptItem) => receiptItem.totalPrice).reduce((totalPrice, itemPrice) => totalPrice + itemPrice);
    setState(() {
      _totalPriceController.text = newTotalPrice.toString();
    });
  }

}
