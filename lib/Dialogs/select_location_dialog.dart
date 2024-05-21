import 'package:bona2/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// TODO: return new receipt on Save... Break up suggestions into city, country etc.
// TODO: what is the location reference? could include it in the database... but then need to migrate
// TODO: auto-search for location? if not found, ask user to find location
// TODO: FAB for cancel, otherwise can click on select one location? What if no location found? does Google return not found string as answer?
class SelectLocationDialog extends StatefulWidget {
  const SelectLocationDialog({Key? key}) : super(key: key);

  @override
  State<SelectLocationDialog> createState() => _SelectLocationDialogState();
}

class _SelectLocationDialogState extends State<SelectLocationDialog> {
  final _placeTextController = TextEditingController();
  final sessionToken = const Uuid().v4();
  late String leadingLocationSuggestion;
  List<dynamic> _suggestionsList = [];

  @override
  void initState() {
    super.initState();
    _placeTextController.addListener(_onPlaceTextChanged);
  }

  Future<void> _onPlaceTextChanged() async {
    // require minimum user-typed text length
    if (_needNewSuggestions()) {
      // if no suggestions yet or the user text differs from leading suggestion, get new suggestions
      await getLocationResults(_placeTextController.text);
    }
  }

  bool _needNewSuggestions() {
    // Need new suggestions if
    // 1. user text is long enough and
    // 2. user text contains new information compared to first suggestion
    String userText = _placeTextController.text.toLowerCase();
    if (userText.length <= 3) {
      return false;
    }
    // 1. user text is long enough. Check if it has new information
    // compared to suggestion.
    if (_suggestionsList.isEmpty) {
      return true;
    } else {
      String firstSuggestion = _suggestionsList[0].toLowerCase();
      // break up user entry into words separated by spaces
      List<String> userWords = userText.split(RegExp(r'\s+'));
      for (String word in userWords) {
        if (!firstSuggestion.contains(word)) {
          return true;
        }
      }
    }
    return false;
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
      // "description": comma separated list
      //"place_id": check what this is (string
      //"types": shows types of location

      List<dynamic> response_maps = json.decode(response.body)["predictions"];
      print("Updated _placeList");
      setState(() {
        _suggestionsList = response_maps.map((e) => e["description"]).toList();
      });
    } else {
      throw Exception("Failed to load predictions");
    }
  }

  @override
  void dispose() {
    _placeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set location")),
      body: Column(
        children: [
          TextField(
            controller: _placeTextController,
            onTap: () async {},
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
          ),
          Expanded(
              child: _suggestionsList.isEmpty
                  ? Center(child: Text("No suggestions."))
                  : ListView.builder(
                      itemCount: _suggestionsList.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      prototypeItem: ListTile(title: Text("")),
                      itemBuilder: (context, index) =>
                          ListTile(title: Text(_suggestionsList[index])))),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pop(
                        context, null); // Return null instead of tuple2
                  }
                  // Close the dialog  , Navigator.pop(context, Tuple2(pk, receipt));
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save the edited location
                  setState(() {
                    //print(receipt.totalPrice);
                  });
                  //Receipt editedReceipt
                  if (context.mounted) {
                    //Navigator.pop(context,
                    //    receipt // Return changed receipt and receiptItems as tuple
                    //); // Close the dialog and return the edited value Tuple2(widget.pk, editedValue, markedForDelete? EditStatus.deleted : EditStatus.changed)
                  }
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
