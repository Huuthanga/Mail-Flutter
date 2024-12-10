import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code/screen/phone_registration_screen.dart';
import 'package:code/screen/otp_verification_screen.dart';
import 'package:code/screen/login_screen.dart';
import 'package:code/screen/setting/theme_provider.dart'; // Tạo một provider quản lý theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAG-Z5eJesCZrHIwJ0qwS67fF4jiVZi3LQ",
        authDomain: "clone-b96c3.firebaseapp.com",
        projectId: "clone-b96c3",
        storageBucket: "clone-b96c3.firebasestorage.app",
        messagingSenderId: "778774618725",
        appId: "1:778774618725:web:219db961efb1d7dc275c8c"
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(), 
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme, 
            darkTheme: themeProvider.darkTheme, 
            themeMode: themeProvider.themeMode, 
            home: LoginScreen(),
          );
        },
      ),
    );
  }
}
