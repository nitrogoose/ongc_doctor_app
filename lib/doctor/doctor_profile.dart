import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';  // Assuming the Doctor model class is in the 'model/doctor.dart' file

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}



class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _doctorDatabase =
      FirebaseDatabase.instance.ref('Doctors'); 

  late Doctor doctor;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {  // called when widget first created
    super.initState();
    _loadDoctorData();
  }

  // Load doctor details from Firebase
  Future<void> _loadDoctorData() async {
    try {
      final userId = _auth.currentUser?.uid; // Fetch the current user's ID
      if (userId != null) {
        // Fetch data for the current user ID
        DatabaseEvent event = await _doctorDatabase.child(userId).once();
        final doctorData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (doctorData != null) {
          print(doctorData); // To check the structure of data
          setState(() {
            doctor = Doctor.fromMap(doctorData, userId); // Map to the Doctor object
            _isLoading = false;
          });
        } else {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      // Handle error, maybe show a message or retry option
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _hasError
              ? const Center(child: Text('Error loading data')) // Show error message
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        Row(
                          children: [
                            Container(
                              width: 115,
                              height: 115,
                              decoration: BoxDecoration(
                                color: const Color(0xffF0EFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: doctor.profileImageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        doctor.profileImageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 60, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${doctor.firstName} ${doctor.lastName}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'From: ${doctor.city}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xffFA9600),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Contact Information Section
                        Text(
                          'Contact Information',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phone: ${doctor.phoneNumber}',
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Years of Experience: ${doctor.yearsOfExperience}',
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Qualification: ${doctor.qualification}',
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reviews: ${doctor.numberOfReviews} reviews | Rating: ${(doctor.totalReviews / doctor.numberOfReviews).toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
}
