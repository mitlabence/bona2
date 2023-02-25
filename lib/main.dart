import 'package:flutter/material.dart';

import 'package:bona2/camera_handler.dart';
import 'package:bona2/constants.dart';

import 'Views/cameraview.dart';
import 'Views/imageuploadview.dart';
import 'Views/receiptoverview.dart';
// import 'package:bona2/global.dart';


Future<void> main() async {
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
        '/live': (context) => const MyHomePage(
          initialNavBarIndex: 0, title: 'Bona 2.0',
        ),
        '/upload': (context) => const MyHomePage(
          initialNavBarIndex: 1, title: 'Bona 2.0',
        ),
        '/imageview': (context) => const ImageUploadView(),
        '/list': (context) => const ReceiptOverView(),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int? initialNavBarIndex;

  const MyHomePage({
    Key? key,
    this.initialNavBarIndex, required String title,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex; //TODO: use enum instead?
  static final List<Widget> _widgetOptions = <Widget>[
    //CameraView(title: "Camera", cameras: cameras, customPaint: null, onImage: (inputImage) { },),
    const CameraView(),
    const ImageUploadView(),
    const ReceiptOverView(),
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
