import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'homePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyArWDiPRjsi3cg9HU7fdfTsfVkI86luL6U",
      appId: "1:241077561918:android:96819fb45f41ad6838bf6f",
      messagingSenderId: "241077561918",
      projectId: "crudopration-7d8b1",
    ),
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}

