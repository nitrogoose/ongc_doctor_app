import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_doctor_list_page.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';
import 'package:ongc_doctor_app/doctor/widget/doctor_card.dart';
import 'package:ongc_doctor_app/doctor/model/patient.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  final DatabaseReference _userDatabase =
      FirebaseDatabase.instance.ref().child('Patients');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Doctor> _doctors = [];
  bool _isLoading = true;
  Patient? _currentPatient;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchPatientInfo();
  }

  Future<void> _fetchDoctors() async { // snapshot to map to doctor object in loop
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() { // rebuilding widget
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchPatientInfo() async {
    String? currentUserUid = _auth.currentUser?.uid;
    if (currentUserUid != null) {
      await _userDatabase.child(currentUserUid).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> data = Map<String, dynamic>.from(
              snapshot.value as Map<dynamic, dynamic>);
          setState(() {
            _currentPatient = Patient.fromMap(data);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find your doctor,\nand book an appointment',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_currentPatient != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_currentPatient!.firstName} ${_currentPatient!.lastName}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'UID: ${_currentPatient!.uid}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _currentPatient!.city,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Loading patient info...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Cardiology', 'assets/heart.png'),
                      _buildCategoryCard(context, 'Oncologist', 'assets/onco.png'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Dentist', 'assets/dental.png'),
                      _buildCategoryCard(context, 'See All', 'assets/grid.png',
                          isHighlighted: true),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder( //  creates a list of doctor cards from the _doctors list.
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector( // passes category as argument
                          onTap: () {
                            // Navigate to doctor details
                          },
                          child: DoctorCard(doctor: _doctors[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String icon,
      {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDoctorListPage(category: title),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
          borderRadius: BorderRadius.circular(15),
          border: isHighlighted
              ? null
              : Border.all(color: const Color(0xffC8C4FF), width: 2),
        ),
        child: Card(
          color: isHighlighted ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isHighlighted ? Colors.white : const Color(0xff006AFA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






/*import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_doctor_list_page.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';
import 'package:ongc_doctor_app/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30.0),
                  Text(
                    'Find your doctor,\nand book an appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Cardiologist', 'assets/heart.png'),
                      _buildCategoryCard(context, 'Oncologist', 'assets/onco.png'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Dentist', 'assets/dental.png'),
                      _buildCategoryCard(context, 'See All', 'assets/grid.png',
                          isHighlighted: true),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to doctor details
                          },
                          child: DoctorCard(doctor: _doctors[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String icon,
      {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDoctorListPage(category: title),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
          borderRadius: BorderRadius.circular(15),
          border: isHighlighted
              ? null
              : Border.all(color: const Color(0xffC8C4FF), width: 2),
        ),
        child: Card(
          color: isHighlighted ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isHighlighted ? Colors.white : const Color(0xff006AFA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/



/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ongc_doctor_app/doctor/doctor_details_page.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';
import 'package:ongc_doctor_app/doctor/model/patient.dart';
import 'package:ongc_doctor_app/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _doctorDatabase =
      FirebaseDatabase.instance.ref().child('Doctors');
  final DatabaseReference _patientDatabase =
      FirebaseDatabase.instance.ref().child('Patients');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Doctor> _doctors = [];
  Patient? _patient;
  bool _isLoadingDoctors = true;
  bool _isLoadingPatient = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchPatientInfo();
  }

  Future<void> _fetchDoctors() async {
    await _doctorDatabase.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tempDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tempDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tempDoctors;
        _isLoadingDoctors = false;
      });
    });
  }

  Future<void> _fetchPatientInfo() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _patientDatabase.child(userId).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          final patientData = event.snapshot.value;
          if (patientData is Map) {
            setState(() {
              _patient = Patient.fromMap(Map<String, dynamic>.from(patientData));
              _isLoadingPatient = false;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoadingDoctors || _isLoadingPatient
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find your doctor,\nand book an appointment',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_patient != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Name: ${_patient!.firstName} ${_patient!.lastName}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'UID: ${_patient!.uid}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Location: ${_patient!.city}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          context, 'Cardiologist', 'assets/heart.png'),
                      _buildCategoryCard(
                          context, 'Oncologist', 'assets/onco.png'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          context, 'Dentist', 'assets/dental.png'),
                      _buildCategoryCard(
                          context, 'See All', 'assets/grid.png',
                          isHighlighed: true),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DoctorDetailPage(doctor: _doctors[index]),
                              ),
                            );
                          },
                          child: DoctorCard(doctor: _doctors[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildCategoryCard(BuildContext context, String title, dynamic icon,
    {bool isHighlighed = false}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    decoration: BoxDecoration(
        color: isHighlighed ? Color(0xff006AFA) : Color(0xffF0EFFF),
        borderRadius: BorderRadius.circular(15),
        border: isHighlighed
            ? null
            : Border.all(color: Color(0xffC8C4FF), width: 2)),
    child: Card(
      color: isHighlighed ? Color(0xff006AFA) : Color(0xffF0EFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 40,
                color: isHighlighed ? Colors.white : Color(0xffF0EFFF),
              )
            else
              Image.asset(
                icon,
                width: 40,
                height: 40,
              ),
            SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isHighlighed ? Colors.white : Color(0xff006AFA),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
*/


/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ongc_doctor_app/doctor/doctor_details_page.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';
import 'package:ongc_doctor_app/doctor/widget/doctor_card.dart';

import 'category_doctor_list_page.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _doctorDatabase =
      FirebaseDatabase.instance.ref().child('Doctors');
  final DatabaseReference _patientDatabase =
      FirebaseDatabase.instance.ref().child('Patients');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Doctor> _doctors = [];
  bool _isLoading = true;

  String? _patientName;
  String? _patientUID;
  String? _patientLocation;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchPatientInfo();
  }

  Future<void> _fetchDoctors() async {
    await _doctorDatabase.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchPatientInfo() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      _patientDatabase.child(userId).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> patientData =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _patientName = patientData['name'] ?? 'Unknown';
            _patientUID = userId;
            _patientLocation = patientData['location'] ?? 'Unknown';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info at Top-Right
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Name: ${_patientName ?? 'Loading...'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'UID: ${_patientUID ?? 'Loading...'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Location: ${_patientLocation ?? 'Loading...'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'Find your doctor,\nand book an appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          context, 'Cardiologist', 'assets/heart.png'),
                      _buildCategoryCard(
                          context, 'Oncologist', 'assets/onco.png'),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          context, 'Dentist', 'assets/dental.png'),
                      _buildCategoryCard(context, 'See All', 'assets/grid.png',
                          isHighlighed: true),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailPage(doctor: _doctors[index]),
                                ),
                              );
                            },
                            child: DoctorCard(doctor: _doctors[index]));
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildCategoryCard(BuildContext context, String title, dynamic icon,
    {bool isHighlighed = false}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    decoration: BoxDecoration(
        color: isHighlighed ? Color(0xff006AFA) : Color(0xffF0EFFF),
        borderRadius: BorderRadius.circular(15),
        border: isHighlighed
            ? null
            : Border.all(color: Color(0xffC8C4FF), width: 2)),
    child: Card(
      color: isHighlighed ? Color(0xff006AFA) : Color(0xffF0EFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 40,
                color: isHighlighed ? Colors.white : Color(0xffF0EFFF),
              )
            else
              Image.asset(
                icon,
                width: 40,
                height: 40,
              ),
            SizedBox(
              height: 16,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isHighlighed ? Colors.white : Color(0xff006AFA),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
*/


/*import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_doctor_list_page.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';
import 'package:ongc_doctor_app/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30.0),
                  Text(
                    'Find your doctor,\nand book an appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Cardiologist', 'assets/heart.png'),
                      _buildCategoryCard(context, 'Oncologist', 'assets/onco.png'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Dentist', 'assets/dental.png'),
                      _buildCategoryCard(context, 'See All', 'assets/grid.png',
                          isHighlighted: true),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to doctor details
                          },
                          child: DoctorCard(doctor: _doctors[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String icon,
      {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDoctorListPage(category: title),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
          borderRadius: BorderRadius.circular(15),
          border: isHighlighted
              ? null
              : Border.all(color: const Color(0xffC8C4FF), width: 2),
        ),
        child: Card(
          color: isHighlighted ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isHighlighted ? Colors.white : const Color(0xff006AFA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/







/*import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ongc_doctor_app/doctor/doctor_details_page.dart';
import 'package:ongc_doctor_app/doctor/model/doctor.dart';
import 'package:ongc_doctor_app/doctor/widget/doctor_card.dart';
import 'category_doctor_list_page.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'Find your doctor,\nand book an appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          context, 'Cardiologist', 'assets/heart.png'),
                     _buildCategoryCard(
                          context, 'Oncologist', 'assets/onco.png'),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          context, 'Dentist', 'assets/dental.png'),
                      _buildCategoryCard(
                          context, 'See All', 'assets/grid.png',
                          isHighlighed: true),
                    ],
                  ),
                  
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailPage(doctor: _doctors[index]),
                                ),
                              );
                            },
                            child: DoctorCard(doctor: _doctors[index]));
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildCategoryCard(BuildContext context, String title, dynamic icon,
    {bool isHighlighed = false}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    decoration: BoxDecoration(
        color: isHighlighed ? Color(0xff006AFA) : Color(0xffF0EFFF),
        borderRadius: BorderRadius.circular(15),
        border: isHighlighed
            ? null
            : Border.all(color: Color(0xffC8C4FF), width: 2)),
    child: Card(
      color: isHighlighed ? Color(0xff006AFA) : Color(0xffF0EFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 40,
                color: isHighlighed ? Colors.white : Color(0xffF0EFFF),
              )
            else
              Image.asset(
                icon,
                width: 40,
                height: 40,
              ),
            SizedBox(
              height: 16,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isHighlighed ? Colors.white : Color(0xff006AFA),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
*/
