//main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/profile_screen.dart';
import 'views/register_screen.dart';
import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCHY9o8tJyXwlRwRWciDTDuP0vMktvsD1M",
        appId: "1:566371582218:web:d583fb46a9874aeb967af3",
        messagingSenderId: "566371582218",
        projectId: "secondserving-ef1f1"),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    ),
  );
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final firebaseAuth = FirebaseAuthService();

  void _login(BuildContext context) async {
  String username = _usernameController.text;
  String password = _passwordController.text;

  firebaseAuth.signInWithEmailAndPassword(username, password).then((value) {
    final snackBar = SnackBar(content: Text(value.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  });

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        ),
      );
    }
  });
}


  void _navigateToRegisterScreen(BuildContext context) {
    // Navigate to the RegisterScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _forgotPassword(BuildContext context) async {
    String username = _usernameController.text;
    if (username.isNotEmpty) {
      FirebaseAuth.instance.sendPasswordResetEmail(email: username)
          .then((value) {
        final snackBar = SnackBar(
            content: Text(
                'Password reset email sent. Please check your email inbox.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((error) {
        final snackBar = SnackBar(content: Text(error.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = SnackBar(
          content: Text('Please enter your email address to reset password'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Second Serving',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => _navigateToRegisterScreen(context),
              child: Text('Register'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => _forgotPassword(context),
              child: Text('Forgot Password'),
            ),
          ],
        ),
      ),
    );
  }
}
