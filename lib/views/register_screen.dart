//register_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final firebaseAuth = FirebaseAuthService();

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
    String? result =
        await firebaseAuth.registerWithEmailAndPassword(email, password);

    if (result == null) {
      Navigator.pushNamed(context, '/email_verification');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  bool _isPhoneNumberValid(String phoneNumber) {
    RegExp regExp = RegExp(r'^01[0-46-9]-*[0-9]{7,8}$');
    return regExp.hasMatch(phoneNumber);
  }

  Future<void> signUp(
      String email, String password, String name, String phone) async {
    try {
      // create user account in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user data to Firestore
      CollectionReference usersRef =
          FirebaseFirestore.instance.collection('users');
      String uid = userCredential.user!.uid;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Serving'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller:
                  _phoneNumberController, // Add the phone number controller to the TextField
              keyboardType:
                  TextInputType.number, // Limit the input to numbers only
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _register(context),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
