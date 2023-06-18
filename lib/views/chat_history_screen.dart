import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secondserving/services/firebase_auth_service.dart';

class ChatHistoryScreen extends StatelessWidget {
  final CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection('chats');

  String uid = "";
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    if (user != null) {
      uid = user!.uid;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            final chats = snapshot.data!.docs;

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final lastMessage = chat.get('lastMessage');

                return FutureBuilder<String>(
                  future: _firebaseAuthService
                      .getUserName(chat.get('participants')[1]),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    String contactName = '';
                    if (snapshot.hasData) {
                      contactName = snapshot.data!;
                    } else if (snapshot.hasError) {
                      // Handle the error here
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(contactName),
                      subtitle: Text(lastMessage),
                      onTap: () {
                        // Handle chat item tap
                      },
                    );
                  },
                );
              },
            );
          }

          return Text('No chats available.');
        },
      ),
    );
  }
}
