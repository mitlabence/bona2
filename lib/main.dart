import 'dart:convert';
import 'package:bona2/Development/taggun_receipt_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Views/camera_view.dart';
import 'Views/image_upload_view.dart';
import 'Views/receipts_overview.dart';
import 'firestore_helper.dart';
import 'global.dart' as globals;
import 'Views/visualization_view.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import "package:bona2/google_auth.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:firebase_app_check/firebase_app_check.dart';
import 'global.dart';

// import 'package:bona2/global.dart';
late List<CameraDescription> _cameras;

// TODO: if decide to use TensorFlow Lite models, can use Firebase for deployment
Future<void> main() async {
  //Database dbReceipts = await openDatabase("receipts.db");
  //Database dbReceiptItems = await openDatabase("receiptitems.db");
  WidgetsFlutterBinding.ensureInitialized();
  TaggunReceiptProvider()
      .loadTaggunJsonFiles(); // Initialize singleton instance
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _cameras = await availableCameras();
  final String apikeys = await rootBundle.loadString('assets/apikeys.json');
  final apiKeysJson = jsonDecode(apikeys);
  globals.OcrApiKey = apiKeysJson["ocrapi"]["key"];
  globals.googleMapAPIKey = apiKeysJson["googlemapapi"]["key"]; // TODO: restrict permissions
  // TODO: https://www.youtube.com/watch?v=noi6aYsP7Go 8:07. Add functions for database operations, test them in ReceiptView screen.
  // FIXME: Unhandled Exception: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
  // MAybe: https://stackoverflow.com/questions/54557479/flutter-and-google-sign-in-plugin-platformexceptionsign-in-failed-com-google
  final userCredential = await signInWithGoogle();
  if (userCredential.user == null) {
    // TODO: proper handling of sign-in error
    throw Exception("Authentication failed. User is null!");
  } else {
    firebaseUid = userCredential.user!.uid;
    FireStoreHelper fsh = FireStoreHelper();
    fsh.initializeUser();  // If user collection does not exist yet, create it
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. debug provider
      // 2. safety net provider
      // 3. play integrity provider
      androidProvider: AndroidProvider.debug,
    ); // https://firebase.google.com/docs/app-check/flutter/default-providers
    firebaseAppCheckToken = (await FirebaseAppCheck.instance.getToken())!;
    // FIXME: null check should not be forced...
  }
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
    ProviderScope( child: VisualizationView(),),
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.blue,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Visualization',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
