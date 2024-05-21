import 'package:bona2/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../DataStructures/receipt.dart';
import '../DataStructures/receipt_item.dart';
import '../constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


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
  final _placeTextController = TextEditingController();
  late Receipt receipt;
  late String paymentType;
  late String currency;
  late TextEditingController _totalPriceController;
  late DateTime selectedDate;
  final sessionToken = const Uuid().v4();
  late String leadingLocationSuggestion;
  List<dynamic>_placeList = [];
  // TODO: add Google Map pick store function?
  // TODO: add autocomplete for country and city?
  // TODO: add database of visited stores?
  @override
  void initState() {
    super.initState();
    receipt = widget.receipt;
    currency = receipt.currency;
    print(currency.toString());
    selectedDate = receipt.dateTime;
    _totalPriceController =
        TextEditingController(text: receipt.totalPrice.toString());
    _placeTextController.addListener(_onPlaceTextChanged);
  }

  Future<void> _onPlaceTextChanged() async {
    if (_placeTextController.text.length > 3) {
      await getLocationResults(_placeTextController.text);
      print("Called API with text ${_placeTextController.text}");
    }
  }

  Future<void> getLocationResults(String input) async {
    String baseURL =
    "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    // TODO: set types to other stores as well (if store is not the general
    // term? https://developers.google.com/maps/documentation/places/android-sdk/supported_types
    String request =
    "$baseURL?input=$input&key=$googleMapAPIKey&types=store&sessiontoken=$sessionToken";
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
    setState(() {
    _placeList = json.decode(response.body)["predictions"];
    print("${_placeList.length} Predictions arrived");
    print("${_placeList[0]}");
    });
    } else {
    throw Exception("Failed to load predictions");
    }
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    _placeTextController.dispose();
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
          TextField(
            controller: _placeTextController,
              onTap: () async {
              },
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                ),
                hintText: "Enter shop address",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
              ),
          )
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
          child: const Text('Done'),
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

