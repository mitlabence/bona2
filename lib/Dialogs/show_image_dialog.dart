import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowImageDialog extends StatefulWidget {
  const ShowImageDialog({required this.imageData, Key? key}) : super(key: key);
  final Uint8List imageData;

  @override
  State<ShowImageDialog> createState() => _ShowImageDialogState();
}

class _ShowImageDialogState extends State<ShowImageDialog> {
  late Image image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = Image.memory(widget.imageData);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      title: const Text("Review image"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            image,
            Align(
              alignment: Alignment(0, .9),
              child: ButtonBar(
                // TODO: add theme! Create global app theme!
                alignment: MainAxisAlignment.end,
                children: <Widget>[
                  // TODO: on retry, delete temporal file?
                  Material(
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
