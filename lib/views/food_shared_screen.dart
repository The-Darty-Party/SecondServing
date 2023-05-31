import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class Meal {
  final String name;
  final String description;
  final String location;
  final String photo;

  Meal({
    required this.name,
    required this.description,
    required this.location,
    required this.photo,
  });
}

class FoodReceiverScreen extends StatefulWidget {
  const FoodReceiverScreen({Key? key}) : super(key: key);

  @override
  _FoodReceiverScreenState createState() => _FoodReceiverScreenState();
}

class _FoodReceiverScreenState extends State<FoodReceiverScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('meals').get();
      final List<Meal> meals = snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal(
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          photo: data['photo'] ?? '',
        );
      }).toList();

      setState(() {
        _meals = meals;
      });
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Food Nearby'),
        backgroundColor: Colors.green, // Set the app bar color to green
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // TODO: Implement history button functionality
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green, // Set the drawer header color to green
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Username: ${user?.displayName ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Email: ${user?.email ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Chat'),
              leading: Icon(Icons.chat),
              onTap: () {
                // TODO: Implement the chat functionality
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              leading: Icon(Icons.logout),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal.photo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                meal.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Location: ${meal.location}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    meal.description,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement plus button functionality
        },
        child: Icon(Icons.add),
        backgroundColor:
            Colors.green, // Set the floating action button color to green
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FoodReceiverScreen(),
  ));
}
