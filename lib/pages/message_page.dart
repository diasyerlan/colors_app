import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colors_app/components/chat_bubble.dart';
import 'package:colors_app/components/textfield.dart';
import 'package:colors_app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  MessagePage(
      {super.key, required this.receiverEmail, required this.receiverID});
  String receiverEmail;
  String receiverID;

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(receiverEmail),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildUserInput(),
          ],
        ));
  }

  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data == null) {
          return Text("No data");
        }
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data['senderID'] == FirebaseAuth.instance.currentUser!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child:
            ChatBubble(message: data['message'], isCurrentUser: isCurrentUser));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
              child: MyTextField(
            controller: _messageController,
            hintText: "Type a message",
            obscureText: false,
          )),
          IconButton(
              onPressed: sendMessage,
              icon: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.green),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.arrow_upward),
                  )))
        ],
      ),
    );
  }
}
