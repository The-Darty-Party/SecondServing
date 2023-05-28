import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secondserving/views/register_screen.dart';
import 'package:secondserving/services/firebase_auth_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:secondserving/views/share_meal_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final firebaseAuth = FirebaseAuthService();
  var isLoading = false;
  void _login(BuildContext context) async {
    EasyLoading.show(status: 'loading...');
    String username = _usernameController.text;
    String password = _passwordController.text;
    try {
      firebaseAuth.signInWithEmailAndPassword(username, password).then((value) {
        final snackBar = SnackBar(content: Text(value.toString()));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
      EasyLoading.dismiss();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DishForm()),
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
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: username)
          .then((value) {
        final snackBar = const SnackBar(
            content: Text(
                'Password reset email sent. Please check your email inbox.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((error) {
        final snackBar = SnackBar(content: Text(error.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = const SnackBar(
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
            const Text(
              'Second Serving',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
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
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => _navigateToRegisterScreen(context),
              child: const Text('Register'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => _forgotPassword(context),
              child: const Text('Forgot Password'),
            ),
          ],
        ),
      ),
    );
  }
}
