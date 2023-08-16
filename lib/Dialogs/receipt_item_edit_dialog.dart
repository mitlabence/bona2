import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:bona2/constants.dart';
import 'package:flutter/material.dart';

// TODO add ShoppingItem values in a database (this should be the item category; also rename ShoppingItem to ItemCategory?). Add dropdown kind of menu (search for the item category by typing?)


class ReceiptItemEditDialog extends StatefulWidget {
  const ReceiptItemEditDialog({required this.receiptItem, Key? key})
      : super(key: key);
  final ReceiptItem receiptItem;

  @override
  State<ReceiptItemEditDialog> createState() => _ReceiptItemEditDialogState();
}

class _ReceiptItemEditDialogState extends State<ReceiptItemEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _rawTextController;
  // late NumberFormat _unitsController;
  late TextEditingController _quantityController;
  late TextEditingController _totalPriceController;
  late String unit;
  late num totalPrice;
  late String currency;

  @override
  void initState() {
    super.initState();

    unit = widget.receiptItem.unit!;
    totalPrice = widget.receiptItem.totalPrice;
    currency = widget.receiptItem.currency;
    _titleController =
        TextEditingController(text: widget.receiptItem.shoppingItem.itemName);
    _rawTextController =
        TextEditingController(text: widget.receiptItem.rawText);
    _quantityController =
        TextEditingController(text: widget.receiptItem.quantity.toString());
    _totalPriceController = TextEditingController(text: totalPrice.toString());

  }

  @override
  void dispose() {
    _titleController.dispose();
    _rawTextController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Content'),
      content: Column(
        children: [
          TextField(controller: _titleController),
          TextField(controller: _rawTextController),
          Row(children: [Expanded(
            flex: 2,
            child: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
            ),
          ),
            Expanded(
              flex: 1,
              child: DropdownButton(
                value: unit,
                items: kReceiptItemUnitsList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    unit = value!;
                  });
                },
              ),
            ),]),

          Row(children: [Expanded(
            flex: 2,
            child: TextField(
              controller: _totalPriceController,
              keyboardType: TextInputType.number,
            ),
          ),
            Expanded(
              flex: 1,
              child: DropdownButton(
                value: currency,
                items: kCurrenciesList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    currency = value!;
                  });
                },
              ),
            ),]),

        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save the edited content
            ReceiptItem editedValue = widget.receiptItem;
            Navigator.pop(context,
                editedValue); // Close the dialog and return the edited value
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
