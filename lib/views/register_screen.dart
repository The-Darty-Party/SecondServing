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
        SnackBar(content: Text('Please enter a valid Malaysian phone number.')),
      );
      return;
    }

    String? result = await firebaseAuth.registerWithEmailAndPassword(email, password);

    if (result == null) {
      _showSuccessMessage(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  void _showSuccessMessage(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Registration Successful'),
        content: Text('You have successfully registered.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  bool _isPhoneNumberValid(String phoneNumber) {
    RegExp regExp = RegExp(r'^01[0-46-9]-*[0-9]{7,8}$');
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
              obscureText: true,
              style: TextStyle(color: Colors.green),
             
decoration: InputDecoration(
labelText: 'Password',
prefixIcon: Icon(Icons.lock, color: Colors.green),
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16.0),
TextField(
controller: _phoneNumberController,
keyboardType: TextInputType.number,
style: TextStyle(color: Colors.green),
decoration: InputDecoration(
labelText: 'Phone Number',
prefixIcon: Icon(Icons.phone, color: Colors.green),
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16.0),
ElevatedButton(
onPressed: () => _register(context),
child: Text(
'Register',
style: TextStyle(fontSize: 18.0, color: Colors.white),
),
style: ElevatedButton.styleFrom(primary: Colors.green),
),
],
),
),
);
}
}

