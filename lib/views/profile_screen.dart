import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? phoneNumber;
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    if (widget.user != null) {
      DocumentSnapshot userSnapshot = await usersCollection.doc(widget.user.uid).get();
      setState(() {
        username = widget.user.displayName;
        phoneNumber = userSnapshot.get('phone');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Username: ${username ?? widget.user.displayName ?? "N/A"}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${widget.user.email ?? "N/A"}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Phone Number: ${phoneNumber ?? "N/A"}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
