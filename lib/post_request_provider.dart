import 'dart:convert';
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

Future<Map<String, dynamic>> getScanVerboseJSON(File file) async {
  const skipTaggun = true;
  // Get API key
  const String apiKeysPath = "assets/taggun/";
  // find AssetManifest.json on phone (?)
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  // get local (Android Studio) file paths
  final apiKeysJsonPath = json
      .decode(manifestJson)
      .keys
      .where((String key) => key.endsWith("apikeys.json")).toList();
  assert(apiKeysJsonPath.length == 1);
  final apiKeysLocalPath = await rootBundle.loadString(apiKeysJsonPath[0]);
  final String taggunApiKey = json.decode(apiKeysLocalPath)["taggunapi"]["key"];
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
    file.path,
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
