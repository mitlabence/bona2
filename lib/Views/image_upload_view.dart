import 'dart:typed_data';

import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:bona2/Views/receipt_revision_view.dart';
import 'package:bona2/uuid_tools.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../DataStructures/receipt.dart';
import '../post_request_provider.dart';
import '../receipt_reader.dart';
import '../taggun_receipt_reader.dart';
import 'image_revision_view.dart';

//TODO: create abstract class/interface POST handler, create implementation for
// Taggun, add tests

class ImageUploadView extends StatefulWidget {
  const ImageUploadView({Key? key}) : super(key: key);

  @override
  State<ImageUploadView> createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  final TaggunReceiptProvider taggunReceiptProvider = TaggunReceiptProvider();

  void addReceiptCallback(BuildContext context, Receipt receipt) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          ReceiptRevisionView(receipt: receipt, imageData: null),
    ));
  }

  Future<XFile?> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Specify that only images should be picked
      allowMultiple: false, // Allow selecting only one image
    );
    if (result != null && result.files.isNotEmpty) {
      return XFile(result.files.single.path!);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final String uuidString = "";
                  print("loading json");
                  Map<String, dynamic>? json =
                      await loadJsonFromDrive("$uuidString.json");
                  print("loading image");

                  Uint8List? imageData =
                      await loadFileFromDrive("$uuidString.jpeg");
                  if (json == null) {
                    print("json is null");
                  } else {
                    print(json.keys);
                    Uint8List uuidBlob = uuidBytesListFromString(uuidString);
                    if (imageData == null) {
                      print("imageData is null");
                    } else {
                      ReceiptReader receiptReader =
                          TaggunReceiptReader(json: json, uuid: uuidBlob);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ReceiptRevisionView(
                              receipt: receiptReader.receipt,
                              imageData: imageData)));
                    }
                  }
                },
                child: Text("Create receipt"),
              ),
              ElevatedButton(
                onPressed: () async {
                  _pickImage().then((XFile? file) {
                    XFile? imageFile;
                    if (mounted) {
                      setState(() {
                        imageFile = file;
                      });

                      if (file != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ImageRevisionView(imageFile: imageFile!),
                        ));
                        //var results = sendRequestPlaceholder(imageFile!.path); // Do not use API for development yet.
                      }
                    }
                  });
                },
                child: Text("Pick image"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
