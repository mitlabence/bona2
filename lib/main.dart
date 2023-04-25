import 'dart:convert';
import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'Views/camera_view.dart';
import 'Views/image_upload_view.dart';
import 'Views/receipts_overview.dart';
import 'global.dart' as globals;

// import 'package:bona2/global.dart';
late List<CameraDescription> _cameras;

Future<void> main() async {
  //Database dbReceipts = await openDatabase("receipts.db");
  //Database dbReceiptItems = await openDatabase("receiptitems.db");
  WidgetsFlutterBinding.ensureInitialized();
  TaggunReceiptProvider()
      .loadTaggunJsonFiles(); // Initialize singleton instance

  _cameras = await availableCameras();
  final String apikeys = await rootBundle.loadString('assets/apikeys.json');
  final apiKeysJson = jsonDecode(apikeys);
  globals.OcrApiKey = apiKeysJson["ocrapi"]["key"];
  // TODO: https://www.youtube.com/watch?v=noi6aYsP7Go 8:07. Add functions for database operations, test them in ReceiptView screen.
  runApp(const BonaApp());
}

class BonaApp extends StatelessWidget {
  const BonaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bona 2.0',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.red,
        ),
        initialRoute: '/upload',
        routes: {
          '/live': (context) => MyHomePage(
                initialNavBarIndex: 0,
                title: 'Bona 2.0',
              ),
          '/upload': (context) => MyHomePage(
                initialNavBarIndex: 1,
                title: 'Bona 2.0',
              ),
          '/imageview': (context) => ImageUploadView(),
          '/list': (context) => ReceiptsOverview(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  final int? initialNavBarIndex;

  MyHomePage({
    Key? key,
    this.initialNavBarIndex,
    required String title,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex; //TODO: use enum instead?
  static final List<Widget> _widgetOptions = <Widget>[
    //CameraView(title: "Camera", cameras: cameras, customPaint: null, onImage: (inputImage) { },),
    CameraView(
      cameras: _cameras,
    ),
    ImageUploadView(),
    const ReceiptsOverview(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialNavBarIndex != null) {
      _selectedIndex = widget.initialNavBarIndex!;
    } else {
      _selectedIndex = 1; //start on upload by default
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bona"),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.center_focus_weak),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sd_card),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Receipts',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
