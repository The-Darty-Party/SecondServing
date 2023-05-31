import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/main.dart'; // Replace with the appropriate screen import

class OtpScreen extends StatefulWidget {
  final String verificationId;

  OtpScreen({required this.verificationId});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _verifyOtp(BuildContext context) async {
    String otp = _otpController.text.trim();
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otp,
    );

    try {
      // Sign in with the provided phone authentication credential
      await _firebaseAuth.signInWithCredential(phoneAuthCredential);

      // OTP verification successful, navigate to the main screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with the appropriate screen
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Show error message if OTP verification fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Screen'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.green),
              decoration: InputDecoration(
                labelText: 'OTP',
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _verifyOtp(context),
              child: Text(
                'Verify OTP',
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
