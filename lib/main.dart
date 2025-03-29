import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ongc_doctor_app/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDedt1kqvAps3EiIxyaCpjXBnwcjfAxpVg",
          authDomain: "ongc-app-pw.firebaseapp.com",
          projectId: "ongc-app-pw",
          storageBucket: "ongc-app-pw.firebasestorage.app",
          messagingSenderId: "16637486242",
          appId: "1:16637486242:web:488befca616f4155a223fb",
          databaseURL: "https://ongc-app-pw-default-rtdb.firebaseio.com/",

          //databaseURL: "https://ongchospital1009-default-rtdb.firebaseio.com/",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
