import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'model/booking.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // makes an instance
  final DatabaseReference _requestDatabase =
      FirebaseDatabase.instance.ref().child('Requests'); // requests node
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() { //called when widget first loaded
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid; // fetches current user id
    if (currentUserId != null) { // checks if user is logged in
      await _requestDatabase
          .orderByChild('receiver')
          .equalTo(currentUserId) // fetches receiver details under requests node equal to current user id
          .once()
          .then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap =
              event.snapshot.value as Map<dynamic, dynamic>;
          _bookings.clear(); // clears for duplicate value
          bookingMap.forEach((key, value) {
            _bookings.add(Booking.fromMap(Map<String, dynamic>.from(value))); // map to doctor object loop, adds to bookings
          });
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Requests'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text('No booking available'))
              : ListView.builder( // Dynamically creates a scrollable list of bookings.
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return ListTile(
                      title: Text(booking.description),
                      subtitle: Text('Date: ${booking.date} Time: ${booking.time}'),
                      trailing: Text(booking.status),
                      onTap: () =>
                          _showStatusDialog(booking.id, booking.status, booking),
                    );
                  }),
    );
  }

  void _showStatusDialog(String requestId, String currentStatus, Booking booking) {
    List<String> statuses = ['Accepted', 'Rejected', 'Completed', 'Postponed'];
    String selectedStatus = currentStatus;
    DateTime? newDate;
    TimeOfDay? newTime;
    TextEditingController reasonController = TextEditingController();

    showDialog( // dialog box
      context: context,
      builder: (context) {
        return StatefulBuilder( // dynamic updates
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Request Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please select the status for this request.'),
                  SizedBox(height: 16.0),
                  Column(
                    children: List.generate(statuses.length, (index) {
                      return RadioListTile<String>(
                        title: Text(statuses[index]),
                        value: statuses[index],
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      );
                    }),
                  ),
                  if (selectedStatus == 'Postponed') ...[
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            newDate = pickedDate;
                          });
                        }
                      },
                      child: Text(newDate == null
                          ? 'Select New Date'
                          : '${newDate!.toLocal()}'.split(' ')[0]),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            newTime = pickedTime;
                          });
                        }
                      },
                      child: Text(newTime == null
                          ? 'Select New Time'
                          : newTime!.format(context)),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason for Postponement',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedStatus == 'Postponed' &&
                        (newDate == null || newTime == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please select a new date and time.')));
                      return;
                    }

                    if (selectedStatus == 'Postponed' &&
                        reasonController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please provide a reason for postponement.')));
                      return;
                    }

                    await _updateRequestStatus(
                      requestId,
                      selectedStatus,
                      newDate,
                      newTime,
                      reasonController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateRequestStatus(
    String requestId,
    String status,
    DateTime? newDate,
    TimeOfDay? newTime,
    String reason,
  ) async {
    Map<String, dynamic> updates = {'status': status};
    if (status == 'Postponed') {
      updates.addAll({
        'newDate': newDate != null ? '${newDate.toLocal()}'.split(' ')[0] : null,
        'newTime': newTime?.format(context),
        'postponementReason': reason,
      });
    }
    await _requestDatabase.child(requestId).update(updates); // stores updates in Requests in firebase
    await _fetchBookings(); // refreshes
  }
}




/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'model/booking.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase =
      FirebaseDatabase.instance.ref().child('Requests');
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      await _requestDatabase
          .orderByChild('receiver')
          .equalTo(currentUserId)
          .once()
          .then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap =
              event.snapshot.value as Map<dynamic, dynamic>;
          _bookings.clear();
          bookingMap.forEach((key, value) {
            _bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
          });
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Requests'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text('No booking available'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return ListTile(
                      title: Text(booking.description),
                      subtitle:
                          Text('Date: ${booking.date} Time: ${booking.time}'),
                      trailing: Text(booking.status),
                      onTap: () =>
                          _showStatusDialog(booking.id, booking.status),
                    );
                  }),
    );
  }

  void _showStatusDialog(String requestId, String currentStatus) {
    List<String> statuses = ['Accepted', 'Rejected', 'Completed'];
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Request Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please select the status for this request.'),
                  SizedBox(height: 16.0),
                  Column(
                    children: List.generate(statuses.length, (index) {
                      return RadioListTile<String>(
                        title: Text(statuses[index]),
                        value: statuses[index],
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await _updateRequestStatus(requestId, selectedStatus);
                    Navigator.pop(context);
                  },
                  child: Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _requestDatabase.child(requestId).update({
      'status': status,
    });
    await _fetchBookings();
  }
}
*/