import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const ChatScreen({Key? key, this.data}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SharedPreferences? prefs;
  Map userData = {};

  String? groupChatId;
  CollectionReference? users;

  TextEditingController message = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    prefs = await SharedPreferences.getInstance();
    userData = jsonDecode(prefs!.getString('login_data')!);
    createDocID();
  }

  createDocID() {
    if (userData['user_id'].hashCode <= widget.data!['user_id'].hashCode) {
      groupChatId = '${userData['user_id']}-${widget.data!['user_id']}';
    } else {
      groupChatId = '${widget.data!['user_id']}-${userData['user_id']}';
    }
    setState(() {});
    users = FirebaseFirestore.instance.collection('messages').doc(groupChatId).collection("chat");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: widget.data!['image'] == null
              ? const ClipOval(
                  child: Icon(
                    Icons.person,
                    color: Colors.red,
                  ),
                )
              : ClipOval(
                  child: Image.network(
                    widget.data!['image'],
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
          title: Text(widget.data!['full_name']),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: users == null
                ? const SizedBox()
                : StreamBuilder<QuerySnapshot>(
                    stream: users!.orderBy('time', descending: true).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) {
                        if (!snapshot.hasData) return const Text("No Chat");
                        return ListView(
                          reverse: true,
                          padding: const EdgeInsets.all(15),
                          children: snapshot.data!.docs.map<Widget>(
                            (doc) {
                              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                              return data['sender_id'] != userData['user_id'] ? generateReceiverLayout(doc) : generateSenderLayout(doc);
                            },
                          ).toList(),
                        );
                      } else {
                        return Text('State: ${snapshot.connectionState}');
                      }
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10).copyWith(top: 0),
            child: TextField(
              controller: message,
              decoration: InputDecoration(
                hintText: "Message",
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: const Icon(
                    Icons.send,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 10, right: MediaQuery.of(context).size.width * 0.35),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            data['text'],
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget generateSenderLayout(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 10, left: MediaQuery.of(context).size.width * 0.35),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            data['text'],
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  sendMessage() async {
    await users!.add({
      'text': message.text,
      'sender_id': userData['user_id'],
      'receive_id': widget.data!['user_id'],
      'time': FieldValue.serverTimestamp(),
    }).then((value) {
      debugPrint("Message Send");
      message.clear();
    }).catchError((error) => debugPrint("Failed to send message: $error"));
  }
}
