import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secondserving/views/share_meal_screen.dart';
import '../models/meal_model.dart';
import 'chat_history_screen.dart';
import 'profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'meal_details.dart' as meal_details;
import 'history.dart' as history;

import 'messages_screen.dart';

class FoodReceiverScreen extends StatefulWidget {
  const FoodReceiverScreen({Key? key}) : super(key: key);

  @override
  _FoodReceiverScreenState createState() => _FoodReceiverScreenState();
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text('This is the history page.'),
      ),
    );
  }
}

class _FoodReceiverScreenState extends State<FoodReceiverScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<Meal> _meals = [];
  bool _sortMealsByNewest = false;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    try {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      Query<Map<String, dynamic>> mealsQuery =
          FirebaseFirestore.instance.collection('meals');

      if (_sortMealsByNewest) {
        mealsQuery = mealsQuery.orderBy('date', descending: true);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await mealsQuery.get();
      final List<Meal> meals = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final String mealStatus = data['status'] ?? '';
            final String mealDonorID = data['donorID'] ?? '';
            final String mealReceiverID = data['receiverID'] ?? '';

            if (mealStatus == 'booked' &&
                mealDonorID != userId &&
                mealReceiverID != userId) {
              return null; // Skip this meal if it's booked and not assigned to the user
            }

            final Timestamp timestamp =
                data['date'] ?? Timestamp.now(); // Get the timestamp

            return Meal(
              mealId: doc.id,
              donorId: data['donorID'] ?? '',
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              location: data['location'] ?? '',
              photo: data['photo'] ?? '',
              status: mealStatus,
              date:
                  timestamp.toDate().toString(), // Convert timestamp to string
            );
          })
          .whereType<Meal>()
          .toList();

      setState(() {
        _meals = meals;
      });
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  void _navigateToMealDetails(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => meal_details.MealDetailsScreen(meal: meal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Food Nearby'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => history.HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _sortMealsByNewest = !_sortMealsByNewest;
                _fetchMeals();
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
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
                    user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              leading: Icon(Icons.logout),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
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
                    'Description: ${meal.description}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Status: ${meal.status}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              onTap: () {
                _navigateToMealDetails(meal);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DishForm()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
