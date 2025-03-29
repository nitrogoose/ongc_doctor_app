import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? patientId;
  final String? patientName;

  ChatScreen({
    this.doctorId,
    this.doctorName,
    this.patientId,
    this.patientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListDatabase =
      FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _chatDatabase =
      FirebaseDatabase.instance.ref().child('Chat');
  final TextEditingController _messageController = TextEditingController();
  String? _currentUserId;

  bool get isDoctor => _currentUserId == widget.doctorId; // checks if current user is p or d

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUserId = _auth.currentUser?.uid; // allows access only if currentuser is not null, ?. is not null operator
  }

  // send message method
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      String message = _messageController.text.trim();
      String chatId = _chatDatabase.push().key!; // unique chatid generated
      String timeStamp = DateTime.now().toIso8601String(); // current time

      //determine sender and receiver IDs based on the user's role
      String senderUid;
      String receiverUid;

      if (isDoctor) {
        senderUid = _currentUserId!;
        receiverUid = widget.patientId!;
      } else {
        senderUid = _currentUserId!;
        receiverUid = widget.doctorId!;
      }

      // save message in Chat database
      _chatDatabase.child(chatId).set({
        'message': message,
        'receiver': receiverUid,
        'sender': senderUid,
        'timestamp': timeStamp,
      });

      //update chatList
      _chatListDatabase.child(senderUid).child(receiverUid).set({ 
        //This creates an entry in the sender's chat list for the receiver.
        'id': receiverUid,
      });

      _chatListDatabase.child(receiverUid).child(senderUid).set({
        'id': senderUid,
      });

      //clear the message input
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? chatPartnerName = isDoctor ? widget.patientName : widget.doctorName;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); //hides keyboard when clicked outside input field
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '$chatPartnerName',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder( // changes ui based on real time updates
                    stream: _chatDatabase.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data?.snapshot.value == null) {
                        return Center(child: Text('No message yet.'));
                      }
                      Map<dynamic, dynamic> messagesMap = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>; //snapshot to map
                      List<Map<String, dynamic>> messagesList = [];

                      messagesMap.forEach((key, value) {
                        if ((value['sender'] == _currentUserId &&
                                value['receiver'] == widget.doctorId) ||
                            (value['sender'] == widget.doctorId &&
                                value['receiver'] == _currentUserId) ||
                            (value['sender'] == _currentUserId &&
                                value['receiver'] == widget.patientId) ||
                            (value['sender'] == widget.patientId &&
                                value['receiver'] == _currentUserId)) {
                          messagesList.add({ // adds message to list
                            'message': value['message'],
                            'sender': value['sender'],
                            'timestamp': value['timestamp'],
                          });
                        }
                      });
                      messagesList.sort(
                          (a, b) => a['timestamp'].compareTo(b['timestamp'])); // sorts message by time

                      return ListView.builder( // displays messages
                          itemCount: messagesList.length,
                          itemBuilder: (context, index) {
                            bool isMe =
                                messagesList[index]['sender'] == _currentUserId;
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight // aligns left if patient or right if doctor
                                  : Alignment.centerLeft,
                              child: Container( // message bubble decoration
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Color(0xffC8C4FF)
                                      : Color(0xffE3E3E3),
                                  borderRadius: isMe
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.zero)
                                      : BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.circular(10)),
                                ),
                                child: Text(messagesList[index]['message']),
                              ),
                            );
                          });
                    })),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.normal
                        ),
                        controller: _messageController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffF0EFFF),
                            hintText: 'Enter your message..',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Color(0xffC8C4FF)))),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(
                        Icons.send,
                        size: 30,
                        color: Color(0xff0064FA),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}