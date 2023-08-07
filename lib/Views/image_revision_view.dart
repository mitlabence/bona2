import 'dart:typed_data';
import 'package:bona2/style_constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImageRevisionView extends StatefulWidget {
  const ImageRevisionView({required this.imageFile, Key? key})
      : super(key: key);
  final XFile imageFile;

  @override
  State<ImageRevisionView> createState() => _ImageRevisionViewState();
}

class _ImageRevisionViewState extends State<ImageRevisionView> {
  Uint8List? imageData;

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
      onPressed:  () {Navigator.of(context).pop();},
    );
    Widget submitButton = TextButton(
      child: Text("Submit"),
      // TODO: add sendRequest(imageFile!.path); from image_upload_view!
      // postTaggunVerbose(File file)  from post_request_provider. That file should be refactored into an implementaiton!
      onPressed:  () {}, // TODO: add Taggun API call here. More generally, add API call here of Taggun-implementation of receipt OCR
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
                    onPressed: () {showConfirmDialog(context);},
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
