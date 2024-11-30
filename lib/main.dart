import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:code/screen/phone_registration_screen.dart';
import 'package:code/screen/otp_verification_screen.dart';
import 'package:code/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyDqJ2ejofU6wF7a3HfX82OmqN_QxhRQTdc",
  authDomain: "kuro-309ef.firebaseapp.com",
  projectId: "kuro-309ef",
  storageBucket: "kuro-309ef.firebasestorage.app",
  messagingSenderId: "173175777832",
  appId: "1:173175777832:web:d3c7f864cca64e2231631d",
  measurementId: "G-MB5Z73DPZL"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
