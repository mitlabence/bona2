import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bona2/DataStructures/receipt.dart';
import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

class MockAssetBundle extends Mock implements AssetBundle {}

class MockDirectory extends Mock implements Directory {}

void main() {
  late MockAssetBundle mockAssetBundle;


  group("Group test MockDirectory", () {
    late TaggunReceiptProvider taggunReceiptProvider;
    late List<FileSystemEntity> fileList;
    setUp(() {
      taggunReceiptProvider = TaggunReceiptProvider();
      const String mockJsonFilesPath = '/test/directory/';
      fileList = [
        File(path.join(mockJsonFilesPath, 'file1.json')),
        File(path.join(mockJsonFilesPath, 'file2.json')),
        File(path.join(mockJsonFilesPath, 'file3.json')),
        Directory(path.join(mockJsonFilesPath, 'subdir')),
      ];
    });
    test("Test override MockDirectory.list()", () async {
      // Mock the Directory.list and FileSystemEntity.path methods
      MockDirectory mockDirectory = MockDirectory();
      when(() => mockDirectory.list(recursive: false))
          .thenAnswer((_) => Stream<FileSystemEntity>.fromIterable(fileList));
      List<FileSystemEntity> result =
          await mockDirectory.list(recursive: false).toList();

      // Verify that the correct results are returned
      expect(result.length, 4);
      expect(result[0].path, '/test/directory/file1.json');
      expect(result[1].path, '/test/directory/file2.json');
      expect(result[2].path, '/test/directory/file3.json');
      expect(result[3].path, '/test/directory/subdir');
    });
  });

  group("Group test TaggunReceiptProvider providing taggun json results", () {
    late TaggunReceiptProvider taggunReceiptProvider;
    setUp(() {
      taggunReceiptProvider = TaggunReceiptProvider();
      taggunReceiptProvider.taggunJsonFilePath = "assets/taggun_test/";
    });
    test("Test taggunReceiptProvider", () async { // TODO: give proper name
      Receipt receipt = await taggunReceiptProvider.pickReceipt();
      print("Number of items: ${receipt.numberOfItems}");
      receipt.receiptItemsList.forEach((element) {print(element);});
      print(receipt.totalPrice);
      assert(receipt.numberOfItems > 0);
      // Based on what I see in this test:
      // TODO: Based on sum (totalPrice), remove items that have matching price.
      // TODO: Betrag and Summe lines, weight data as well as tax lines should
      //    not be items. Need classifier, probably.  Classify items too.
      // TODO: when reading out taggun, if rectangles match for two entries, take only one detected number as price, the one that comes last in the raw text. See lactose free milk example.
    });
  });

  group("Group test TaggunReceiptProvider loadReceipts", () {
    setUp(() {
      mockAssetBundle = MockAssetBundle();
      TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) {
        final Uint8List encoded =
            utf8.encoder.convert('{"Foo.ttf":["Foo.ttf"]}');
        return Future.value(encoded.buffer.asByteData());
      });
    });
    test('loadReceipts should correctly load JSON files', () async {
      // Mock the Directory.list and FileSystemEntity.path methods
      MockDirectory mockDirectory = MockDirectory();
      // TODO: decide if use MockDirectory with mock files, or all files in assets/taggun, or assets/taggun/single
      // when(() => mockDirectory.list(recursive: false))
      //     .thenAnswer((_) => Stream<FileSystemEntity>.fromIterable(fileList));
      // List<FileSystemEntity> result =
      //     await mockDirectory.list(recursive: false).toList();
      // when(() => mockAssetBundle.loadString('assets/taggun/', cache: false))
      //     .thenAnswer((_) => Future.value(mockJsonFilesList));
      // await taggunReceiptProvider.getTaggunJsonFiles();
      //
      // // Verify that taggunJsonFilesPath and taggunJsonFiles are correctly set
      // expect(taggunReceiptProvider.taggunJsonFilesPath, mockJsonFilesPath);
      // expect(taggunReceiptProvider.taggunJsonFiles.length, 3);
      // expect(taggunReceiptProvider.taggunJsonFiles[0],
      //     path.join(mockJsonFilesPath, 'file1.json'));
      // expect(taggunReceiptProvider.taggunJsonFiles[1],
      //     path.join(mockJsonFilesPath, 'file2.json'));
      // expect(taggunReceiptProvider.taggunJsonFiles[2],
      //     path.join(mockJsonFilesPath, 'file3.json'));
    });
  });
}
