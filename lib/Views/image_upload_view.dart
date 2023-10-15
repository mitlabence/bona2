import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:bona2/Views/receipt_revision_view.dart';
import 'package:bona2/uuid_tools.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../DataStructures/receipt.dart';
import '../post_request_provider.dart';
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
      builder: (context) => ReceiptRevisionView(receipt: receipt),
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
      body: SizedBox(
        height: 500,
        width: 300,
        child: Column(
          children: <Widget>[
            TextButton(
              onPressed: () async {
                // TODO: put json file in cloud storage
                Receipt receipt = await taggunReceiptProvider.pickReceipt();
                // TODO: see https://stackoverflow.com/questions/68871880/do-not-use-buildcontexts-across-async-gaps
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ReceiptRevisionView(receipt: receipt)));
                } else {
                  print("ImageUploadView: Context not mounted!");
                }
                // DataBaseHelper dbh = DataBaseHelper.instance;
                // int responseReceipt = await dbh.addReceipt(r);
                // int responseReceiptItem = await dbh.addReceiptItems(r.receiptItemsList);
              },
              child: const Text("Add random receipt"),
            ),
            TextButton(
              onPressed: () async {
                var uuid = generateUuidString();
                String fname = "$uuid.json";
                Map<String, dynamic>? jsonData =
                    await taggunReceiptProvider.pickJson();
                if (jsonData != null) {
                  String uploadFilePath =
                      await uploadMapToDriveAsJson(jsonData, fname);
                }
              },
              child: const Text("Random json to cloud"),
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
            ElevatedButton(
              child: Text("Test pop to list"),
              //FIXME: app bar disappears when using navigator like this!
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/upload', (r) => false),
            ),
          ],
        ),
      ),
    );
  }
}
