import 'dart:convert';

import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:bona2/Views/image_revision_view.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bona2/global.dart' as globals;
import 'package:bona2/post_request_provider.dart';

class CameraView extends StatefulWidget {
  const CameraView({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController controller;
  late XFile? imageFile;

  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("Camera Access Denied");
            break;
          default:
            print("Camera Exception Other");
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
          child: const Icon(Icons.photo_camera),
        ),
        body: CameraPreview(controller));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
        });

        if (file != null) {
          showInSnackBar('Picture saved to ${file.path}');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ImageRevisionView(imageFile: imageFile!),
          ));
          //sendRequest(imageFile!.path);
          // TODO: Request should not be sent in camera_view! But only afte reviewing the image!
          //var results = sendRequestPlaceholder(imageFile!.path); // Do not use API for development yet.
        }
      }
    });
    // TODO: start testing https://ocr.space/ocrapi OCR Engine2/3 and Receipt scanning activated.
    // Need to use POST, as GET only allows to use URL. See Post parameters
    // Also need to lower file size to < 1 MB.
  }
  Future<dynamic> sendRequestPlaceholder(String filePath) async {
    var receiptJson = await TaggunReceiptProvider().pickJson();
    return receiptJson;
  }
  //TODO: clean up this mess code! Need to separate Taggun implementation from send request code.
  // Need to make sure what type is returned in the uncoupled taggun API POST request function,
  // And make all possible events in this function non-dynamic! I.e. know what is returned in each case.
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
    var r = await jsonDecode(respStr); // FIXME: need to figure out type of r for clean code!
    print(response.statusCode);
    final directory = await getApplicationDocumentsDirectory();
    final File outputJson = File('${directory.path}/out.json');
    await outputJson.writeAsString(respStr);
    print(respStr);
    return r;
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<XFile?> takePicture() async {
    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      final XFile xFile = await cameraController.takePicture();
      print("${xFile.path}");
      File file = File(xFile.path);
      return xFile;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }
}
