import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../DataStructures/receipt.dart';
import '../taggun_receipt_reader.dart';

class TaggunReceiptProvider {
  static final TaggunReceiptProvider _instance =
      TaggunReceiptProvider._internal();

  factory TaggunReceiptProvider() {
    return _instance;
  }

  static const String _defaultJsonFilesPath = "assets/taggun/";
  static const int _seed = 42;
  late String _taggunJsonFilesPath;
  late List<String> _taggunJsonFiles;
  final Random _rng = Random();

  TaggunReceiptProvider._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    _taggunJsonFilesPath = _defaultJsonFilesPath;
    // TODO: need to assert the sync function's result is available the next time we retrieve the files list!
  }

  String get taggunJsonFilesPath => _taggunJsonFilesPath;

  set taggunJsonFilePath(String path) {
    _taggunJsonFilesPath = path;
  }

  get taggunJsonFiles async => await loadTaggunJsonFiles();

  Future<List<String>> loadTaggunJsonFiles() async {
    // find AssetManifest.json on phone (?)
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    // get local (Android Studio) file paths
    _taggunJsonFiles = json
        .decode(manifestJson)
        .keys
        .where((String key) =>
            key.startsWith(taggunJsonFilesPath) & key.endsWith(".json"))
        .toList();
    /*
    String localTaggunJsonFilesPath = await rootBundle.loadString(taggunJsonFilesPath);
    Directory directory = Directory(localTaggunJsonFilesPath);
    List<FileSystemEntity> fileList = await directory.list().toList();
    taggunJsonFiles = [];
    for (FileSystemEntity file in fileList) {
      if (file is File && path.extension(file.path) == '.json') {
        taggunJsonFiles.add(file.path);
      }
    }
    */
    // Get file paths on phone
    // for (String localFilePath in taggunJsonFiles) {
    //   final filePath = await rootBundle.loadString(localFilePath, cache: false);
    //   File file = File(filePath);
    //   if (path.extension(file.path) == '.json') {
    //     //taggunJsonFiles.add(file.path);
    //     taggunJsonFiles.add(localFilePath);
    //   }
    // }

    assert(_taggunJsonFiles.isNotEmpty);
    return _taggunJsonFiles;
  }

  Future<Receipt> pickReceipt() async {
    try {
      final Map<String, dynamic>? json = await pickJson();
      if (json == null) {
        print("Error decoding json file. Returning empty receipt");
      } else {
        TaggunReceiptReader taggunReader = TaggunReceiptReader(json: json);
        return taggunReader.receipt;
      }
    } on FormatException catch (e) {
      print("Returning empty receipt");
    }
    return Receipt.empty();
  }

  Future<Map<String, dynamic>?> pickJson() async {
    await taggunJsonFiles; // Wait for taggun files to load
    assert(_taggunJsonFiles.isNotEmpty);
    final int indexFile = _rng.nextInt(_taggunJsonFiles.length);
    try {
      print("Index is $indexFile");
      final filePath = await rootBundle.loadString(_taggunJsonFiles[indexFile],
          cache: false);
      return jsonDecode(filePath);
    } on FormatException catch (e) {
      print(
          "Error decoding supposed json file at ${_taggunJsonFiles[indexFile]}: $e");
    }
  }
}
