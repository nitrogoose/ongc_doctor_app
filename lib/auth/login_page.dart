import 'package:flutter/material.dart';
import 'package:ongc_doctor_app/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ongc_doctor_app/doctor/doctor_home_page.dart';
import 'package:ongc_doctor_app/patient/patient_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _isNavigation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Message
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Welcome!\nLogin First',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => email = val, // This sets the email value whenever the user types into the field.
                      validator: (val) => // validates, ensures email is not empty
                          val!.isEmpty ? 'Enter an email address' : null,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      onChanged: (val) => password = val,
                      validator: (val) => val!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0064FA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Register Text Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'New User? Register',
                        style: TextStyle(
                          color: Color(0xff0064FA),
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) { // If the user is authenticated (user != null),
        // it checks the user's data in the Firebase under the "Doctors" node using the user’s UID.
          DatabaseReference userRef = _database.child('Doctors').child(user.uid);
          DataSnapshot snapshot = await userRef.get();

          if (snapshot.exists) {
            _navigateToDoctorHome();
          } else { // if userid not in doctor node, checks patient
            userRef = _database.child('Patients').child(user.uid);
            snapshot = await userRef.get();
            if (snapshot.exists) {
              _navigateToPatientHome();
            } else {
              _showErrorDialog('User not found');
            }
          }
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDoctorHome() {
    if (!_isNavigation) {
      _isNavigation = true; // ensures navigation only happens once
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const DoctorHomePage(),
      ));
    }
  }

  void _navigateToPatientHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const PatientHomePage(),
      ));
    }
  }
}
