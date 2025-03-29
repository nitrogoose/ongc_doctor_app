import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ongc_doctor_app/doctor/doctor_home_page.dart';
import 'package:ongc_doctor_app/patient/patient_home_page.dart';
import 'package:ongc_doctor_app/auth/login_page.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for GoogleFonts

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    User? user = _auth.currentUser;

    if (user == null) {
      await Future.delayed(Duration(seconds: 3));
      _navigateToLogin();
    } else {
      DatabaseReference userRef = _database.child('Doctors').child(user.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        await Future.delayed(Duration(seconds: 2));
        _navigateToDoctorHome();
      } else {
        userRef = _database.child('Patients').child(user.uid);
        snapshot = await userRef.get();
        if (snapshot.exists) {
          await Future.delayed(Duration(seconds: 2));
          _navigateToPatientHome();
        } else {
          await Future.delayed(Duration(seconds: 2));
          _navigateToLogin();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xff0064FA),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 10.0),
                child: Text(
                  'ONGC MEDICARE',  // Add the missing text content
                  style: GoogleFonts.poppins(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ), // Text
              ), // Padding
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  textAlign: TextAlign.end,
                  'Transforming\nHealthcare',
                  style: GoogleFonts.poppins(fontSize: 28, color: Colors.white),
                ), // Text
              ), // Padding
              Image.asset(
                'assets/dna_image.png',
               // Image.network("https://raw.githubusercontent.com/barmangolap15/FlutterDoctorApp/refs/heads/master/assets/images/dna_image.png",
               // fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,

              ), // Image
            ], // Column
          ), // SingleChildScrollView
        ), // Container
      ), // Scaffold
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _navigateToDoctorHome() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorHomePage()));
  }

  void _navigateToPatientHome() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientHomePage()));
  }
}