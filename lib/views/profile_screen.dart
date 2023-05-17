import 'package:flutter/material.dart';
import '../main.dart';
import '../services/firebase_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final String user;
  final String email;
  final String phoneNumber;

  ProfileScreen({required this.user, required this.email, required this.phoneNumber});

  final firebaseAuth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green, // Set the app bar background color
      ),
      body: Center( // Wrap the Column with Center widget
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Align items in the center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Align items in the center horizontally
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green, // Change the background color to green
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Username: $user',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green), // Adjust the font size and color
              ),
              SizedBox(height: 10),
              Text(
                'Email: $email',
                style: TextStyle(fontSize: 18, color: Colors.green), // Adjust the font size and color
              ),
              SizedBox(height: 10),
              Text(
                'Phone number: $phoneNumber',
                style: TextStyle(fontSize: 18, color: Colors.green), // Adjust the font size and color
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  firebaseAuth.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Set the button's background color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
