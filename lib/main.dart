import 'package:flutter/material.dart';

import 'blank_pixel.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAKMezJPIZPQ-lPz9abKBEj7sdYDAw1bTo",
          authDomain: "snake-bf2fd.firebaseapp.com",
          projectId: "snake-bf2fd",
          storageBucket: "snake-bf2fd.appspot.com",
          messagingSenderId: "69792545852",
          appId: "1:69792545852:web:f8913706079fe881695739",
          measurementId: "G-LE0SFBDL4V"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
    );
  }
}
