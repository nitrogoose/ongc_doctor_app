import 'dart:io';
import 'dart:typed_data';  // For handling image bytes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';  // For kIsWeb
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ongc_doctor_app/doctor/doctor_home_page.dart';
import 'package:ongc_doctor_app/patient/patient_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance used for user authentication 
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>(); // key that uniquely identifies the form widget and allows for form validation

  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'Guwahati';
  String profileImageUrl = '';
  String category = 'Dentist';
  String qualification = '';
  String yearsOfExperience = '';

  final _picker = ImagePicker();
  XFile? _imageFile;  // For mobile, we'll still use ImagePicker's XFile
  Uint8List? _imageBytes;  // For web, we'll store the image bytes

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Dropdown for User Type
                      DropdownButtonFormField(
                        value: userType,
                        items: ['Patient', 'Doctor'].map((String type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            userType = val as String;
                          });
                        },
                        decoration: InputDecoration(labelText: 'User Type'),
                      ),
                      // Email TextFormField
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val, // Updates the email variable when the user types.
                        validator: (val) =>
                            val!.isEmpty ? 'Enter an email address' : null,
                      ),
                      // Password TextFormField
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        onChanged: (val) => password = val,
                        validator: (val) => val!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      // Phone Number TextFormField
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => phoneNumber = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter a phone number' : null,
                      ),
                      // First Name TextFormField
                      TextFormField(
                        decoration: InputDecoration(labelText: 'First Name'),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => firstName = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter a first name' : null,
                      ),
                      // Last Name TextFormField
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Last Name'),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => lastName = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter a last name' : null,
                      ),
                      // Dropdown for City
                      DropdownButtonFormField(
                        value: city,
                        items: ['Guwahati', 'Delhi', 'Mumbai', 'Bangalore']
                            .map((String city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            city = val as String;
                          });
                        },
                        decoration: InputDecoration(labelText: 'City'),
                        validator: (val) => val == null ? 'Select a city' : null,
                      ),
                      // Button to upload profile image
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Upload profile image'),
                      ),
                      // Display the selected image
                      if (_imageFile != null)
                        Image.file(File(_imageFile!.path)) // For mobile
                      else if (_imageBytes != null)
                        Image.memory(_imageBytes!), // For web
                      // Show additional fields if user is a Doctor
                      if (userType == 'Doctor') ...[ 
                        // Qualification TextFormField
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Qualification'),
                          onChanged: (val) => qualification = val,
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter a qualification' : null,
                        ),
                        // Category Dropdown for Doctor
                        DropdownButtonFormField(
                          value: category,
                          items: ['Dentist', 'Cardiology', 'Oncology', 'Surgeon']
                              .map((String category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              category = val as String;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Category'),
                          validator: (val) => val == null ? 'Select a category' : null,
                        ),
                        // Years of Experience TextFormField
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Years of Experience'),
                          onChanged: (val) => yearsOfExperience = val,
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter years of experience' : null,
                        ),
                      ],
                      // Register Button
                      ElevatedButton(
                        onPressed: _register,
                        child: Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // For web, use file_picker to pick an image
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        // Store the image bytes for displaying on web
        setState(() {
          _imageBytes = result.files.single.bytes;  // Use the bytes directly
          _imageFile = null;  // Make sure no mobile-specific file is stored
        });
      } else {
        print('No image selected');
      }
    } else {
      // For mobile, use ImagePicker
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile; // Set picked file for mobile platforms
        _imageBytes = null;  // Make sure no web-specific bytes are stored
      });
    }
  }

  // Register function
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) { //The validate method checks whether all the form fields meet their respective validation criteria. If all the fields are valid, it returns true
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user; // if successful user object has info of new user

        if (user != null) { // user can be null in error case
          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients'; // stores data on correct node
          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            'profileImageUrl': profileImageUrl,
          };

          if (userType == 'Doctor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearsOfExperience;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await _database.child(userTypePath).child(user.uid).set(userData); // usertype is patient or doctor, sets accordingly

          if (_imageFile != null) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('$userTypePath/${user.uid}/profile.jpg');
            UploadTask uploadTask =
                storageReference.putFile(File(_imageFile!.path));
            TaskSnapshot taskSnapshot = await uploadTask;

            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            await _database.child(userTypePath).child(user.uid).update({
              'profileImageUrl': downloadUrl,
            });
          }

          if (_imageBytes != null) {
            // Handle Firebase upload for Web
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('$userTypePath/${user.uid}/profile.jpg');
            UploadTask uploadTask = storageReference.putData(_imageBytes!);
            TaskSnapshot taskSnapshot = await uploadTask;

            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            await _database.child(userTypePath).child(user.uid).update({
              'profileImageUrl': downloadUrl,
            });
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  userType == 'Doctor' ? DoctorHomePage() : PatientHomePage(),
            ),
          );
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
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
