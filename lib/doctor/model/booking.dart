



class Booking {
  final String date;
  final String description;
  final String id;
  final String receiver;
  final String sender;
  final String status;
  final String time;
  final String? newDate;
  final String? newTime;
  final String? postponementReason;

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.receiver,
    required this.sender,
    required this.status,
    required this.time,
    this.newDate,
    this.newTime,
    this.postponementReason,
  });

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      receiver: data['receiver'] ?? '',
      sender: data['sender'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] ?? '',
      newDate: data['newDate'],
      newTime: data['newTime'],
      postponementReason: data['postponementReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'id': id,
      'receiver': receiver,
      'sender': sender,
      'status': status,
      'time': time,
      'newDate': newDate,
      'newTime': newTime,
      'postponementReason': postponementReason,
    };
  }
}

















/*class Booking {
  final String date;
  final String description;
  final String id;
  final String receiver;
  final String sender;
  final String status;
  final String time;


  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.receiver,
    required this.sender,
    required this.status,
    required this.time,

  });

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      receiver: data['receiver'] ?? '',
      sender: data['sender'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] ?? '',

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'id': id,
      'receiver': receiver,
      'sender': sender,
      'status': status,
      'time': time,

    };
  }
}
*/