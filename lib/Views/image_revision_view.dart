import 'dart:typed_data';
import 'package:bona2/Views/receipt_revision_view.dart';
import 'package:bona2/taggun_receipt_reader.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../DataStructures/receipt.dart';
import '../post_request_provider.dart';
import '../receipt_reader.dart';
import '../uuid_tools.dart';

class ImageRevisionView extends StatefulWidget {
  const ImageRevisionView({required this.imageFile, Key? key})
      : super(key: key);
  final XFile imageFile;

  @override
  State<ImageRevisionView> createState() => _ImageRevisionViewState();
}

class _ImageRevisionViewState extends State<ImageRevisionView> {
  Uint8List? imageData;

  // TODO: extract specific implementation of interface out of this class. provider should be passed as parameter?
  // Or maybe it does make sense to put it here to avoid overcomplicating
  // matters - receipt scanner API should be only called in this view.
  PostRequestProvider postRequestProvider = TaggunPostRequestProvider();
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      setState(() {
        imageData = bytes;
      });
    } catch (e) {
      // Handle any error that occurs while reading the bytes
      print('Error loading image: $e');
    }
  }

  showConfirmDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget submitButton = TextButton(
      child: Text("Submit"),
      // TODO: add sendRequest(imageFile!.path); from image_upload_view!
      // postTaggunVerbose(File file)  from post_request_provider. That file should be refactored into an implementaiton!
      onPressed: () async {
        //TODO: Navigator.pop() before moving to next window? Otherwise pressing back button ends up with same dialog
        // TODO: save resultsMap to local file! In emergency it should be recovered from local file.
        String uuidString = generateUuidString();
        Uint8List uuidBlob =
            uuidBytesListFromString(uuidString); // Uint8List is a blob in SQL
        String fnameJson = "$uuidString.json";
        String fnameJpeg = "$uuidString.jpeg";


        Map<String, dynamic> resultsMap =
        await postRequestProvider.postFile(widget.imageFile.path);
        String uploadedJsonPath =
            await uploadMapToDriveAsJson(resultsMap, fnameJson);
        print(uploadedJsonPath);
        ReceiptReader receiptReader = TaggunReceiptReader(json: resultsMap, uuid: uuidBlob);
        Receipt receipt = receiptReader.receipt;
        // Receipt receipt = Receipt.fromMapAndUuid(resultsMap, uuidBlob);
        print("Created receipt");
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ReceiptRevisionView(receipt: receipt)));
        } else {
          print("ImageRevisionView: Context not mounted!");
        }
        print("uploading image...");
        String uploadedImagePath =
        await uploadFileToDrive(File(widget.imageFile.path), fnameJpeg);
        print(uploadedImagePath);
      }, // TODO: add Taggun API call here. More generally, add API call here of Taggun-implementation of receipt OCR
    );
    /*
    // Old sendRequest function calling free ocr API
    Future<dynamic> sendRequest(String filePath) async {
      MultipartFile image = await MultipartFile.fromPath("file", filePath);
      final Uri uri = Uri.parse("https://api.ocr.space/parse/image");
      var requestBody = <String, String>{
        'apikey': globals.OcrApiKey,
        'isOverlayRequired':'false',
        'isTable':'true',
        'language': 'ger',
        'OCREngine':'2',
      };
      var request = MultipartRequest('POST', uri)
        ..fields.addAll(requestBody)
        ..files.add(image);
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      var r = await jsonDecode(respStr);
      print(response.statusCode);
      final directory = await getApplicationDocumentsDirectory();
      final File outputJson = File('${directory.path}/out.json');
      await outputJson.writeAsString(respStr);
      print(respStr);
      return r;
    }*/

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm action"),
      content: Text("Would you like to transcribe file (costs one coin)?"),
      actions: [
        cancelButton,
        submitButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      final image = Image.memory(imageData!);
      return Stack(
        children: <Widget>[
          image,
          Align(
            alignment: Alignment(0, .9),
            child: ButtonBar(
              // TODO: add theme! Create global app theme!
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                // TODO: on retry, delete temporal file?
                Material(
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                // TODO: onPressed(): add Dialog() are you sure? This will cost 1 coin... Then on yes it sends the taggun post request, moves to receipt_revision_view
                Material(
                  child: IconButton(
                    onPressed: () {
                      showConfirmDialog(context);
                    },
                    icon: const Icon(Icons.upload_file),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
