import 'package:bona2/DataStructures/receipt_item.dart';
import 'package:bona2/constants.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../DataStructures/shopping_item.dart';

// TODO add ShoppingItem values in a database (this should be the item category; also rename ShoppingItem to ItemCategory?). Add dropdown kind of menu (search for the item category by typing?)

class ReceiptItemEditDialog extends StatefulWidget {
  /// Given a ReceiptItem receiptItem, its identifier index in a list (for backtracking which item changed),
  /// show a dialog to edit its details.
  const ReceiptItemEditDialog(
      {required this.receiptItem, required this.index, Key? key})
      : super(key: key);
  final ReceiptItem receiptItem;
  final dynamic index;

  @override
  State<ReceiptItemEditDialog> createState() => _ReceiptItemEditDialogState();
}

class _ReceiptItemEditDialogState extends State<ReceiptItemEditDialog> {
  late TextEditingController _itemCategoryController;
  late TextEditingController _rawTextController;

  // late NumberFormat _unitsController;
  late TextEditingController _quantityController;
  late TextEditingController _totalPriceController;
  late String unit;
  late num totalPrice;
  late String currency;
  late ItemCategory itemCategory;

  bool markedForDelete = false;

  @override
  void initState() {
    super.initState();

    unit = widget.receiptItem.unit!;
    totalPrice = widget.receiptItem.totalPrice;
    currency = widget.receiptItem.currency;
    itemCategory = widget.receiptItem.itemCategory;
    _itemCategoryController =
        TextEditingController(text: widget.receiptItem.itemCategory.itemName);
    _rawTextController =
        TextEditingController(text: widget.receiptItem.rawText);
    _quantityController =
        TextEditingController(text: widget.receiptItem.quantity.toString());
    _totalPriceController = TextEditingController(text: totalPrice.toString());
  }

  @override
  void dispose() {
    _itemCategoryController.dispose();
    _rawTextController.dispose();
    _quantityController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Content'),
      content: Column(
        children: [
          Text("Category:"),
          TextField(controller: _itemCategoryController),
          const Text("Raw text:"),
          TextField(controller: _rawTextController),
          Row(children: [
            Expanded(
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
            ),
          ]),
          Row(children: [
            Expanded(
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
            ),
          ]),
      Row(
        children:
          [
            const Text("Delete?"),
            Checkbox(
              checkColor: Colors.white,
              value: markedForDelete,
              onChanged: (bool? value) {
                setState(() {
                  markedForDelete = value!;
                });
              },
            ),
          ],
      ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context,
                Tuple3(widget.index, widget.receiptItem, EditStatus.unchanged)); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save the edited content
            ReceiptItem editedValue = ReceiptItem(
                itemCategory:
                    ItemCategory(itemName: _itemCategoryController.text),
                rawText: _rawTextController.text,
                totalPrice: num.parse(_totalPriceController.text),
                quantity: num.parse(_quantityController.text),
                unit: unit,
                currency: currency,
                uuid: widget.receiptItem.uuid);

            Navigator.pop(
                context,
                Tuple3(widget.index,
                    editedValue, markedForDelete? EditStatus.deleted : EditStatus.changed)); // Close the dialog and return the edited value
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
