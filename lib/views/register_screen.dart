
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'food_shared_screen.dart';
import 'otp_screen.dart';
import '/main.dart';
import '/services/firebase_auth_service.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  void _register(BuildContext context) async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phoneNumber = _phoneNumberController.text;

    if (!_isPhoneNumberValid(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid Malaysian phone number.')),
      );
      return;
    }


    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      await signUp(email, password, username, phoneNumber, uid);

      // Navigator.pushNamed(context, '/email_verification');
      if (userCredential.user != null) {
        // User registration successful, send OTP message and navigate to OTP screen
        await _firebaseAuthService.sendOtpMessage(phoneNumber);
        _navigateToOtpScreen(phoneNumber, userCredential.user!.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> signUp(String email, String password, String name, String phone,
      String uid) async {
    try {
      // save user data to Firestore
      CollectionReference usersRef =
          FirebaseFirestore.instance.collection('users');
      await usersRef.doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
      });

      print('User created successfully!');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  void _navigateToOtpScreen(String phoneNumber, String verificationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(
          verificationId: verificationId,
        ),
      ),
    ).then((value) {
      // OTP verification completed, navigate back to the Login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    });
  }

  bool _isPhoneNumberValid(String phoneNumber) {
    RegExp regExp = RegExp(r'^\+[1-9]\d{1,14}$');
    return regExp.hasMatch(phoneNumber);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          'Second Serving',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Registration',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,

              style: TextStyle(color: Colors.green),
              decoration: InputDecoration(

                labelText: 'Username',
                prefixIcon: Icon(Icons.person, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,

              style: TextStyle(color: Colors.green),
              decoration: InputDecoration(

                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: Colors.green),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(

              controller: _phoneNumberController,
              style: TextStyle(color: Colors.green),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(

                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _register(context),

              child: Text('Register'),
              style: ElevatedButton.styleFrom(primary: Colors.green),

            ),
          ],
        ),
      ),
    );
  }
}
