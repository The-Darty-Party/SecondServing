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
        apiKey: "AIzaSyDBIbP0W6zaYMovXuK1CUsuHBfuuIR8Luo",
        appId: "1:855207657361:android:7cc50e23eee3d51aa0a430",
        messagingSenderId: "855207657361",
        projectId: "login-9e408"),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final firebaseAuth = FirebaseAuthService();
  bool _isPasswordVisible = false;

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
            builder: (context) => ProfileScreen(
              user: username,
              email: 'example@example.com',// Replace with the user's email
              phoneNumber: '01xxxxxxxxx', 
 
            ),
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
      FirebaseAuth.instance.sendPasswordResetEmail(email: username).then((value) {
        final snackBar = SnackBar(
          content: Text('Password reset email sent. Please check your email inbox.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((error) {
        final snackBar = SnackBar(content: Text(error.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = SnackBar(
        content: Text('Please enter your email address to reset password'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Second Serving',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                style: TextStyle(fontSize: 18.0, color: Colors.green),
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller:
_passwordController,
obscureText: !_isPasswordVisible,
style: TextStyle(fontSize: 18.0, color: Colors.green),
decoration: InputDecoration(
labelText: 'Password',
prefixIcon: Icon(Icons.lock, color: Colors.green),
suffixIcon: IconButton(
icon: Icon(
_isPasswordVisible ? Icons.visibility_off : Icons.visibility,
color: Colors.green,
),
onPressed: () {
setState(() {
_isPasswordVisible = !_isPasswordVisible;
});
},
),
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16.0),
ElevatedButton(
onPressed: () => _login(context),
child: Text(
'Login',
style: TextStyle(fontSize: 18.0, color: Colors.black),
),
style: ElevatedButton.styleFrom(
primary: Colors.green,
),
),
const SizedBox(height: 16.0),
TextButton(
onPressed: () => _navigateToRegisterScreen(context),
child: Text(
'Register',
style: TextStyle(fontSize: 18.0, color: Colors.green),
),
),
const SizedBox(height: 16.0),
TextButton(
onPressed: () => _forgotPassword(context),
child: Text(
'Forgot Password',
style: TextStyle(fontSize: 18.0, color: Colors.green),
),
),
],
),
),
),
);
}
}