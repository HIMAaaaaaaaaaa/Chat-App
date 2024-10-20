// ignore_for_file: unused_import

import 'dart:io';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart'; 
import 'ImageViewScreen.dart'; 

class ChatScreen extends StatefulWidget {
  final String receiverUserID;
  final String receiverUserEmail;
  final String receiverUserName;
  final String receiverUserphotoUrl;

  const ChatScreen({
    required this.receiverUserID,
    required this.receiverUserEmail,
    required this.receiverUserName,
    required this.receiverUserphotoUrl,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatService _chatService;
  late final FirebaseAuth _firebaseAuth;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _firebaseAuth = FirebaseAuth.instance;
  }

  void sendMessage(String message) async {
    await _chatService.sendMessage(
      _firebaseAuth.currentUser!.uid,
      widget.receiverUserID,
      message,
    );
    _messageController.clear(); // Clear the text field after sending the message
  }

  void sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('chat_media/${DateTime.now().toString()}');
      UploadTask uploadTask = ref.putFile(File(pickedFile.path));

      uploadTask.then((res) async {
        String photoUrl = await res.ref.getDownloadURL();
        sendMessage(photoUrl); // Sending the image URL as a message
      });
    }
  }

  void showImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverUserphotoUrl.isNotEmpty
                  ? NetworkImage(widget.receiverUserphotoUrl)
                  : null, // No need for image if photoUrl is empty
              child: widget.receiverUserphotoUrl.isEmpty ? Icon(Icons.person) : null, // Display person icon if photoUrl is empty
            ),
            SizedBox(width: 5),
            Text(widget.receiverUserName, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: buildMessageList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ChatInput(
                    controller: _messageController,
                    onSendPressed: sendMessage,
                  ),
                ),
                IconButton(
                  onPressed: sendImage,
                  icon: Icon(Icons.image),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        _firebaseAuth.currentUser!.uid,
        widget.receiverUserID,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = snapshot.data!.docs[index];
            return buildMessageItem(document);
          },
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var isSender = (data['senderId'] == _firebaseAuth.currentUser!.uid);

    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isSender) // Display receiver's avatar only for receiver's messages
                  CircleAvatar(
                    backgroundImage: widget.receiverUserphotoUrl.isNotEmpty
                        ? NetworkImage(widget.receiverUserphotoUrl)
                        : null, // No need for image if photoUrl is empty
                    child: widget.receiverUserphotoUrl.isEmpty ? Icon(Icons.person) : null, // Display person icon if photoUrl is empty
                  ),
                SizedBox(width: 10),
                Flexible(
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5, // Limit message box width to 50% of screen width
                        ),
                        padding: data['message'].toString().startsWith('http') ? null : EdgeInsets.all(10.0),
                        decoration: data['message'].toString().startsWith('http') ? null : BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: isSender ? Colors.blue : Colors.grey[300], // Sender message color: Blue, Receiver message color: Grey
                        ),
                        child: data['message'].toString().startsWith('http')
                            ? GestureDetector(
                                onTap: () => showImage(context, data['message']),
                                child: Container(
                                  width: 150, // Fixed width for the image
                                  height: 150, // Fixed height for the image
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(data['message']),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ) // Display image if the message is a URL
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['message'],
                                    style: TextStyle(color: isSender ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    data['timestamp'].toDate().toString(),
                                    style: TextStyle(fontSize: 10.0, color: Colors.grey, fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TextBubble extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isSender;

  const TextBubble({
    required this.message,
    required this.timestamp,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: isSender ? Colors.blue : Colors.grey[300], // Sender message color: Blue, Receiver message color: Grey
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: isSender ? Colors.white : Colors.black),
          ),
          Text(
            timestamp,
            style: TextStyle(fontSize: 10.0, color: Colors.grey, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSendPressed;

  const ChatInput({
    required this.controller,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Type your message',
              border: OutlineInputBorder(
                gapPadding: 5,
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onSubmitted: (text) {
              if (text.trim().isNotEmpty) {
                onSendPressed(text);
                controller.clear(); // Clear the text field after sending the message
              }
            },
          ),
        ),
        IconButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              onSendPressed(text);
              controller.clear(); // Clear the text field after sending the message
            }
          },
          icon: Icon(Icons.send),
        ),
      ],
    );
  }
}

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    final String chatRoomId = getChatRoomId(senderId, receiverId);

    Message newMessage = Message(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final String chatRoomId = getChatRoomId(userId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String getChatRoomId(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    return ids.join("_");
  }
}

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  const Message({
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;

  ImageViewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

