import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// tasks from bona1
//TODO: replace print() with assert stuff! Should start unit testing...
//TODO: upon loading new image, clear the detected blocks! Create a void function in MLApi.
//TODO: upon navigating to other view (Scan), keep opened image in cache! So coming back to Upload, the same image is shown.
//TODO: set boxes clickable. Change color to red or something.
//TODO: once clickable boxes: user should click all boxes that contain elements and corresponding prices. Maybe: several buttons appear, like
// "items", "prices", "final price", "date"... and for each property, the user shows the corresponding selected rectangles.
//TODO: check lines. For each box (block), there should be a way to print the lines...

// tasks from bona2:
// TODO: format output json file with 2 space padding.
// TODO: save output json file in google cloud
// TODO: try opening cache/response_20230429_164400.json
// TODO: add "are you sure" pop-up window after taking photo
// TODO: handle error codes properly! (403: authorization error, wrong apikey, for example)

//TODO: upload image to cloud storage, then server handles decoding into json (with taggun or whatever)?
abstract class PostRequestProvider {
  Future<String?> getApiKey();

  Future<Map<String, dynamic>> postFile(String filePath);
}

Future<String?> getApiKeyWithName(String apiKeyName) async {
  /// Current keys in apikeys.json:
  ///   "ocrapi"
  ///   "taggunapi"
  ///   "clouduuid"
  ///
  // find AssetManifest.json on phone (?)
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  // get local (Android Studio) file paths
  final apiKeysJsonPath = json
      .decode(manifestJson)
      .keys
      .where((String key) => key.endsWith("apikeys.json"))
      .toList();
  assert(apiKeysJsonPath.length == 1);
  final apiKeysLocalPath = await rootBundle.loadString(apiKeysJsonPath[0]);
  final Map<String, dynamic> apiKeysJson = json.decode(apiKeysLocalPath);
  if (apiKeysJson.keys.contains(apiKeyName)) {
    return apiKeysJson[apiKeyName]["key"];
  } else {
    return null;
  }
}

class TaggunPostRequestProvider implements PostRequestProvider {
  @override
  Future<String?> getApiKey() async {
    return await getApiKeyWithName("taggunapi");
  }

  @override
  Future<Map<String, dynamic>> postFile(String filePath) async {
    final String? taggunApiKey = await getApiKey();
    if (taggunApiKey == null) {
      throw Exception("postTaggunVerbose: No taggun api key found!");
    } else {
      /*
  Curl:
  curl -X 'POST' \
  'https://api.taggun.io/api/receipt/v1/verbose/file' \
  -H 'accept: application/json' \
  -H 'apikey: 6c7a0d70a17011ec8215c512ccf27e54' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@20220420_175835.jpg;type=image/jpeg' \
  -F 'refresh=false' \
  -F 'incognito=false' \
  -F 'extractTime=true' \
  -F 'subAccountId=mitlabence' \
  -F 'referenceId=t0000003'
   */
      //TODO: add subAccountId and referenceId!
      print("getScanVerboseJSON: initializing request");
      var j;
      final Uri apiUri =
          Uri.parse("https://api.taggun.io/api/receipt/v1/verbose/file");
      //final data = await file.readAsBytes();
      var request = http.MultipartRequest("POST", apiUri);
      request.headers['content-type'] = 'multipart/form-data';
      print("taggunApiKey:$taggunApiKey");
      request.headers['apikey'] = taggunApiKey;
      request.fields["extractTime"] = "true"; //TODO: Test this
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ));
      print("getScanVerboseJSON: request sent");
      await request.send().then(
        (result) async {
          await http.Response.fromStream(result).then((response) {
            print(
                "getScanVerboseJSON response status code: ${response.statusCode}");
            if (response.statusCode == 200) {
              j = jsonDecode(response.body);
              //return j; //FIXME: for some reason, this does not return from the whole function. Should I leave this "return j" here? I guess it is needed because of the await?
              print("getScanVerboseJSON: successful!");
            } else {
              print("getScanVerboseJSON: getting JSON from image failed!");
              print("header:");
              print(response.headers);
              print("reason:");
              print(response.reasonPhrase);
              print("body:");
              print(response.body);

              //return Map(); // TODO: check if this is a valid solution
            }
          });
        },
      );
      print(j.toString());
      final documentsPath = await getApplicationDocumentsDirectory();
      final exportFile = File('${documentsPath.path}/data.json');
      final encodedJson = json.encode(j);
      await exportFile.writeAsString(encodedJson);
      //TODO: add json formatting!
      return j;
      print("Getting JSON from image failed fatally. Returning Map()");
      return Map(); // TODO: check if this is a valid solution
    }
  }
}

Future<Uint8List?> loadFileFromDrive(String fileName) async {
  final String? userCloudId = await getApiKeyWithName("clouduuid");
  if (userCloudId == null) {
    throw Exception("User Cloud ID not found!");
  } else {
    final storage = FirebaseStorage.instance;
    print("found storage");
    final userFolderRef = storage.ref().child(userCloudId);
    print("Found folder");
    final requestedFileRef = userFolderRef.child(fileName);
    try {
      final file = await requestedFileRef.getData();
      return file;
    }
    on PlatformException catch (e) { // If no file with given name, PlatformException is thrown by Firebase
      print("File not found");
      return null;
    }
  }
}

Future<Map<String, dynamic>?> loadJsonFromDrive(String fileName) async {
  final Uint8List? file = await loadFileFromDrive(fileName);
  //final js = json.encode(file);
  if (file != null) {
    var js = utf8.decode(file!);
    return json.decode(js);
  } else {
    return null;
  }
}

Future<String> uploadFileToDrive(File file, String filename) async {
  final String? userCloudId = await getApiKeyWithName("clouduuid");
  if (userCloudId == null) {
    throw Exception("User Cloud ID not found!");
  } else {
    assert(filename.endsWith(".jpeg"));
    final storage = FirebaseStorage.instance;
    print("found storage");
    final userFolderRef = storage.ref().child(userCloudId);
    print("Found folder");
    // TODO: handle already existing filename? There might be a performance issue? Not expecting high frequency of uploading...
    final newFileRef = userFolderRef.child(filename);
    print("Found file ref");
    Uint8List fileBytesData = await file.readAsBytes();
    print("Got file data");
    UploadTask uploadTask = newFileRef.putData(fileBytesData);
    print("upload task started");
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    print("Uploaded to $downloadUrl");
    return downloadUrl;
  }
}

Future<String> uploadMapToDriveAsJson(
    Map<String, dynamic> jsonMap, String filename) async {
  final String? userCloudId = await getApiKeyWithName("clouduuid");
  if (userCloudId == null) {
    throw Exception("User Cloud ID not found!");
  } else {
    assert(filename.endsWith(".json"));
    final storage = FirebaseStorage.instance;
    print("found storage");
    final userFolderRef = storage.ref().child(userCloudId);
    print("Found folder");
    final newJsonRef = userFolderRef.child(filename);
    print("Found file ref");
    // This produces a way too large file (~doubles the size) only for the sake
    // of beautifying the json file:
    //const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    //String jsonString = encoder.convert(jsonMap);
    String jsonString = json.encode(jsonMap);
    // TODO: maybe easier way to convert file?
    Uint8List jsonData = Uint8List.fromList(utf8.encode(jsonString));
    print("Got file data");
    print(newJsonRef.fullPath);
    UploadTask uploadTask = newJsonRef.putData(jsonData);
    // TODO: uploadTask throws error. File does not exist? no auth token for request?
    print("upload task started");
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    print("Uploaded to $downloadUrl");
    return downloadUrl;
  }
}
