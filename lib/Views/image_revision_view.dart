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

    bool submitted = false;

    // set up the AlertDialog

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String statusText = "Would you like to transcribe file?";
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Confirm action"),
            content: Text(statusText),
            actions: [
              // Cancel button
              TextButton(
                child: Text("Cancel"),
                onPressed: submitted
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
              ),
              TextButton(
                child: Text("Submit"),
                // TODO: add sendRequest(imageFile!.path); from image_upload_view!
                // postTaggunVerbose(File file)  from post_request_provider. That file should be refactored into an implementaiton!
                onPressed: submitted
                    ? null
                    : () async {
                  // TODO: need to test this thoroughly! No internet connection -> save to cache? (at any given step... before upload, during upload...)
                  // TODO: when moving to receipt review, receipt is already in Firebase Storage.... so should cache it too, in case user accidentally cancels, they could still
                  // open the edit when clicking on scan, as long as they don't press Discard there( Then remove from CLoud Storage). Could achieve by checking if a global cache receipt exists.
                        if (!submitted) {
                          // TODO: test! (replace api call with simple print)
                          setState(() {
                            submitted = true;
                          });
                          //TODO: Navigator.pop() before moving to next window? Otherwise pressing back button ends up with same dialog
                          // TODO: save resultsMap to local file! In emergency it should be recovered from local file.
                          // TODO: if dialog closed, one can open it again and submit for second time. Need to set time between submissions?
                          // FIXME: if dialog closed, error:
                          /*
                            I/flutter (30922): Backing up image to cloud...
                            E/flutter (30922): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: setState() called after dispose(): _StatefulBuilderState#8df37(lifecycle state: defunct, not mounted)
                            E/flutter (30922): This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree (e.g., whose parent widget no longer includes the widget in its build). This error can occur when code calls setState() from a timer or an animation callback.
                            E/flutter (30922): The preferred solution is to cancel the timer or stop listening to the animation in the dispose() callback. Another solution is to check the "mounted" property of this object before calling setState() to ensure the object is still in the tree.
                            E/flutter (30922): This error might indicate a memory leak if setState() is being called because another object is retaining a reference to this State object after it has been removed from the tree. To avoid memory leaks, consider breaking the reference to this object during dispose().
                            E/flutter (30922): #0      State.setState.<anonymous closure> (package:flutter/src/widgets/framework.dart:1167:9)
                            E/flutter (30922): #1      State.setState (package:flutter/src/widgets/framework.dart:1202:6)
                            E/flutter (30922): #2      _ImageRevisionViewState.showConfirmDialog.<anonymous closure>.<anonymous closure>.<anonymous closure> (package:bona2/Views/image_revision_view.dart:129:35)
                            E/flutter (30922): <asynchronous suspension>
                            E/flutter (30922):
                           */
                          String uuidString = generateUuidString();
                          Uint8List uuidBlob = uuidBytesListFromString(
                              uuidString); // Uint8List is a blob in SQL
                          String fnameJson = "$uuidString.json";
                          String fnameJpeg = "$uuidString.jpeg";

                          setState(() {
                            statusText = "Reading receipt...";
                          });
                          Map<String, dynamic> resultsMap =
                              await postRequestProvider
                                  .postFile(widget.imageFile.path);
                          String uploadedJsonPath =
                              await uploadMapToDriveAsJson(
                                  resultsMap, fnameJson);
                          print(uploadedJsonPath);
                          print("Backing up image to cloud...");
                          setState(() {
                            statusText = "Backing up image to cloud...";
                          });
                          String uploadedImagePath = await uploadFileToDrive(
                              File(widget.imageFile.path), fnameJpeg);
                          print(uploadedImagePath);
                          setState(() {
                            statusText = "Processing receipt entries...";
                          });
                          ReceiptReader receiptReader = TaggunReceiptReader(
                              json: resultsMap, uuid: uuidBlob);
                          Receipt receipt = receiptReader.receipt;
                          // Receipt receipt = Receipt.fromMapAndUuid(resultsMap, uuidBlob);
                          print("Created receipt");
                          setState(() {
                            statusText = "Created receipt.";
                          });
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ReceiptRevisionView(
                                    receipt: receipt, imageData: imageData)));
                          } else {
                            print("ImageRevisionView: Context not mounted!");
                          }
                        }
                      }, // TODO: add Taggun API call here. More generally, add API call here of Taggun-implementation of receipt OCR
              ),
            ],
          );
        });
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
