import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_details_page.dart';
import 'model/doctor.dart';
import 'widget/doctor_card.dart';

class CategoryDoctorListPage extends StatefulWidget {
  final String category;

  const CategoryDoctorListPage({super.key, required this.category});

  @override
  State<CategoryDoctorListPage> createState() => _CategoryDoctorListPageState();
}

class _CategoryDoctorListPageState extends State<CategoryDoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');   // reference to doctor node in firebase
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsByCategory(); // called when widget inserted into tree
  }

  Future<void> _fetchDoctorsByCategory() async {
    await _database.once().then((DatabaseEvent event) {  // retrieves doctor node once
      DataSnapshot snapshot = event.snapshot; // represents fetched data
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>; // snapshot value into map
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key); // converts map entry into doctor object
          if (doctor.category == widget.category) {
            tmpDoctors.add(doctor);
          }
        });
      }
      setState(() { // update state for UI refresh
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Doctors'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? Center(
                  child: Text(
                    'No doctors found in this category',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector( // tap functionality
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorDetailPage(doctor: _doctors[index]), // goes to doctor detailpage upon tap
                          ),
                        );
                      },
                      child: DoctorCard(doctor: _doctors[index]),
                    );
                  },
                ),
    );
  }
}
